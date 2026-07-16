import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/rendimiento/rendimiento_app.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../../modelos/materia.dart';
import '../../administrador/proveedores/proveedores_acceso_administrador.dart';
import '../../verificacion/modelos/estado_verificacion_materia.dart';
import '../../verificacion/modelos/imagen_subida_verificacion.dart';
import '../../verificacion/pantallas/editor_imagen_verificacion_pantalla.dart';
import '../modelos/publicacion_foto_materia.dart';
import '../proveedores/proveedores_resenas_opiniones.dart';

class GaleriaFotosMateria extends ConsumerStatefulWidget {
  static const double _tileWidth = 210;
  static const double _tileHeight = 320;
  const GaleriaFotosMateria({
    super.key,
    required this.matter,
    required this.careerId,
    required this.verification,
    required this.photoPosts,
  });

  final Materia matter;
  final String careerId;
  final EstadoVerificacionMateria verification;
  final List<PublicacionFotoMateria> photoPosts;

  @override
  ConsumerState<GaleriaFotosMateria> createState() =>
      _GaleriaFotosMateriaState();
}

class _GaleriaFotosMateriaState extends ConsumerState<GaleriaFotosMateria> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant GaleriaFotosMateria oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoPosts.length != widget.photoPosts.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escenas de cursada',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: GaleriaFotosMateria._tileHeight,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount:
                widget.photoPosts.isEmpty ? 1 : widget.photoPosts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return TarjetaAgregarFotoMateria(
                  width: GaleriaFotosMateria._tileWidth,
                  height: GaleriaFotosMateria._tileHeight,
                  enabled: true,
                  onTap: () => _manejarAgregarFoto(context),
                );
              }

              final post = widget.photoPosts[index - 1];
              return MosaicoFotoMateria(
                width: GaleriaFotosMateria._tileWidth,
                height: GaleriaFotosMateria._tileHeight,
                post: post,
                posts: widget.photoPosts,
                initialIndex: index - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _manejarAgregarFoto(BuildContext context) async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;

    final repo = ref.read(proveedorRepositorioResenasOpiniones);
    final sourceImage = await repo.seleccionarFotoMateria();
    if (sourceImage == null || !context.mounted) return;

    final editedImage =
        await Navigator.of(context).push<ImagenSubidaVerificacion>(
      MaterialPageRoute<ImagenSubidaVerificacion>(
        builder: (_) =>
            EditorImagenVerificacionPantalla(sourceImage: sourceImage),
      ),
    );
    if (editedImage == null || !context.mounted) return;

    final captionController = TextEditingController();
    final caption = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sumar imagen de cursada'),
        content: TextField(
          controller: captionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText:
                'Si querés, agregá una frase breve sobre la escena, el grupo o ese momento de cursada.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(captionController.text),
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
    captionController.dispose();
    if (caption == null || !context.mounted) return;

    final uploadTrace = await RendimientoApp.iniciarTraza(
      'matter_photo_upload',
      attributes: {
        'career_id': widget.careerId,
        'matter_id': widget.matter.id,
      },
    );
    var traceStopped = false;

    try {
      final deviceId = await ref.read(proveedorIdDispositivo.future);
      await repo.createPublicacionFotoMateria(
        client: client,
        deviceId: deviceId,
        matterId: widget.matter.id,
        careerId: widget.careerId,
        image: editedImage,
        caption: caption,
      );
      await RendimientoApp.detenerTraza(
        uploadTrace,
        metrics: {
          'success': 1,
          'caption_provided': caption.trim().isEmpty ? 0 : 1,
        },
      );
      traceStopped = true;
      ref.invalidate(proveedorPublicacionesFotoMateria(widget.matter.id));
      await ref
          .read(proveedorPublicacionesFotoMateria(widget.matter.id).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('La imagen se compartió en la comunidad de la materia.'),
          ),
        );
      }
    } catch (error) {
      if (!traceStopped) {
        await RendimientoApp.detenerTraza(
          uploadTrace,
          metrics: const {'success': 0},
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo compartir la imagen: $error'),
          ),
        );
      }
    }
  }
}

class TarjetaAgregarFotoMateria extends StatelessWidget {
  const TarjetaAgregarFotoMateria({
    super.key,
    required this.width,
    required this.height,
    required this.enabled,
    required this.onTap,
  });

  final double width;
  final double height;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MarcoFotoMateria(
      width: width,
      height: height,
      backgroundColor: const Color(0xFFEAF8FC),
      borderColor: const Color(0xFF8FD0E1),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 34,
              color:
                  enabled ? const Color(0xFF0B657A) : const Color(0xFF5E7F88),
            ),
            const SizedBox(height: 12),
            Text(
              enabled
                  ? 'Comparte algo de la cursada'
                  : 'Verifica la materia para sumar imágenes',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF0B657A),
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              enabled
                  ? 'Selfie, grupo o una escena simple de la materia.'
                  : 'Cuando la materia quede habilitada, desde aquí vas a poder sumar imágenes.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF255764),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MosaicoFotoMateria extends StatelessWidget {
  const MosaicoFotoMateria({
    super.key,
    required this.width,
    required this.height,
    required this.post,
    required this.posts,
    required this.initialIndex,
  });

