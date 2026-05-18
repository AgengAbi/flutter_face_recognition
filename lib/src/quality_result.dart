// lib/src/quality_result.dart
import 'dart:typed_data';

class QualityResult {
  /// true if average pairwise cosine similarity >= 0.85
  final bool isAcceptable;

  /// Average cosine similarity across the 3 embedding pairs
  final double averageSimilarity;

  /// The embedding from the frame with the highest average similarity to the other two.
  /// null if isAcceptable is false.
  final Float32List? bestEmbedding;

  const QualityResult({
    required this.isAcceptable,
    required this.averageSimilarity,
    this.bestEmbedding,
  });
}
