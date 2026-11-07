import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap.dart';

Future<void> main() async {
  final app = await bootstrapApp(const AriaApp());
  runApp(app);
}
