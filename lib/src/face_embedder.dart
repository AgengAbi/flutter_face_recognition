import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbedder {
  static const String _modelAsset =
      'packages/flutter_face_recognition/assets/edgeface_xs_gamma_06_fp16.tflite';
  static const int inputSize = 112;
  static const int embeddingSize = 512;

  Interpreter? _interpreter;

  Future<void> initialize() async {
    final options = InterpreterOptions()..threads = 2;
    _interpreter = await Interpreter.fromAsset(_modelAsset, options: options);
  }

  /// Extracts a 512-dim L2-normalized embedding from a 112×112 face crop.
  /// [croppedFace] must be resized to 112×112 before calling.
  Future<Float32List> extractEmbedding(img.Image croppedFace) async {
    assert(_interpreter != null, 'Call initialize() first');
    assert(
      croppedFace.width == inputSize && croppedFace.height == inputSize,
      'Input must be 112×112',
    );

    final input = _preprocessImage(croppedFace);
    final output = List.filled(embeddingSize, 0.0).reshape([1, embeddingSize]);
    _interpreter!.run(input.reshape([1, inputSize, inputSize, 3]), output);

    final embedding =
        Float32List.fromList((output[0] as List).cast<double>());
    return _l2Normalize(embedding);
  }

  /// Normalizes pixels to [-1, 1]: (pixel - 127.5) / 128.0
  Float32List _preprocessImage(img.Image image) {
    final pixels = Float32List(inputSize * inputSize * 3);
    int idx = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        pixels[idx++] = (pixel.r.toDouble() - 127.5) / 128.0;
        pixels[idx++] = (pixel.g.toDouble() - 127.5) / 128.0;
        pixels[idx++] = (pixel.b.toDouble() - 127.5) / 128.0;
      }
    }
    return pixels;
  }

  Float32List _l2Normalize(Float32List v) {
    double norm = 0.0;
    for (final x in v) {
      norm += x * x;
    }
    norm = sqrt(norm);
    if (norm == 0) return v;
    return Float32List.fromList(v.map((x) => x / norm).toList());
  }

  void dispose() => _interpreter?.close();
}
