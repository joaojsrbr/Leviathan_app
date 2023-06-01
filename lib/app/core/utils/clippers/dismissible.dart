import 'package:flutter/material.dart';

class DismissibleClipper extends CustomClipper<RRect> {
  DismissibleClipper({
    required this.axis,
    required this.moveAnimation,
    required this.radius,
  }) : super(reclip: moveAnimation);

  final Axis axis;
  final Animation<Offset> moveAnimation;
  final double radius;

  @override
  RRect getClip(Size size) {
    switch (axis) {
      case Axis.horizontal:
        final double offset = moveAnimation.value.dx * size.width;
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
        final double offset = moveAnimation.value.dy * size.height;
        if (offset < 0) {
          return RRect.fromLTRBR(0.0, size.height + offset, size.width, size.height, Radius.circular(radius));
        }
        return RRect.fromLTRBR(0.0, 0.0, size.width, offset, Radius.circular(radius));
    }
  }

  RRect getApproximateClipRRect(Size size) => getClip(size);

  @override
  bool shouldReclip(DismissibleClipper oldClipper) {
    return oldClipper.axis != axis || oldClipper.moveAnimation.value != moveAnimation.value;
  }
}
