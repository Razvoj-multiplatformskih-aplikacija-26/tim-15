import 'package:flutter/material.dart';

class MyEntriesScreen extends StatelessWidget {
  const MyEntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My submissions')),
      body: const Center(child: Text('My submissions')),
    );
  }
}