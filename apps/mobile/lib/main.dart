import 'package:flutter/material.dart';

import 'app.dart';
import 'data/fake_repository.dart';

void main() {
  runApp(ScoreboardApp(repository: FakeRepository()));
}
