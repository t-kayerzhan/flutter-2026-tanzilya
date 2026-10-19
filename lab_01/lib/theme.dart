import 'package:flutter/material.dart';

// The only colour literal in lib/: ColorScheme.fromSeed needs a starting colour.
const _seed = Colors.indigo;

ThemeData buildTheme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
);
