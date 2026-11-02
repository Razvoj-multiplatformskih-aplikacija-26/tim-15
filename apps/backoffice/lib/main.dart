import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'data/fake_repository.dart';

void main() {
  final repository = FakeRepository();
  runApp(BackofficeApp(repository: repository));
}