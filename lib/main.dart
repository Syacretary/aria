import 'package:flutter/material.dart';

import 'bootstrap.dart';

void main() {
  // Draw a real Flutter frame immediately. Waiting for native preferences
  // before runApp leaves Android's splash screen waiting indefinitely if a
  // platform channel is slow during cold start.
  runApp(const AriaBootstrapGate());
}
