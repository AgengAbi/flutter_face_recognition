# flutter_face_recognition

Face embedding extraction and verification using EdgeFace XS FP16.

## Features
- 512-dim L2-normalized embeddings (~7ms on mid-range Android)
- Single-angle enrollment with 3-frame quality gate (cosine ≥ 0.85)
- Multi-angle enrollment: frontal + left side + right side
- Profile-based verification — compares query against all enrolled angles, returns best match
- AT&T: 98.0% | Celebrity: 98.5% | TAR@FAR=1%: 95–97.67%

## Single-Angle Enrollment (frontal only)

```dart
final embedder = FaceEmbedder();
await embedder.initialize();

// Capture 3 frontal frames, extract embeddings
final embeddings = <Float32List>[];
for (final frame in frontalFrames) { // 3 frames, same angle
  embeddings.add(await embedder.extractEmbedding(frame));
}

// Quality gate — rejects shaky captures
final quality = EnrollmentQualityChecker.checkFromEmbeddings(embeddings);
if (quality.isAcceptable) {
  final profile = FaceProfile(frontal: quality.bestEmbedding!);
  // Upload profile.toJson() to server
}
```

## Multi-Angle Enrollment (frontal + left + right)

```dart
// Run quality gate separately for each angle (3 frames each)
final frontalQ  = EnrollmentQualityChecker.checkFromEmbeddings(frontalEmbeddings);
final leftQ     = EnrollmentQualityChecker.checkFromEmbeddings(leftEmbeddings);
final rightQ    = EnrollmentQualityChecker.checkFromEmbeddings(rightEmbeddings);

if (frontalQ.isAcceptable && leftQ.isAcceptable && rightQ.isAcceptable) {
  final profile = FaceProfile(
    frontal: frontalQ.bestEmbedding!,
    leftSide: leftQ.bestEmbedding!,
    rightSide: rightQ.bestEmbedding!,
  );
  // Upload profile.toJson() to server
}
```

## Verification

```dart
// Restore profile from server JSON
final profile = FaceProfile.fromJson(serverJson);

// Single embedding (e.g. from a frontal check-in frame)
final queryEmbedding = await embedder.extractEmbedding(croppedFace);

// Compare against all enrolled angles — returns best match
final result = FaceVerifier.verifyWithProfile(queryEmbedding, profile);
print('Match: ${result.isMatch}');
print('Distance: ${result.bestDistance}');
print('Best angle: ${result.matchedAngle}');
```

## Acknowledgements

This package uses the EdgeFace XS model from:
[otroshi/edgeface](https://github.com/otroshi/edgeface)

The `.pth` weights were converted to TensorFlow Lite (`.tflite`) FP16 for mobile deployment.

Original license: BSD 3-Clause

```
Copyright (c) 2024, Anjith George, Christophe Ecabert, Hatef Otroshi Shahreza,
Ketan Kotwal, Sébastien Marcel
Idiap Research Institute, Martigny 1920, Switzerland.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
