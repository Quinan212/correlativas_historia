import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_state.dart';
import 'providers/examenes_providers.dart';
import 'providers/plan_providers.dart';
import 'pantalla/pantalla_examenes.dart';

class ExamenesScreen extends StatelessWidget {
  const ExamenesScreen({super.key});

  @override
  Widget build(BuildContext context) => const PantallaExamenes();
}

String resolveExamenesCareerId(String careerId) {
  switch (careerId) {
    case 'historia':
    case 'geografia':
    case 'politica':
      return careerId;
    default:
      return 'historia';
  }
}

void prewarmExamenesData(WidgetRef ref, {String? careerId}) {
  final resolvedCareerId = resolveExamenesCareerId(
    careerId ?? ref.read(selectedCareerInfoProvider).id,
  );

  ref.read(examenesCareerIdProvider.notifier).state = resolvedCareerId;
  unawaited(ref.read(examenesAllProvider.future));
  unawaited(ref.read(planMapaMateriasProvider(resolvedCareerId).future));
}

Route<void> buildExamenesRoute() {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (_, animation, __) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: const ExamenesScreen(),
      );
    },
  );
}
