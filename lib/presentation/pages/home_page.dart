import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

      // Listen for processing completion
      ref.listenManual(
        homeViewModelProvider.select((s) => s.processedVideo),
        (prev, next) {
          if (next != null && prev == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Video processed successfully!'),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    });
  }

  Future<void> _pickVideo() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        ref.read(homeViewModelProvider.notifier).selectVideo(video.path);
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to pick video: $e'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Logo
            _buildLogo(),
            const Spacer(),
            // Video Selection Area
            _buildVideoSelectionArea(context, homeState, viewModel),
            const SizedBox(height: 24),
            // Process Button
            if (homeState.selectedVideoPath != null)
              _buildProcessButton(homeState, viewModel),
            const Spacer(),
            // Action Buttons
            _buildActionButtons(homeState, viewModel),
            const SizedBox(height: 40),
          ],
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
        onTap: state.isProcessing ? null : _pickVideo,
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
          'Select Video',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Build selected video preview
  Widget _buildSelectedVideoPreview(HomeState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          state.processedVideo != null ? Icons.check_circle : Icons.video_file,
          size: 48,
          color: state.processedVideo != null 
              ? Colors.green.shade600 
              : Colors.blue.shade600,
        ),
        const SizedBox(height: 8),
        Text(
          state.processedVideo != null 
              ? 'Processing Complete!'
              : _getFileName(state.selectedVideoPath!),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (state.isProcessing)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
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
    );
  }

  String _getFileName(String path) {
    return path.split('/').last;
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
                  state.processedVideo != null ? 'Process Again' : 'Process Video',
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
      child: Row(
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
