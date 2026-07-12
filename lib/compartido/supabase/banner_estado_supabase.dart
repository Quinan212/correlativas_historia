import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'proveedores_supabase.dart';
import 'supabase_bootstrap.dart';

class BannerEstadoSupabase extends ConsumerWidget {
  const BannerEstadoSupabase({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(proveedorArranqueSupabase);

    if (bootstrap.status == EstadoArranqueSupabase.ready) {
      return const SizedBox.shrink();
    }

    final bg = bootstrap.status == EstadoArranqueSupabase.failed
        ? const Color(0xFF7F1D1D)
        : const Color(0xFF7C2D12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: bg,
      child: Text(
        bootstrap.message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}