  final double width;
  final double height;
  final PublicacionFotoMateria post;
  final List<PublicacionFotoMateria> posts;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (width * pixelRatio).round();
    return RepaintBoundary(
      child: MarcoFotoMateria(
        width: width,
        height: height,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        borderColor: theme.colorScheme.outlineVariant,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VistaPreviaFotoMateriaPantalla(
                posts: posts,
                initialIndex: initialIndex,
              ),
            ),
          );
        },
        child: ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            width: width,
            height: height,
            cacheWidth: cacheWidth,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, size: 34),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MarcoFotoMateria extends StatelessWidget {
  const MarcoFotoMateria({
    super.key,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    this.onTap,
  });

  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: ClipRRect(
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(22),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox.expand(child: child),
          ),
        ),
      ),
    );
  }
}

class VistaPreviaFotoMateriaPantalla extends StatelessWidget {
  const VistaPreviaFotoMateriaPantalla({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  final List<PublicacionFotoMateria> posts;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PaginadorVistaPreviaFotoMateria(
      posts: posts,
      initialIndex: initialIndex,
      theme: theme,
    );
  }
}

class PaginadorVistaPreviaFotoMateria extends ConsumerStatefulWidget {
  const PaginadorVistaPreviaFotoMateria({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.theme,
  });

  final List<PublicacionFotoMateria> posts;
  final int initialIndex;
  final ThemeData theme;

  @override
  ConsumerState<PaginadorVistaPreviaFotoMateria> createState() =>
      _PaginadorVistaPreviaFotoMateriaState();
}

class _PaginadorVistaPreviaFotoMateriaState
    extends ConsumerState<PaginadorVistaPreviaFotoMateria> {
  late final PageController _controller;
  late int _currentIndex;
  late List<PublicacionFotoMateria> _posts;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _posts = List<PublicacionFotoMateria>.from(widget.posts);
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPost = _posts[_currentIndex];
    final adminStatus =
        ref.watch(proveedorEstadoDispositivoAdministrador).value;
    final canModerate = adminStatus?.isAdmin == true;
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagen ${_currentIndex + 1} de ${_posts.length}'),
        actions: [
          if (canModerate)
            IconButton(
              tooltip: 'Quitar imagen',
              onPressed: () => _manejarEliminarFotoActual(
                context: context,
                adminDeviceId: adminStatus!.deviceId,
              ),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _posts.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final post = _posts[index];
                return FotoMateriaConZoom(imageUrl: post.imageUrl);
              },
            ),
          ),
          if ((currentPost.caption ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Text(
                currentPost.caption!.trim(),
                style: widget.theme.textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _manejarEliminarFotoActual({
    required BuildContext context,
    required String adminDeviceId,
  }) async {
    final currentPost = _posts[_currentIndex];
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Quitar imagen'),
            content: const Text(
              'Esta imagen dejara de verse en la comunidad de la materia. Puedes usar esta accion si el contenido no corresponde.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Quitar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete || !context.mounted) return;

    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;

    try {
      final repo = ref.read(proveedorRepositorioResenasOpiniones);
      await repo.deletePublicacionFotoMateria(
        client: client,
        adminDeviceId: adminDeviceId,
        photoId: currentPost.id,
      );
      ref.invalidate(proveedorPublicacionesFotoMateria(currentPost.matterId));

      if (_posts.length == 1) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La imagen fue retirada de la comunidad.'),
            ),
          );
        }
        return;
      }

      final updatedPosts = List<PublicacionFotoMateria>.from(_posts)
        ..removeAt(_currentIndex);
      final nextIndex = _currentIndex.clamp(0, updatedPosts.length - 1);

      setState(() {
        _posts = updatedPosts;
        _currentIndex = nextIndex;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpToPage(nextIndex);
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen fue retirada de la comunidad.'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo quitar la imagen: $error'),
          ),
        );
      }
    }
  }
}

class FotoMateriaConZoom extends StatefulWidget {
  const FotoMateriaConZoom({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  State<FotoMateriaConZoom> createState() => _FotoMateriaConZoomState();
}

class _FotoMateriaConZoomState extends State<FotoMateriaConZoom> {
  late final TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final details = _doubleTapDetails;
    if (details == null) return;

    final isIdentity = _transformationController.value.isIdentity();
    if (!isIdentity) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    const scale = 2.5;
    final position = details.localPosition;
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(
        -position.dx * (scale - 1),
        -position.dy * (scale - 1),
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (size.width * pixelRatio * 1.2).round();

    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        clipBehavior: Clip.none,
        minScale: 1,
        maxScale: 5,
        boundaryMargin: const EdgeInsets.all(32),
        child: Center(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            cacheWidth: cacheWidth,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
