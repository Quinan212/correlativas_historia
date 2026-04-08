import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/config/feature_flags.dart';
import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../models/situated_assistant_models.dart';
import '../providers/situated_assistant_providers.dart';

class SituatedAssistantScreen extends ConsumerStatefulWidget {
  const SituatedAssistantScreen({super.key});

  @override
  ConsumerState<SituatedAssistantScreen> createState() =>
      _SituatedAssistantScreenState();
}

class _SituatedAssistantScreenState
    extends ConsumerState<SituatedAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage.assistant(
      'Hola. Soy la IA situada. Preguntame directamente y yo me encargo de ubicar carrera, materia y condiciones con base en Steiman y los textos de la app (sin FAQ).',
    ),
  ];

  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!FeatureFlags.situatedAssistantEnabled) return;
    final question = _controller.text.trim();
    if (question.isEmpty || _loading) return;

    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      setState(() {
        _messages.add(
          const _ChatMessage.assistant(
            'La IA no esta disponible en este build. Revisa la configuracion de Supabase.',
            isError: true,
          ),
        );
      });
      _scrollToEnd();
      return;
    }

    setState(() {
      _messages.add(_ChatMessage.user(question));
      _loading = true;
    });
    _controller.clear();
    _scrollToEnd();

    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repo = ref.read(situatedAssistantRepositoryProvider);
      final response = await repo.ask(
        client: client,
        question: question,
        contextType: 'uso_app',
        contextId: '',
        deviceId: deviceId,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage.assistant(_answerFrom(response)));
        if (response.sources.isNotEmpty) {
          _messages.add(
            _ChatMessage.sources(response.sources),
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      final detail = error.toString().trim();
      setState(() {
        _messages.add(
          _ChatMessage.assistant(
            detail.isEmpty
                ? 'No pude responder ahora. Intenta de nuevo en unos segundos.'
                : 'No pude responder ahora. $detail',
            isError: true,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _scrollToEnd();
      }
    }
  }

  String _answerFrom(SituatedAssistantResponse response) {
    if (response.isNoEvidence) {
      return 'No encuentro respaldo suficiente en Steiman o en los textos de la app para responder eso con precision.';
    }
    return response.answer.trim().isEmpty
        ? 'No pude construir una respuesta clara con esa consulta.'
        : response.answer.trim();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canUseIa = FeatureFlags.situatedAssistantEnabled &&
        ref.watch(supabaseClientProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IA Situada'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!canUseIa)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'La IA esta pausada temporalmente en este build.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _ChatBubble(message: message);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Escribí tu pregunta...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: (_loading || !canUseIa) ? null : _send,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final align = message.role == _ChatRole.user
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = switch (message.role) {
      _ChatRole.user => theme.colorScheme.primaryContainer,
      _ChatRole.assistant => message.isError
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.surfaceContainerHighest,
      _ChatRole.sources => theme.colorScheme.surfaceContainerHigh,
    };
    final textColor = switch (message.role) {
      _ChatRole.user => theme.colorScheme.onPrimaryContainer,
      _ChatRole.assistant => message.isError
          ? theme.colorScheme.onErrorContainer
          : theme.colorScheme.onSurfaceVariant,
      _ChatRole.sources => theme.colorScheme.onSurfaceVariant,
    };

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: message.role == _ChatRole.sources
              ? _SourcesBlock(sources: message.sources)
              : Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                ),
        ),
      ],
    );
  }
}

class _SourcesBlock extends StatelessWidget {
  const _SourcesBlock({required this.sources});

  final List<SituatedAssistantSource> sources;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fuentes',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        ...sources.map(
          (source) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Fuente: ${source.title}, ${source.reference}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

enum _ChatRole { user, assistant, sources }

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    this.text = '',
    this.sources = const [],
    this.isError = false,
  });

  const _ChatMessage.user(String text)
      : this(role: _ChatRole.user, text: text);

  const _ChatMessage.assistant(String text, {bool isError = false})
      : this(role: _ChatRole.assistant, text: text, isError: isError);

  const _ChatMessage.sources(List<SituatedAssistantSource> sources)
      : this(role: _ChatRole.sources, sources: sources);

  final _ChatRole role;
  final String text;
  final List<SituatedAssistantSource> sources;
  final bool isError;
}
