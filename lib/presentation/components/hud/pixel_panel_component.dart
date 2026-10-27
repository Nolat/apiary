// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/pixel_paint.dart';

/// A 9-slice box (panel, frame, button) drawn nearest-neighbor: the stock
/// [NineTileBoxComponent] smooths what it stretches, which blurs the edges of
/// the sprite at fractional scales. Pixel art goes through this one (see
/// "Présentation Flame" in `docs/CONVENTIONS.md`).
class PixelPanelComponent extends NineTileBoxComponent {
  PixelPanelComponent({super.nineTileBox, super.position, super.size}) {
    paint = pixelPaint();
  }
}
