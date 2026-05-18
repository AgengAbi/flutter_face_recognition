// lib/src/face_profile.dart
import 'dart:typed_data';
import 'face_angle.dart';

class FaceProfile {
  final Float32List frontal;
  final Float32List? leftSide;
  final Float32List? rightSide;

  const FaceProfile({
    required this.frontal,
    this.leftSide,
    this.rightSide,
  });

  Map<FaceAngle, Float32List> get enrolledAngles => {
        FaceAngle.frontal: frontal,
        if (leftSide != null) FaceAngle.leftSide: leftSide!,
        if (rightSide != null) FaceAngle.rightSide: rightSide!,
      };

  bool get isMultiAngle => leftSide != null && rightSide != null;

  Map<String, dynamic> toJson() => {
        'frontal': frontal.toList(),
        if (leftSide != null) 'leftSide': leftSide!.toList(),
        if (rightSide != null) 'rightSide': rightSide!.toList(),
      };

  factory FaceProfile.fromJson(Map<String, dynamic> json) {
    Float32List? parse(dynamic v) =>
        v == null ? null : Float32List.fromList((v as List).cast<double>());
    return FaceProfile(
      frontal: parse(json['frontal'])!,
      leftSide: parse(json['leftSide']),
      rightSide: parse(json['rightSide']),
    );
  }
}
