import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/configuracion/banderas_funcionalidad.dart';
import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/supabase/supabase.dart';
import '../modelos/modelos_asistente_contextual.dart';
import '../proveedores/proveedores_asistente_contextual.dart';

class AsistenteContextualPantalla extends ConsumerStatefulWidget {
  const AsistenteContextualPantalla({super.key});

  @override
  ConsumerState<AsistenteContextualPantalla> createState() =>
      _AsistenteContextualPantallaState();
}

class _AsistenteContextualPantallaState
    extends ConsumerState<AsistenteContextualPantalla> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_MensajeChat> _messages = [
    const _MensajeChat.assistant(
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
    if (!BanderasFuncionalidad.asistenteContextualHabilitado) return;
    final question = _controller.text.trim();
    if (question.isEmpty || _loading) return;

    final client = ref.read(proveedorClienteSupabase);
    if (client == null) {
      setState(() {
        _messages.add(
          const _MensajeChat.assistant(
            'La IA no esta disponible en este build. Revisa la configuracion de Supabase.',
            isError: true,
          ),
        );
      });
      _scrollToEnd();
      return;
    }

    setState(() {
      _messages.add(_MensajeChat.user(question));
      _loading = true;
    });
    _controller.clear();
    _scrollToEnd();

    try {
      final deviceId = await ref.read(proveedorIdDispositivo.future);
      final repo = ref.read(proveedorRepositorioAsistenteContextual);
      final response = await repo.ask(
        client: client,
        question: question,
        contextType: 'uso_app',
        contextId: '',
        deviceId: deviceId,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(_MensajeChat.assistant(_answerFrom(response)));
        if (response.sources.isNotEmpty) {
          _messages.add(
            _MensajeChat.sources(response.sources),
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      final detail = error.toString().trim();
      setState(() {
        _messages.add(
          _MensajeChat.assistant(
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

  String _answerFrom(RespuestaAsistenteContextual response) {
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
    final canUseIa = BanderasFuncionalidad.asistenteContextualHabilitado &&
        ref.watch(proveedorClienteSupabase) != null;

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
                  return _BurbujaChat(message: message);
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

class _BurbujaChat extends StatelessWidget {
  const _BurbujaChat({required this.message});

  final _MensajeChat message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final align = message.role == _RolChat.user
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = switch (message.role) {
      _RolChat.user => theme.colorScheme.primaryContainer,
      _RolChat.assistant => message.isError
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.surfaceContainerHighest,
      _RolChat.sources => theme.colorScheme.surfaceContainerHigh,
    };
    final textColor = switch (message.role) {
      _RolChat.user => theme.colorScheme.onPrimaryContainer,
      _RolChat.assistant => message.isError
          ? theme.colorScheme.onErrorContainer
          : theme.colorScheme.onSurfaceVariant,
      _RolChat.sources => theme.colorScheme.onSurfaceVariant,
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
          child: message.role == _RolChat.sources
              ? _BloqueFuentes(sources: message.sources)
              : Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                ),
        ),
      ],
    );
  }
}

class _BloqueFuentes extends StatelessWidget {
  const _BloqueFuentes({required this.sources});

  final List<FuenteAsistenteContextual> sources;

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

enum _RolChat { user, assistant, sources }

class _MensajeChat {
  const _MensajeChat({
    required this.role,
    this.text = '',
    this.sources = const [],
    this.isError = false,
  });

  const _MensajeChat.user(String text) : this(role: _RolChat.user, text: text);

  const _MensajeChat.assistant(String text, {bool isError = false})
      : this(role: _RolChat.assistant, text: text, isError: isError);

  const _MensajeChat.sources(List<FuenteAsistenteContextual> sources)
      : this(role: _RolChat.sources, sources: sources);

  final _RolChat role;
  final String text;
  final List<FuenteAsistenteContextual> sources;
  final bool isError;
}
