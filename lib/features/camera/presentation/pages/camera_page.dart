import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/consts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/gradient_border_button.dart';
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart' as app;

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CameraCubit>(),
      child: const _CameraView(),
    );
  }
}

class _CameraView extends StatefulWidget {
  const _CameraView();

  @override
  State<_CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<_CameraView> {
  final _promptController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final granted = await _requestPermission(
      Permission.camera,
      'Camera access is needed to capture your garment photo.',
    );
    if (!granted || !mounted) return;
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null && mounted) {
      context.read<CameraCubit>().onImageCaptured(picked.path);
    }
  }

  Future<void> _gallery() async {
    final permission = Platform.isAndroid
        ? Permission.photos
        : Permission.photos;
    final granted = await _requestPermission(
      permission,
      'Photo library access is needed to select your garment.',
    );
    if (!granted || !mounted) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      context.read<CameraCubit>().onImageCaptured(picked.path);
    }
  }

  Future<bool> _requestPermission(
    Permission permission,
    String rationale,
  ) async {
    var status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied && mounted) {
      await _showPermissionDeniedDialog(rationale);
    }
    return false;
  }

  Future<void> _showPermissionDeniedDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          GradientBorderButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            label: 'Open Settings',
            borderRadius: AppSpacing.pillRadius,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<CameraCubit, app.CameraState>(
        listener: (context, state) {
          if (state is app.CameraConfirmed) {
            context.go(
              '/result',
              extra: {
                'imagePath': state.imagePath,
                'userPrompt': state.userPrompt,
              },
            );
          } else if (state is app.CameraError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final imagePath = state is app.CameraPreview ? state.imagePath : null;
          final hasImage = imagePath != null;

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => hasImage
                          ? context.read<CameraCubit>().retake()
                          : context.go('/info'),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: hasImage
                              ? Image.file(File(imagePath), fit: BoxFit.cover)
                              : Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.checkroom_outlined,
                                        size: 48,
                                        color: AppColors.purple,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Capture or select\nyour garment',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              height: 1.3,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Use the buttons below to get started',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (hasImage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: _buildPromptField(),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: hasImage
                      ? _buildConfirmButtons(context, imagePath)
                      : _buildCaptureButtons(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptureButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _gallery,
              icon: const Icon(Icons.photo_library_outlined, size: 20),
              label: const Text('Gallery'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: GradientBorderButton(
              onPressed: _capture,
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              borderRadius: AppSpacing.pillRadius,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptField() {
    const purpleBorder = Color(0x99AB47BC);
    const purpleFocused = Color(0xFFAB47BC);

    return TextField(
      controller: _promptController,
      maxLines: 3,
      minLines: 1,
      maxLength: 150,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        hintText: 'Describe your vision... (optional)',
        hintStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purpleBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purpleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purpleFocused),
        ),
        counterStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }

  Widget _buildConfirmButtons(BuildContext context, String imagePath) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _promptController.clear();
              context.read<CameraCubit>().retake();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retake'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: GradientBorderButton(
            onPressed: () {
              final prompt = _promptController.text.trim();
              context.read<CameraCubit>().onImageConfirmed(
                imagePath,
                userPrompt: prompt.isEmpty ? null : prompt,
              );
            },
            icon: Icons.check,
            label: 'Confirm',
          ),
        ),
      ],
    );
  }
}
