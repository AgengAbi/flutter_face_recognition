// test/enrollment_quality_checker_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_face_recognition/src/enrollment_quality_checker.dart';

Float32List makeEmbedding(double val) =>
    Float32List.fromList(List.filled(512, val));

void main() {
  group('EnrollmentQualityChecker', () {
    test('accepts 3 identical embeddings (similarity = 1.0)', () {
      final embeddings = [
        makeEmbedding(0.5),
        makeEmbedding(0.5),
        makeEmbedding(0.5),
      ];
      final result = EnrollmentQualityChecker.checkFromEmbeddings(embeddings);
      expect(result.isAcceptable, isTrue);
      expect(result.averageSimilarity, closeTo(1.0, 0.001));
      expect(result.bestEmbedding, isNotNull);
    });

    test('rejects 3 orthogonal embeddings', () {
      final embeddings = [
        Float32List.fromList([1.0, 0.0, ...List.filled(510, 0.0)]),
        Float32List.fromList([0.0, 1.0, ...List.filled(510, 0.0)]),
        Float32List.fromList([0.0, 0.0, 1.0, ...List.filled(509, 0.0)]),
      ];
      final result = EnrollmentQualityChecker.checkFromEmbeddings(embeddings);
      expect(result.isAcceptable, isFalse);
      expect(result.bestEmbedding, isNull);
    });

    test('requires exactly 3 embeddings', () {
      expect(
        () => EnrollmentQualityChecker.checkFromEmbeddings([makeEmbedding(0.5)]),
        throwsAssertionError,
      );
    });
  });
}
