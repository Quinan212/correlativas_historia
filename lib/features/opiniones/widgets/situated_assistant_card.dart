import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../models/situated_assistant_models.dart';
import '../providers/situated_assistant_providers.dart';

class SituatedAssistantCard extends ConsumerStatefulWidget {
  const SituatedAssistantCard({
    super.key,
    required this.matterId,
  });

  final String matterId;

  @override
  ConsumerState<SituatedAssistantCard> createState() =>
      _SituatedAssistantCardState();
}

class _SituatedAssistantCardState extends ConsumerState<SituatedAssistantCard> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  SituatedAssistantResponse? _response;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _loading) return;

    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      setState(() {
        _error = 'El asistente no esta disponible en este momento.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repo = ref.read(situatedAssistantRepositoryProvider);
      final response = await repo.ask(
        client: client,
        question: question,
        contextType: 'materia',
        contextId: widget.matterId,
        deviceId: deviceId,
      );
      if (!mounted) return;
      setState(() {
        _response = response;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo obtener respuesta: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = ref.watch(supabaseClientProvider) != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF0B1220)
            : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asistente situado',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Responde con base en Steiman y textos de la app (sin FAQ).',
            style: theme.textTheme.bodySmall,
          ),
          if (!isAvailable) ...[
            const SizedBox(height: 8),
            Text(
              'La IA no esta disponible en este build. Verifica la configuracion de Supabase.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText:
                  'Ej: Como puedo compartir una imagen de cursada en esta materia?',
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: IconButton(
                onPressed: (_loading || !isAvailable) ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_loading || !isAvailable) ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.smart_toy_outlined),
              label: const Text('Preguntar a la IA'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (_response != null) ...[
            const SizedBox(height: 12),
            _AssistantResponseView(response: _response!),
          ],
        ],
      ),
    );
  }
}

class _AssistantResponseView extends StatelessWidget {
  const _AssistantResponseView({required this.response});

  final SituatedAssistantResponse response;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final answer = response.isNoEvidence
        ? 'No encuentro respaldo suficiente en Steiman o en los textos de la app para responder eso con precision.'
        : response.answer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          answer,
          style: theme.textTheme.bodyMedium,
        ),
        if (response.sources.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Fuentes',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          ...response.sources.map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Fuente: ${source.title}, ${source.reference}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
