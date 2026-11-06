import 'package:flutter/material.dart';

/// True when the screen is wider than it is tall.
bool isLandscapeOf(BuildContext context) {
  return MediaQuery.orientationOf(context) == Orientation.landscape;
}

/// Picks the number of grid columns for the current orientation.
int gridColumnsOf(
  BuildContext context, {
  required int portrait,
  required int landscape,
}) {
  return isLandscapeOf(context) ? landscape : portrait;
}

/// Centers its child and stops it from growing wider than maxWidth.
class AppContentWidth extends StatelessWidget {
  const AppContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 640,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Centers its child and scrolls when the space is too small.
class AppScrollableCenter extends StatelessWidget {
  const AppScrollableCenter({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

/// Clips an image to rounded corners with a fixed aspect ratio.
class ResponsiveImageCard extends StatelessWidget {
  const ResponsiveImageCard({
    super.key,
    required this.child,
    this.aspectRatio = 16 / 9,
    this.radius = 16,
  });

  final Widget child;
  final double aspectRatio;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(aspectRatio: aspectRatio, child: child),
    );
  }
}
