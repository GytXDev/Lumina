import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerWidget extends StatelessWidget {
  final ThemeMode themeMode;

  const CustomShimmerWidget({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final baseColor =
        themeMode == ThemeMode.dark ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor =
        themeMode == ThemeMode.dark ? Colors.grey[600]! : Colors.grey[100]!;

    return ListTile(
      title: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 16,
          width: 200,
          color: baseColor,
        ),
      ),
      subtitle: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 14,
          width: 150,
          color: baseColor,
        ),
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: baseColor,
      ),
    );
  }
}
