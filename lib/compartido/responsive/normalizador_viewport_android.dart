import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Evita que el zoom de pantalla extremo de Android reduzca el ancho lógico
/// hasta romper interfaces diseñadas para teléfonos modernos.
///
/// En teléfonos Android con menos de 360 dp de ancho disponible, la app se
/// construye sobre un viewport virtual de 360 dp y se escala uniformemente al
/// ancho real. No interviene en tablets, escritorio, web ni teléfonos con un
/// ancho lógico normal.
class NormalizadorViewportAndroid extends StatelessWidget {
  const NormalizadorViewportAndroid({
    super.key,
    required this.child,
    this.anchoMinimoTelefono = 360,
  });

  final Widget child;
  final double anchoMinimoTelefono;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    final aplica = !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        size.shortestSide < 600 &&
        size.width > 0 &&
        size.width < anchoMinimoTelefono;

    if (!aplica) return child;

    final scale = size.width / anchoMinimoTelefono;
    final virtualSize = Size(anchoMinimoTelefono, size.height / scale);
    final virtualMedia = media.copyWith(
      size: virtualSize,
      padding: _dividir(media.padding, scale),
      viewPadding: _dividir(media.viewPadding, scale),
      viewInsets: _dividir(media.viewInsets, scale),
      systemGestureInsets: _dividir(media.systemGestureInsets, scale),
    );

    return SizedBox.expand(
      child: ClipRect(
        child: Align(
          alignment: Alignment.topLeft,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: virtualSize.width,
              height: virtualSize.height,
              child: MediaQuery(data: virtualMedia, child: child),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _dividir(EdgeInsets value, double scale) {
    return EdgeInsets.fromLTRB(
      value.left / scale,
      value.top / scale,
      value.right / scale,
      value.bottom / scale,
    );
  }
}
