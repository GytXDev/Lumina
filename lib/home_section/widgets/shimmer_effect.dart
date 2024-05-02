// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      width: 100.0,
                      height: 16.0,
                      color: Colors.white,
                    ),
                  ],
                ),
                Container(
                  width: 60.0,
                  height: 16.0,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Container(
              height: 200.0,
              color: Colors.grey[300]!,
            ),
            const SizedBox(
              height: 8.0,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20.0,
                    height: 16.0,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4.0),
                  Container(
                    width: 80.0,
                    height: 16.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50.0,
                    height: 20.0,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    width: 120.0,
                    height: 20.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60.0,
                  height: 20.0,
                  color: Colors.white,
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.grey[300]!,
                  ),
                  child: Container(
                    width: 120.0,
                    height: 20.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 16.0,
                    color: Colors.grey[300]!,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Details...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
