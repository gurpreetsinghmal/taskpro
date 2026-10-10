import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const int maxSowImageBytes = 150 * 1024;

Uint8List compressSowImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('The selected file is not a supported image.');
  }

  var image = img.bakeOrientation(decoded);
  if (image.hasAlpha) {
    final background = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 3,
    );
    img.fill(background, color: img.ColorRgb8(255, 255, 255));
    image = img.compositeImage(background, image);
  }

  while (true) {
    for (var quality = 85; quality >= 25; quality -= 10) {
      final encoded = img.encodeJpg(image, quality: quality);
      if (encoded.lengthInBytes <= maxSowImageBytes) {
        return encoded;
      }
    }

    if (image.width <= 160 && image.height <= 160) {
      throw StateError('Unable to compress the selected image below 150 KB.');
    }

    final scale = math.min(
      0.8,
      math.sqrt(maxSowImageBytes / img.encodeJpg(image, quality: 25).length),
    );
    final widthIsLongest = image.width >= image.height;
    final nextLongestEdge = math.max(
      1,
      ((widthIsLongest ? image.width : image.height) * scale).floor(),
    );
    if (nextLongestEdge >= (widthIsLongest ? image.width : image.height)) {
      throw StateError('Unable to compress the selected image below 150 KB.');
    }
    image = img.copyResize(
      image,
      width: widthIsLongest ? nextLongestEdge : null,
      height: widthIsLongest ? null : nextLongestEdge,
      interpolation: img.Interpolation.linear,
    );
  }
}
