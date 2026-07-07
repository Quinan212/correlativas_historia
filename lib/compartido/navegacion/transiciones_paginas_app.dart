import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PageTransitionsTheme buildAppPageTransitionsTheme() {
  const PageTransitionsBuilder builder = CupertinoPageTransitionsBuilder();
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
