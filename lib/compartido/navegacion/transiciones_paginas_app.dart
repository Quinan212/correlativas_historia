import 'package:flutter/material.dart';

PageTransitionsTheme buildAppPageTransitionsTheme() {
  const builder = _HorizontalPageTransitionsBuilder();
  return const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: builder,
      TargetPlatform.iOS: builder,
      TargetPlatform.macOS: builder,
      TargetPlatform.windows: builder,
      TargetPlatform.linux: builder,
      TargetPlatform.fuchsia: builder,
    },
  );
}

class _HorizontalPageTransitionsBuilder extends PageTransitionsBuilder {
  const _HorizontalPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}
