import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuyna/presentation/viewmodels/home_viewmodel.dart';

/// Home page widget - Main screen of nuyna app
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        onTap: () {
          // TODO: Implement video picker
          // For now, simulate selection
          viewModel.selectVideo('/example/video.mp4');
        },
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
          Icons.video_file,
          size: 48,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 8),
        Text(
          'Video Selected',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        if (state.isProcessing)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              value: state.processingProgress,
            ),
          ),
      ],
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
