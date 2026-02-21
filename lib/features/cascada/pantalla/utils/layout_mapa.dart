import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

class LayoutMapa {
  static bool isWindowsDesktop() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static Widget pageContainer(
      BuildContext context, {
        required double maxW,
        required Widget child,
      }) {
    final w = MediaQuery.of(context).size.width;
    final double finalW = w < maxW ? w : maxW;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: finalW),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: child,
        ),
      ),
    );
  }

  static Widget columnsContainer(
      BuildContext context, {
        required double maxWGeneral,
        required double colsFactor,
        required double colsSidePadding,
        required Widget child,
      }) {
    final w = MediaQuery.of(context).size.width;
    final byFactor = maxWGeneral * colsFactor;
    final byScreen =
    (w - (colsSidePadding * 2)).clamp(0.0, double.infinity);
    final maxW = math.min(byFactor, byScreen);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: colsSidePadding),
          child: child,
        ),
      ),
    );
  }
}