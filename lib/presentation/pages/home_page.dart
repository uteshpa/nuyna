import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:nuyna/presentation/pages/result_page.dart';
import 'package:nuyna/presentation/viewmodels/home_viewmodel.dart';

/// Home page widget - Main screen of nuyna app
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Listen for error messages and show SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        homeViewModelProvider.select((s) => s.errorMessage),
        (prev, next) {
          if (next != null && next.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );

      // Listen for processing completion and navigate to ResultPage
      ref.listenManual(
        homeViewModelProvider.select((s) => s.processedVideo),
        (prev, next) {
          if (next != null && prev == null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ResultPage(processedVideo: next),
              ),
            ).then((_) {
              // Reset state when returning from result page
              if (mounted) {
                ref.read(homeViewModelProvider.notifier).clearSelection();
              }
            });
          }
        },
      );
    });
  }

  Future<void> _pickMedia() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Use pickMedia to select either image or video from gallery
      final XFile? file = await _picker.pickMedia();
      
      if (file != null) {
        ref.read(homeViewModelProvider.notifier).selectVideo(file.path);
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to pick media: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                  MediaQuery.of(context).padding.top - 
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 20),
                  // Video Selection Area
                  _buildVideoSelectionArea(context, homeState, viewModel),
                  const SizedBox(height: 24),
                  // Process Button
                  if (homeState.selectedVideoPath != null)
                    _buildProcessButton(homeState, viewModel),
                  const Spacer(),
                  // Action Buttons
                  _buildActionButtons(homeState, viewModel),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the nuyna logo with leaf icon
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'nuyna',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.eco_outlined,
          size: 28,
          color: Colors.black87,
        ),
      ],
    );
  }

  /// Build the video selection area with dashed border
  Widget _buildVideoSelectionArea(
    BuildContext context,
    HomeState state,
    HomeViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: state.isProcessing ? null : _pickMedia,
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade400,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: Colors.grey.shade500,
              strokeWidth: 2,
              gap: 8,
            ),
            child: Center(
              child: state.selectedVideoPath != null
                  ? _buildSelectedVideoPreview(state)
                  : _buildEmptyState(),
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state for video selection
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add,
          size: 40,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 12),
        Text(
          'Select Image',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Build selected media preview with thumbnail
  Widget _buildSelectedVideoPreview(HomeState state) {
    final path = state.selectedVideoPath!;
    final isImage = _isImageFile(path);
    
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isImage
                  ? Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
                    )
                  : FutureBuilder<Uint8List?>(
                      future: _generateVideoThumbnail(path),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            color: Colors.black12,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildVideoPlaceholder(),
                          );
                        }
                        return _buildVideoPlaceholder();
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          if (state.isProcessing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: state.processingProgress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(state.processingProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isImageFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'].contains(ext);
  }

  /// Build process button
  Widget _buildProcessButton(HomeState state, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: state.isProcessing ? null : viewModel.processVideo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: state.isProcessing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Processing...'),
                  ],
                )
              : Text(
                  'Process Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  /// Build action buttons row
  Widget _buildActionButtons(HomeState state, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Protection Switches
          _buildProtectionSwitches(state, viewModel),
          const SizedBox(height: 16),
          // Original Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.description_outlined,
                label: 'METADATA',
                isActive: state.options.enableMetadataStrip,
                onTap: viewModel.toggleMetadataStrip,
              ),
              _buildActionButton(
                icon: Icons.fingerprint,
                label: 'BIOMETRICS',
                isActive: state.options.enableIrisBlock || state.options.enableFingerGuard,
                onTap: viewModel.toggleBiometrics,
              ),
              _buildActionButton(
                icon: Icons.sentiment_satisfied_alt_outlined,
                label: 'FACE',
                isActive: state.options.enableFaceBlur,
                onTap: viewModel.toggleFaceBlur,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build protection switches for Level 2 features
  Widget _buildProtectionSwitches(HomeState state, HomeViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Fingerprint Guard',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Smooth fingerprint patterns',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            value: state.options.enableFingerGuard,
            onChanged: (_) => viewModel.toggleFingerGuard(),
            activeTrackColor: const Color(0xFF4CAF50).withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF4CAF50);
              }
              return null;
            }),
            secondary: Icon(
              Icons.fingerprint,
              color: state.options.enableFingerGuard 
                  ? const Color(0xFF4CAF50) 
                  : Colors.grey,
            ),
          ),
          Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text(
              'Advanced Face Protection',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'AI-resistant obfuscation',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            value: state.options.enableAdvancedFaceObfuscation,
            onChanged: (_) => viewModel.toggleAdvancedFaceObfuscation(),
            activeTrackColor: const Color(0xFF4CAF50).withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF4CAF50);
              }
              return null;
            }),
            secondary: Icon(
              Icons.security,
              color: state.options.enableAdvancedFaceObfuscation 
                  ? const Color(0xFF4CAF50) 
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.black87 : Colors.white,
              border: Border.all(
                color: Colors.black87,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 32,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for dashed border effect
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    path.addRRect(rect);

    // Draw dashed path
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + gap).clamp(0, metric.length);
        dashPath.addPath(
          metric.extractPath(start, end.toDouble()),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Extension methods for HomePage
extension _HomePageHelpers on _HomePageState {
  /// Generate thumbnail for video file
  Future<Uint8List?> _generateVideoThumbnail(String videoPath) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );
      return thumbnail;
    } catch (e) {
      return null;
    }
  }

  /// Build placeholder widget for video
  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.black12,
      child: Center(
        child: Icon(
          Icons.videocam,
          size: 48,
          color: Colors.blue.shade600,
        ),
      ),
    );
  }
}
