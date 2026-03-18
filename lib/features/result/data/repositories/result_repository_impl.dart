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
        '''You are an expert fashion designer in 2026. Study the exact garment in this photo — its fabric, color, cut, silhouette, and construction details.

Generate exactly 3 reimagined versions of THIS SPECIFIC garment. Each concept must:
- Keep the original garment clearly recognizable (same base fabric/color family)
- Apply a distinct modern 2026 fashion transformation
- Be realistic and producible by a skilled tailor or fashion house

Return only this JSON array, nothing else:
[
  {
    "title": "2-3 word collection-style name",
    "style": "One sentence on the aesthetic direction",
    "transformation": "One sentence describing the exact physical changes to the garment",
    "occasion": "Short phrase e.g. Evening wear, Street style",
    "imagePrompt": "Ultra-detailed fashion photography prompt: describe the reimagined garment precisely — reference the original garment's color, fabric, and shape, then describe specific modifications (cuts, additions, styling). Place on a model in a modern editorial setting with studio lighting, shot on 85mm lens, 2026 fashion campaign style, photorealistic, high fashion magazine quality"
  }
]

CRITICAL for imagePrompt: Be extremely specific about the garment. Mention its exact color, material, and original form first, then describe each modification. The generated image must look like a real transformed version of this exact garment, not a generic fashion concept.${userPrompt != null ? '\n\nADDITIONAL USER DIRECTION: The user wants: "$userPrompt". Incorporate this vision into all 3 concepts while still keeping the garment recognizable.' : ''}''',
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
