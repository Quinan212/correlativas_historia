import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../modelos/modelos_resenas_opiniones.dart';

class SeccionComentariosMateria extends ConsumerWidget {
  const SeccionComentariosMateria({super.key, required this.comments});

  final List<ReviewCommentSnippet> comments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final commentProfilesAsync = ref.watch(
      proveedorPerfilesDispositivoPorIds(
        serializeDeviceIds(comments.map((item) => item.deviceId)),
      ),
    );
    final commentProfiles =
        commentProfilesAsync.value ?? const <String, PerfilDispositivo>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: comments
          .map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commentProfiles[comment.deviceId]?.publicDisplayLabel ??
                        'Referencia anónima',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '"${comment.comment}"',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
