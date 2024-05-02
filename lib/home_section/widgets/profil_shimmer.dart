import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final ThemeMode themeMode;

  const ShimmerWidget({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerLine(width: 200.0, height: 20.0),
          const SizedBox(height: 8.0),
          _buildShimmerLine(width: 150.0, height: 16.0),
          const SizedBox(height: 8.0),
          _buildShimmerLine(width: 180.0, height: 16.0),
        ],
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: _getBaseColor(),
      highlightColor: _getHighlightColor(),
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Color _getBaseColor() {
    return themeMode == ThemeMode.light
        ? Colors.grey[300]!
        : Colors.grey[800]!;
  }

  Color _getHighlightColor() {
    return themeMode == ThemeMode.light
        ? Colors.grey[100]!
        : Colors.grey[700]!;
  }
}
