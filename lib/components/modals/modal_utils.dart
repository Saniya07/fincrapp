import 'package:fincr/components/modals/modals.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';

void showColorPicker(
    BuildContext _context, ValueNotifier<Color> _colorNotifier) {
  showDialog(
    context: _context,
    builder: (_context) {
      return ColorPickerModal(
        existingColor: _colorNotifier.value,
        onColorSelect: (Color selectedColor) {
          _colorNotifier.value = selectedColor;
        },
      );
    },
  );
}

void showIconPicker(
    BuildContext _context, ValueNotifier<String> _iconNotifier) {
  showDialog(
    context: _context,
    builder: (_context) {
      return IconPicker(
        onIconSelected: (IconData selectedIcon) {
          _iconNotifier.value = getUnicodeFromIconData(selectedIcon);
        },
      );
    },
  );
}
