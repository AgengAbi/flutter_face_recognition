import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recognition Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Face Recognition')),
        body: const Center(child: Text('See README for integration guide')),
      ),
    );
  }
}
