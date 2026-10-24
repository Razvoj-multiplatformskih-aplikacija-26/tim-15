import 'package:flutter/material.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entryId});
  final String entryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submission Details')),
      body: Center(child: Text('Submission details:  $entryId')),
    );
  }
}