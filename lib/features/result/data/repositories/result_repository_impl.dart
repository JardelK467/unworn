import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/garment_result.dart';
import '../../domain/repositories/result_repository.dart';

class QuotaExceededException implements Exception {
  const QuotaExceededException([this.message = 'API quota exceeded']);
  final String message;
  @override
  String toString() => message;
}

class InvalidGarmentException implements Exception {
  const InvalidGarmentException([this.message = 'Could not identify garment']);
  final String message;
  @override
  String toString() => message;
}

class ResultRepositoryImpl implements ResultRepository {
  @override
  Future<List<GarmentResult>> generateStyles(
    String imagePath, {
    String? userPrompt,
    ProgressCallback? onProgress,
  }) async {
    final imageBytes = await File(imagePath).readAsBytes();

    onProgress?.call(0.05, 'Analysing garment...');
    final concepts = await _analyzeWithGemini(imageBytes, userPrompt);

    final totalSteps = concepts.length + 1;
    final results = <GarmentResult>[];
    for (var i = 0; i < concepts.length; i++) {
      final concept = concepts[i];
      final progress = (i + 1) / totalSteps;
      onProgress?.call(
        progress,
        'Generating look ${i + 1} of ${concepts.length}...',
      );
      final generatedImage = await _generateImage(concept['imagePrompt']!);
      results.add(
        GarmentResult(
          title: concept['title']!,
          style: concept['style']!,
          transformation: concept['transformation']!,
          occasion: concept['occasion']!,
          imageBytes: generatedImage,
        ),
      );
    }

    onProgress?.call(1.0, 'Done');
    return results;
  }

  Future<List<Map<String, String>>> _analyzeWithGemini(
    Uint8List imageBytes,
    String? userPrompt,
  ) async {
    final model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    );

    final prompt = Content.multi([
      TextPart(
        '''You are an expert fashion stylist in 2026. Study the exact garment in this photo — its fabric, color, cut, silhouette, fit, and every visible detail.

Generate exactly 3 complete outfit styling concepts built around THIS EXACT garment, worn UNCHANGED. Each concept must:
- Keep the garment 100% identical to the photo — same color, same fabric, same cut, same fit, NO added details, NO modifications, NO embellishments, NO design changes whatsoever
- Style a complete outfit AROUND the garment using other clothing items, shoes, and accessories
- Be realistic — something a person could actually put together and wear today

Return only this JSON array, nothing else:
[
  {
    "title": "2-3 word styling concept name",
    "style": "One sentence on the overall aesthetic direction of the outfit",
    "transformation": "One sentence listing the key pieces paired with the garment (e.g. bottoms, shoes, accessories)",
    "occasion": "Short phrase e.g. Evening out, Casual weekend, Office smart-casual",
    "imagePrompt": "Ultra-detailed fashion photography prompt: describe the EXACT original garment first — its precise color, fabric, texture, fit, neckline, sleeve length, and every visible detail from the photo. The garment must appear EXACTLY as it is in the original photo with ZERO modifications. Then describe the complete styled outfit around it — specific bottoms, footwear, accessories, and layering pieces. Place on a model in a modern editorial setting with studio lighting, full body shot on 85mm lens, 2026 fashion campaign style, photorealistic, high fashion magazine quality"
  }
]

CRITICAL RULES for imagePrompt:
1. The garment from the photo must appear EXACTLY as-is — same color, same fabric, same construction, same fit. Do NOT add patterns, graphics, textures, embellishments, distressing, cropping, or ANY detail not visible in the original photo.
2. Describe the original garment with extreme precision so the generated image reproduces it faithfully.
3. All creativity goes into the OTHER pieces in the outfit, NOT into changing the garment itself.
4. Show a complete, wearable outfit that a real person could recreate.${userPrompt != null ? '\n\nADDITIONAL USER DIRECTION: The user wants: "$userPrompt". Incorporate this into the styling direction of all 3 outfits while keeping the original garment completely unchanged.' : ''}''',
      ),
      DataPart('image/jpeg', imageBytes),
    ]);

    final response = await model.generateContent([prompt]);
    final text = response.text ?? '';

    var jsonStr = text.trim();
    if (jsonStr.isEmpty) {
      throw const InvalidGarmentException();
    }

    if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr
          .replaceFirst(RegExp(r'^```\w*\n?'), '')
          .replaceFirst(RegExp(r'\n?```$'), '');
    }

    final trimmed = jsonStr.trimLeft();
    if (!trimmed.startsWith('[') && !trimmed.startsWith('{')) {
      throw const InvalidGarmentException();
    }

    final parsed = jsonDecode(jsonStr);
    final list = (parsed is List)
        ? parsed
        : (parsed as Map<String, dynamic>)['concepts'] as List;
    final concepts = list
        .map(
          (c) => {
            'title': c['title'] as String,
            'style': c['style'] as String,
            'transformation': c['transformation'] as String,
            'occasion': c['occasion'] as String,
            'imagePrompt': c['imagePrompt'] as String,
          },
        )
        .toList();

    if (concepts.isEmpty) {
      throw const InvalidGarmentException();
    }

    return concepts;
  }

  Future<Uint8List> _generateImage(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${AppConstants.geminiImageModel}:generateContent'
      '?key=${AppConstants.geminiApiKey}',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'responseModalities': ['IMAGE', 'TEXT'],
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 429) {
      throw const QuotaExceededException();
    }

    if (response.statusCode != 200) {
      final bodyStr = response.body.toLowerCase();
      if (bodyStr.contains('quota') || bodyStr.contains('billing')) {
        throw const QuotaExceededException();
      }
      throw Exception(
        'Gemini image generation failed (${response.statusCode}): ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List?;
    if (candidates != null && candidates.isNotEmpty) {
      final parts = (candidates[0]['content']['parts'] as List?) ?? [];
      for (final part in parts) {
        if (part case {'inlineData': {'data': final String b64Data}}) {
          return base64Decode(b64Data);
        }
      }
    }

    throw Exception('Gemini image generation returned no image data');
  }
}
