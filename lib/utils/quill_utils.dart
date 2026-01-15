import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class QuillUtils {
  static quill.DefaultStyles getDefaultStyles(BuildContext context) {
    final theme = Theme.of(context);
    return quill.DefaultStyles(
      paragraph: quill.DefaultTextBlockStyle(
        TextStyle(
            fontSize: 17,
            color: theme.colorScheme.onSurface,
            height: 1.6,
            letterSpacing: 0.2),
        const quill.HorizontalSpacing(0, 0),
        const quill.VerticalSpacing(8.0, 0),
        const quill.VerticalSpacing(0, 0),
        null,
      ),
      placeHolder: quill.DefaultTextBlockStyle(
        TextStyle(
            fontSize: 17,
            color: theme.hintColor.withValues(alpha: 0.8),
            height: 1.6,
            letterSpacing: 0.2),
        const quill.HorizontalSpacing(0, 0),
        const quill.VerticalSpacing(8.0, 0),
        const quill.VerticalSpacing(0, 0),
        null,
      ),
    );
  }
}
