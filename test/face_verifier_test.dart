// test/face_verifier_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_face_recognition/src/face_angle.dart';
import 'package:flutter_face_recognition/src/face_profile.dart';
import 'package:flutter_face_recognition/src/face_verifier.dart';

Float32List makeEmbedding(double fillValue, int size) =>
    Float32List.fromList(List.filled(size, fillValue));

void main() {
  group('FaceVerifier — math primitives', () {
    test('Euclidean distance of identical embeddings is 0', () {
      final e = makeEmbedding(0.5, 512);
      expect(FaceVerifier.euclideanDistance(e, e), closeTo(0.0, 0.0001));
    });

    test('Euclidean distance of opposite embeddings is large', () {
      final a = makeEmbedding(1.0, 512);
      final b = makeEmbedding(-1.0, 512);
      expect(FaceVerifier.euclideanDistance(a, b), greaterThan(1.0));
    });

    test('verify returns true for same embedding (distance = 0)', () {
      final e = makeEmbedding(0.1, 512);
      expect(FaceVerifier.verify(e, e), isTrue);
    });

    test('verify returns false when distance exceeds threshold', () {
      final a = makeEmbedding(1.0, 512);
      final b = makeEmbedding(-1.0, 512);
      expect(FaceVerifier.verify(a, b, threshold: 0.6), isFalse);
    });

    test('cosine similarity of identical vectors is 1.0', () {
      final e = makeEmbedding(0.5, 512);
      expect(FaceVerifier.cosineSimilarity(e, e), closeTo(1.0, 0.0001));
    });

    test('cosine similarity of orthogonal vectors is 0', () {
      final a = Float32List(512);
      final b = Float32List(512);
      a[0] = 1.0;
      b[1] = 1.0;
      expect(FaceVerifier.cosineSimilarity(a, b), closeTo(0.0, 0.0001));
    });
  });

  group('FaceVerifier — multi-angle profile verification', () {
    test('verifyWithProfile matches against closest angle', () {
      final query = makeEmbedding(0.2, 512);
      final profile = FaceProfile(
        frontal: makeEmbedding(1.0, 512),
        leftSide: makeEmbedding(0.2, 512),
        rightSide: makeEmbedding(0.9, 512),
      );
      final result = FaceVerifier.verifyWithProfile(query, profile);
      expect(result.isMatch, isTrue);
      expect(result.matchedAngle, FaceAngle.leftSide);
      expect(result.bestDistance, closeTo(0.0, 0.0001));
    });

    test('verifyWithProfile returns false when no angle matches', () {
      final query = makeEmbedding(0.0, 512);
      final profile = FaceProfile(
        frontal: makeEmbedding(1.0, 512),
        leftSide: makeEmbedding(0.9, 512),
        rightSide: makeEmbedding(0.8, 512),
      );
      final result = FaceVerifier.verifyWithProfile(query, profile, threshold: 0.1);
      expect(result.isMatch, isFalse);
    });

    test('verifyWithProfile frontal-only profile uses only frontal', () {
      final query = makeEmbedding(0.5, 512);
      final profile = FaceProfile(frontal: makeEmbedding(0.5, 512));
      final result = FaceVerifier.verifyWithProfile(query, profile);
      expect(result.isMatch, isTrue);
      expect(result.matchedAngle, FaceAngle.frontal);
    });
  });
}
