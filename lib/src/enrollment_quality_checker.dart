// lib/src/enrollment_quality_checker.dart
import 'dart:typed_data';
import 'face_verifier.dart';
import 'quality_result.dart';

class EnrollmentQualityChecker {
  static const double acceptanceThreshold = 0.85;

  /// Checks quality from 3 pre-computed embeddings of the same angle.
  /// Computes average pairwise cosine similarity across 3 pairs: (0,1), (0,2), (1,2).
  /// Returns the embedding with the highest average similarity as bestEmbedding.
  static QualityResult checkFromEmbeddings(List<Float32List> embeddings) {
    assert(embeddings.length == 3, 'Exactly 3 embeddings required');

    const pairs = [(0, 1), (0, 2), (1, 2)];
    final similarities = pairs
        .map((p) => FaceVerifier.cosineSimilarity(embeddings[p.$1], embeddings[p.$2]))
        .toList();

    final avg = similarities.reduce((a, b) => a + b) / similarities.length;

    if (avg < acceptanceThreshold) {
      return QualityResult(isAcceptable: false, averageSimilarity: avg);
    }

    // Pick embedding with highest average similarity to the other two
    final scores = List.generate(3, (i) {
      double total = 0;
      for (int j = 0; j < 3; j++) {
        if (i != j) total += FaceVerifier.cosineSimilarity(embeddings[i], embeddings[j]);
      }
      return total / 2;
    });
    final bestIdx = scores.indexOf(scores.reduce((a, b) => a > b ? a : b));

    return QualityResult(
      isAcceptable: true,
      averageSimilarity: avg,
      bestEmbedding: embeddings[bestIdx],
    );
  }
}
