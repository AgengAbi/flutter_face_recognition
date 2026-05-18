// lib/src/face_verifier.dart
import 'dart:math';
import 'dart:typed_data';
import 'face_angle.dart';
import 'face_profile.dart';
import 'verification_result.dart';

class FaceVerifier {
  /// Euclidean distance between two 512-dim embedding vectors.
  static double euclideanDistance(Float32List a, Float32List b) {
    assert(a.length == b.length, 'Embedding dimensions must match');
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  /// Returns true if Euclidean distance between [e1] and [e2] is below [threshold].
  /// Default threshold = 0.6 (validated on AT&T + Celebrity datasets).
  static bool verify(Float32List e1, Float32List e2, {double threshold = 0.6}) =>
      euclideanDistance(e1, e2) < threshold;

  /// Cosine similarity between two vectors. Used for enrollment quality gate.
  static double cosineSimilarity(Float32List a, Float32List b) {
    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0.0 || normB == 0.0) return 0.0;
    return dot / (sqrt(normA) * sqrt(normB));
  }

  /// Compares [query] against every enrolled angle in [profile].
  /// Returns a [VerificationResult] with the minimum distance found
  /// and which angle produced it — used for thesis multi-angle comparison.
  static VerificationResult verifyWithProfile(
    Float32List query,
    FaceProfile profile, {
    double threshold = 0.6,
  }) {
    double bestDist = double.infinity;
    FaceAngle bestAngle = FaceAngle.frontal;

    for (final entry in profile.enrolledAngles.entries) {
      final dist = euclideanDistance(query, entry.value);
      if (dist < bestDist) {
        bestDist = dist;
        bestAngle = entry.key;
      }
    }

    return VerificationResult(
      isMatch: bestDist < threshold,
      bestDistance: bestDist,
      matchedAngle: bestAngle,
    );
  }
}
