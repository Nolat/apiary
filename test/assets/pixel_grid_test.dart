// 🎯 Dart imports:
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

/// Every sprite is drawn at ×1, one image pixel being one game pixel, so that
/// all the pixels of the screen have the same size and sit on the same grid
/// (see "Direction artistique" in `docs/DESIGN.md`). An asset exported
/// enlarged (each pixel a 2×2 or 3×3 block) or with soft, semi-transparent
/// edges would break it on screen.
void main() {
  final files =
      Directory('assets/images')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('finds the sprites to check', () {
    expect(files, isNotEmpty);
  });

  for (final file in files) {
    testWidgets('${file.path} is pixel art at ×1', (tester) async {
      await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(file.readAsBytesSync());
        final image = (await codec.getNextFrame()).image;
        final data = (await image.toByteData())!;
        final pixels = _Pixels(image.width, image.height, data);

        expect(
          pixels.semiTransparent,
          isEmpty,
          reason:
              'Soft edges: a pixel is either opaque or transparent, found '
              '${pixels.semiTransparent.take(3)}',
        );
        expect(
          pixels.enlargedBy,
          isNull,
          reason: 'Drawn at ×${pixels.enlargedBy}: export it at ×1',
        );
      });
    });
  }

  group('the checks', () {
    test('catch a sprite exported at ×2', () {
      final pixels = _Pixels.fromRows(const [
        '1122',
        '1122',
        '3344',
        '3344',
      ]);

      expect(pixels.enlargedBy, 2);
    });

    test('let a sprite with single pixels through', () {
      final pixels = _Pixels.fromRows(const [
        '1234',
        '1234',
        '3344',
        '3344',
      ]);

      expect(pixels.enlargedBy, isNull);
    });

    test('catch a semi-transparent pixel', () {
      final pixels = _Pixels.fromRows(const ['1234'], alphaOf: {'3': 128});

      expect(pixels.semiTransparent, hasLength(1));
    });
  });
}

class _Pixels {
  _Pixels(this.width, this.height, ByteData data)
    : _rgba = data.buffer.asUint8List();

  /// A tiny sprite for the checks themselves: one character is one color.
  factory _Pixels.fromRows(
    List<String> rows, {
    Map<String, int> alphaOf = const {},
  }) {
    final width = rows.first.length;
    final bytes = Uint8List(width * rows.length * 4);
    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < width; x++) {
        final char = rows[y][x];
        final i = (y * width + x) * 4;
        bytes
          ..[i] = char.codeUnitAt(0)
          ..[i + 3] = alphaOf[char] ?? 255;
      }
    }
    return _Pixels(width, rows.length, bytes.buffer.asByteData());
  }

  final int width;
  final int height;
  final Uint8List _rgba;

  int _at(int x, int y) {
    final i = (y * width + x) * 4;
    return (_rgba[i] << 24) |
        (_rgba[i + 1] << 16) |
        (_rgba[i + 2] << 8) |
        _rgba[i + 3];
  }

  /// The cells whose alpha is neither 0 nor 255.
  List<(int, int)> get semiTransparent => [
    for (var y = 0; y < height; y++)
      for (var x = 0; x < width; x++)
        if (_rgba[(y * width + x) * 4 + 3] case final alpha
            when alpha != 0 && alpha != 255)
          (x, y),
  ];

  /// The factor k ≥ 2 by which the sprite looks enlarged (every aligned k×k
  /// block is one color, on a sprite of at least two colors), or `null`.
  int? get enlargedBy {
    final colors = {
      for (var y = 0; y < height; y++)
        for (var x = 0; x < width; x++) _at(x, y),
    };
    if (colors.length < 2) {
      return null;
    }
    for (var k = 2; k <= 4; k++) {
      if (width % k != 0 || height % k != 0) {
        continue;
      }
      var uniform = true;
      for (var y = 0; y < height && uniform; y++) {
        for (var x = 0; x < width && uniform; x++) {
          uniform = _at(x, y) == _at(x - x % k, y - y % k);
        }
      }
      if (uniform) {
        return k;
      }
    }
    return null;
  }
}
