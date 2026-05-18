// lib/src/verification_result.dart
import 'face_angle.dart';

class VerificationResult {
  final bool isMatch;
  final double bestDistance;
  final FaceAngle matchedAngle;

  const VerificationResult({
    required this.isMatch,
    required this.bestDistance,
    required this.matchedAngle,
  });
}
