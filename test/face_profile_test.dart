// test/face_profile_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_face_recognition/src/face_angle.dart';
import 'package:flutter_face_recognition/src/face_profile.dart';
import 'package:flutter_face_recognition/src/verification_result.dart';

Float32List makeEmb(double val) =>
    Float32List.fromList(List.filled(512, val));

void main() {
  group('FaceAngle', () {
    test('enum has frontal, leftSide, rightSide', () {
      expect(FaceAngle.values.length, 3);
      expect(FaceAngle.values, containsAll([
        FaceAngle.frontal,
        FaceAngle.leftSide,
        FaceAngle.rightSide,
      ]));
    });
  });

  group('FaceProfile', () {
    test('frontal-only profile has 1 enrolled angle', () {
      final p = FaceProfile(frontal: makeEmb(0.1));
      expect(p.enrolledAngles.length, 1);
      expect(p.enrolledAngles.keys, contains(FaceAngle.frontal));
      expect(p.isMultiAngle, isFalse);
    });

    test('full multi-angle profile has 3 enrolled angles', () {
      final p = FaceProfile(
        frontal: makeEmb(0.1),
        leftSide: makeEmb(0.2),
        rightSide: makeEmb(0.3),
      );
      expect(p.enrolledAngles.length, 3);
      expect(p.isMultiAngle, isTrue);
    });

    test('round-trip toJson/fromJson preserves all embeddings', () {
      final original = FaceProfile(
        frontal: makeEmb(0.1),
        leftSide: makeEmb(0.2),
        rightSide: makeEmb(0.3),
      );
      final restored = FaceProfile.fromJson(original.toJson());
      expect(restored.frontal[0], closeTo(0.1, 0.0001));
      expect(restored.leftSide![0], closeTo(0.2, 0.0001));
      expect(restored.rightSide![0], closeTo(0.3, 0.0001));
    });

    test('fromJson handles missing optional angles (frontal-only)', () {
      final original = FaceProfile(frontal: makeEmb(0.5));
      final restored = FaceProfile.fromJson(original.toJson());
      expect(restored.leftSide, isNull);
      expect(restored.rightSide, isNull);
    });
  });

  group('VerificationResult', () {
    test('isMatch true when bestDistance < threshold', () {
      const r = VerificationResult(
        isMatch: true,
        bestDistance: 0.3,
        matchedAngle: FaceAngle.frontal,
      );
      expect(r.isMatch, isTrue);
      expect(r.bestDistance, 0.3);
      expect(r.matchedAngle, FaceAngle.frontal);
    });
  });
}
