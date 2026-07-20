import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'modelos_sincronizacion_sage_automatica.dart';

class PantallaSincronizacionSageAutomatica extends StatefulWidget {
  const PantallaSincronizacionSageAutomatica({
    super.key,
    required this.estado,
    required this.loginDisponible,
    required this.procesandoCredenciales,
    required this.onIngresar,
    required this.onReintentar,
    required this.onCancelar,
  });

  final EstadoSincronizacionSageAutomatica estado;
  final bool loginDisponible;
  final bool procesandoCredenciales;
  final Future<void> Function(String usuario, String password) onIngresar;
  final VoidCallback? onReintentar;
  final VoidCallback onCancelar;

  @override
  State<PantallaSincronizacionSageAutomatica> createState() =>
      _PantallaSincronizacionSageAutomaticaState();
}

class _PantallaSincronizacionSageAutomaticaState
    extends State<PantallaSincronizacionSageAutomatica> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _puedeEnviarCredenciales =>
      !widget.procesandoCredenciales &&
      (widget.loginDisponible || widget.estado.solicitaCredenciales);

  Future<void> _submit() async {
    if (!_puedeEnviarCredenciales) return;
    if (_formKey.currentState?.validate() != true) return;
    TextInput.finishAutofillContext();
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text;
    await widget.onIngresar(usuario, password);
    if (mounted) _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.estado;
    final showLogin =
        state.solicitaCredenciales || (state.esError && widget.loginDisponible);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: showLogin
                        ? _buildLogin(context)
                        : _buildProgress(context),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 8,
              child: IconButton(
                tooltip: 'Cerrar',
                onPressed: widget.onCancelar,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogin(BuildContext context) {
    final state = widget.estado;
    final scheme = Theme.of(context).colorScheme;
    return AutofillGroup(
      key: const ValueKey('sage-auto-login'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  state.codigoError == CodigoErrorSincronizacionSage.sesionVencida
                      ? 'Volver a conectar '
                      : 'Conectar con ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Image.asset(
                    'assets/sage_banner.png',
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Text(
                      'SAGE',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.detalle?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _MensajeErrorSage(
                mensaje: state.detalle!,
                codigo: state.codigoVisible,
              ),
            ],
            const SizedBox(height: 22),
            TextFormField(
              controller: _usuarioController,
              enabled: !widget.procesandoCredenciales,
              autofocus: true,
              autofillHints: const [AutofillHints.username],
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'DNI o usuario',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingresá tu usuario.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              enabled: !widget.procesandoCredenciales,
              obscureText: _ocultarPassword,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _ocultarPassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  onPressed: widget.procesandoCredenciales
                      ? null
                      : () => setState(
                          () => _ocultarPassword = !_ocultarPassword,
                        ),
                  icon: Icon(
                    _ocultarPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Ingresá tu contraseña.'
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _puedeEnviarCredenciales ? _submit : null,
              icon: widget.procesandoCredenciales
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(
                widget.procesandoCredenciales
                    ? 'Iniciando sesión…'
                    : 'Iniciar y sincronizar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final state = widget.estado;
    final scheme = Theme.of(context).colorScheme;
    final completed = state.completada;
    final isError = state.esError;
    final retrying = state.reintentando;
    return KeyedSubtree(
      key: ValueKey('sage-auto-${state.etapa.name}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: completed
                    ? scheme.tertiaryContainer
                    : isError
                    ? scheme.errorContainer
                    : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                completed
                    ? Icons.check_rounded
                    : isError
                    ? Icons.error_outline_rounded
                    : retrying
                    ? Icons.refresh_rounded
                    : state.sesionReutilizada
                    ? Icons.lock_open_rounded
                    : Icons.sync_rounded,
                color: completed
                    ? scheme.onTertiaryContainer
                    : isError
                    ? scheme.onErrorContainer
                    : scheme.primary,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            state.titulo,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (state.detalle?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              state.detalle!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          if (state.sesionReutilizada || state.intentoActual > 0) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (state.sesionReutilizada)
                  const _EstadoChip(
                    icon: Icons.cookie_outlined,
                    label: 'Sesión reutilizada',
                  ),
                if (state.intentoActual > 0)
                  _EstadoChip(
                    icon: Icons.replay_rounded,
                    label:
                        'Intento ${state.intentoActual}/${state.intentosMaximos}',
                  ),
                if (state.codigoVisible != null)
                  _EstadoChip(
                    icon: Icons.tag_rounded,
                    label: state.codigoVisible!,
                  ),
              ],
            ),
          ],
          if (!completed && !isError) ...[
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: state.progreso?.clamp(0, 1).toDouble(),
              minHeight: 6,
              borderRadius: BorderRadius.circular(99),
            ),
          ],
          if (isError && state.permiteReintentar) ...[
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: widget.onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar este paso'),
            ),
          ],
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _MensajeErrorSage extends StatelessWidget {
  const _MensajeErrorSage({required this.mensaje, this.codigo});

  final String mensaje;
  final String? codigo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensaje,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
                if (codigo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    codigo!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
