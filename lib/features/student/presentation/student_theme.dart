import 'package:flutter/material.dart';

/// Student UI color theme: orange accent, cream/white surfaces.
class StudentTheme {
  StudentTheme._();

  static const Color primaryOrange = Color(0xFFFF9500);
  static const Color cardCream = Color(0xFFFFF5EE);
  static const Color cardLightOrange = Color(0xFFFFE8D6);
  static const Color surfaceCream = Color(0xFFF7F3EF);
  static const Color titleDark = Color(0xFF1C1C1E);
  static const Color secondaryGray = Color(0xFF6C6C70);
}

/// Placeholder for book cover (rect with icon). Use fixed size or aspect ratio.
class BookCoverPlaceholder extends StatelessWidget {
  const BookCoverPlaceholder({
    super.key,
    this.width = 56,
    this.height = 80,
    this.useConstraints = false,
  });

  final double width;
  final double height;
  final bool useConstraints;

  @override
  Widget build(BuildContext context) {
    if (!useConstraints) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: StudentTheme.cardLightOrange,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.3)),
        ),
        child: Icon(
          Icons.menu_book_rounded,
          color: StudentTheme.primaryOrange.withValues(alpha: 0.7),
          size: (width < height ? width : height) * 0.5,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : width;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : height;
        final iconSize = (w < h ? w : h) * 0.5;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: StudentTheme.cardLightOrange,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Icon(
              Icons.menu_book_rounded,
              color: StudentTheme.primaryOrange.withValues(alpha: 0.7),
              size: iconSize,
            ),
          ),
        );
      },
    );
  }
}
