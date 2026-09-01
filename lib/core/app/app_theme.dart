import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(brightness: Brightness.light, useMaterial3: true);
  }

  static ThemeData get dark {
    return ThemeData(brightness: Brightness.dark, useMaterial3: true);
  }
}
