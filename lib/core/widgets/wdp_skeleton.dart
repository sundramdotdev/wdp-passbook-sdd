import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radii.dart';

/// Shimmering / pulsing placeholder skeleton widget for loading states.
class WdpSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const WdpSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  const WdpSkeleton.round({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(9999));

  @override
  State<WdpSkeleton> createState() => _WdpSkeletonState();
}

class _WdpSkeletonState extends State<WdpSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.navyElevated : AppColors.lightSurfaceSoft;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: widget.borderRadius ?? AppRadii.compactRadius,
            ),
          ),
        );
      },
    );
  }
}
