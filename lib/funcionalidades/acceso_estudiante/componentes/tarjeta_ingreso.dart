import 'package:flutter/material.dart';

class TarjetaIngreso extends StatelessWidget {
  const TarjetaIngreso({
    required this.cargando,
    required this.error,
    required this.controladorCorreo,
    required this.controladorContrasena,
    required this.alIniciar,
    required this.alInvitado,
  });

  final bool cargando;
  final String? error;
  final TextEditingController controladorCorreo;
  final TextEditingController controladorContrasena;
  final Future<void> Function() alIniciar;
  final VoidCallback alInvitado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TarjetaVidrio(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acceso al perfil',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usá tu correo y contraseña para entrar al perfil del alumno.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxWidth < 420;
              final campoCorreo = TextField(
                controller: controladorCorreo,
                enabled: !cargando,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
              );
              final campoContrasena = TextField(
                controller: controladorContrasena,
                enabled: !cargando,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              );

              if (compacto) {
                return Column(
                  children: [
                    campoCorreo,
                    const SizedBox(height: 12),
                    campoContrasena,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: campoCorreo),
                  const SizedBox(width: 12),
                  Expanded(child: campoContrasena),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: cargando ? null : alIniciar,
              icon: const Icon(Icons.login_rounded),
              label: Text(cargando ? 'Ingresando...' : 'Entrar'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: cargando ? null : alInvitado,
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Ingresar como Invitado'),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TarjetaVidrio extends StatelessWidget {
  const TarjetaVidrio({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final oscuro = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: oscuro ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: oscuro ? cs.outlineVariant : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: oscuro ? 0.12 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
