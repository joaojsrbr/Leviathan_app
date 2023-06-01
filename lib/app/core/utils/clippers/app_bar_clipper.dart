import 'package:flutter/material.dart';

class AppBarClipper extends CustomClipper<RRect> {
  AppBarClipper({
    this.axis = Axis.vertical,
    this.topLeft = Radius.zero,
    this.topRight = Radius.zero,
    required this.radius,
  });

  final Axis axis;
  final double radius;
  final Radius topLeft;
  final Radius topRight;

  @override
  RRect getClip(Size size) {
    switch (axis) {
      case Axis.horizontal:
        final double offset = size.width;
        if (offset < 0) {
          return RRect.fromLTRBAndCorners(
            size.width + offset,
            0.0,
            size.width,
            size.height,
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
        }
        return RRect.fromLTRBAndCorners(
          0.0,
          0.0,
          offset,
          size.height,
          topRight: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
      case Axis.vertical:
        final double offset = size.height;
        if (offset <= 0) {
          return RRect.fromLTRBAndCorners(
            0.0,
            size.height + offset,
            size.width,
            size.height,
            bottomRight: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
            topLeft: topLeft,
            topRight: topRight,
          );
        }
        return RRect.fromLTRBAndCorners(
          0.0,
          0.0,
          size.width,
          offset,
          bottomRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          topLeft: topLeft,
          topRight: topRight,
        );
    }
  }

  RRect getApproximateClipRRect(Size size) => getClip(size);

  @override
  bool shouldReclip(AppBarClipper oldClipper) {
    return oldClipper.axis != axis;
  }
}
