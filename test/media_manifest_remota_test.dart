import 'dart:convert';
import 'dart:io';

import 'package:correlativas_historia/compartido/media/cache_media_remota.dart';
import 'package:correlativas_historia/compartido/media/modelos_media_remota.dart';
import 'package:correlativas_historia/compartido/supabase/supabase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valida y encuentra entradas del manifiesto remoto', () {
    final manifest = MediaManifest.fromJson(
      jsonDecode('''
{
  "schemaVersion": 1,
  "contentVersion": "test",
  "generatedAt": "2026-07-12T00:00:00Z",
  "assets": {
    "trayectorias.01": {
      "type": "image",
      "path": "trayectorias/01-aaaaaaaaaa.jpg",
      "sha256": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "size": 12,
      "preloadPriority": 2,
      "source": "banners/historia/recorrido/01.jpg"
    }
  }
}
''')
          as Map<String, dynamic>,
    );

    expect(manifest.schemaVersion, 1);
    const expectedPath = 'trayectorias/01-aaaaaaaaaa.jpg';
    const sources = [
      'banners/historia/recorrido/01.jpg',
      'assets/banners/historia/recorrido/01.jpg',
      r'assets\banners\historia\recorrido\01.jpg',
      './assets/banners/historia/recorrido/01.jpg',
    ];

    for (final source in sources) {
      expect(manifest.findBySource(source)?.path, expectedPath);
    }

    final representativeManifest = MediaManifest.fromJson(
      jsonDecode('''
{
  "schemaVersion": 1,
  "contentVersion": "test",
  "generatedAt": "2026-07-12T00:00:00Z",
  "assets": {
    "trayectoria": {
      "type": "image",
      "path": "trayectorias/antiguedad-aaaaaaaaaa.webp",
      "sha256": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "size": 12,
      "preloadPriority": 2,
      "source": "banners/historia/1/antiguedad.webp"
    },
    "video": {
      "type": "video",
      "path": "videos/historia-overlay-aaaaaaaaaa.mp4",
      "sha256": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      "size": 12,
      "preloadPriority": 2,
      "source": "career_icons/historia_overlay_banner.mp4"
    }
  }
}
''')
          as Map<String, dynamic>,
    );

    expect(
      representativeManifest
          .findBySource('assets/banners/historia/1/antiguedad.webp')
          ?.path,
      'trayectorias/antiguedad-aaaaaaaaaa.webp',
    );
    expect(
      representativeManifest
          .findBySource('assets/career_icons/historia_overlay_banner.mp4')
          ?.path,
      'videos/historia-overlay-aaaaaaaaaa.mp4',
    );
    expect(
      representativeManifest.findBySource('assets/inexistente.webp'),
      isNull,
    );
  });

  test('separa variantes de precarga y recursos mínimos de promoción', () {
    final entries = <MediaManifestEntry>[
      _entry('banners/historia/recorrido/01.jpg', 'image'),
      _entry('career_icons/historia_overlay_banner.mp4', 'video'),
      _entry('banners/historia/1/antiguedad.webp', 'image'),
      _entry('banners/historia/1/antiguedad_ancho.webp', 'image'),
    ];

    expect(entries.where(debePrecargarMedia), hasLength(3));
    expect(entries.where(esMediaPrioritariaParaPromocion), hasLength(3));
    expect(debePrecargarMedia(entries.last), isFalse);
  });

  test(
    'el manifiesto pendiente no reemplaza al activo antes de promoverlo',
    () async {
      final root = await Directory.systemTemp.createTemp('media-cache-test-');
      addTearDown(() => root.delete(recursive: true));
      final cache = CacheMediaRemota.withRootDirectory(rootDirectory: root);
      const active =
          '{"schemaVersion":1,"contentVersion":"active",'
          '"generatedAt":"2026-07-12T00:00:00Z","assets":{}}';
      const pending =
          '{"schemaVersion":1,"contentVersion":"pending",'
          '"generatedAt":"2026-07-12T00:00:00Z","assets":{}}';

      await cache.writeManifestAtomically(active);
      await cache.writePendingManifestAtomically(pending);

      expect(await cache.readCachedManifest(), active);
      expect(
        await cache.pendingManifestFile().then((file) => file.exists()),
        isTrue,
      );

      await cache.promotePendingManifest();

      expect(await cache.readCachedManifest(), pending);
    },
  );

  test('un manifiesto inválido no se puede interpretar como activo', () {
    expect(
      () => MediaManifest.fromJson(<String, dynamic>{
        'schemaVersion': 1,
        'contentVersion': 'invalid',
        'generatedAt': '2026-07-12T00:00:00Z',
        'assets': {
          'broken': {
            'type': 'image',
            'path': 'broken.webp',
            'sha256': 'not-a-sha',
            'size': 12,
            'preloadPriority': 1,
            'source': 'banners/broken.webp',
          },
        },
      }),
      throwsFormatException,
    );
  });

  test('prioriza la clave publishable moderna y conserva el fallback', () {
    expect(
      SupabaseConfig.resolveClientKey(
        publishable: '  sb_publishable_test  ',
        anon: 'legacy-anon',
      ),
      'sb_publishable_test',
    );
    expect(
      SupabaseConfig.resolveClientKey(publishable: ' ', anon: 'legacy-anon'),
      'legacy-anon',
    );
  });
}

MediaManifestEntry _entry(String source, String type) {
  return MediaManifestEntry(
    type: type,
    path: 'test/${source.split('/').last}',
    sha256: 'a' * 64,
    size: 12,
    preloadPriority: 1,
    source: source,
  );
}
