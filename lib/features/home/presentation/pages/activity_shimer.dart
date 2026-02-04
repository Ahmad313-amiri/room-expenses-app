import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ActivityShimmerLoading extends StatelessWidget {
  const ActivityShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _shimmerBox(width: 80, height: 20),
        const SizedBox(height: 16),
        _settlementCard(),
        const SizedBox(height: 16),
        _activityTile(),
        _activityTile(),
        const SizedBox(height: 24),
        _shimmerBox(width: 100, height: 20),
        const SizedBox(height: 16),
        _activityTile(),
      ],
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _settlementCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(width: 160, height: 16),
          const SizedBox(height: 8),
          _shimmerBox(width: 120, height: 12),
          const SizedBox(height: 16),
          _shimmerBox(width: double.infinity, height: 44, radius: 12),
        ],
      ),
    );
  }

  Widget _activityTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _shimmerBox(width: 48, height: 48, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 180, height: 14),
                const SizedBox(height: 8),
                _shimmerBox(width: 120, height: 12),
              ],
            ),
          ),
          _shimmerBox(width: 40, height: 12),
        ],
      ),
    );
  }
}
