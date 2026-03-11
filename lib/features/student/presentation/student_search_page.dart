import 'package:flutter/material.dart';

import 'student_theme.dart';

class StudentSearchPage extends StatelessWidget {
  const StudentSearchPage({super.key});

  static const _searchBooks = [
    'Be Kind',
    'My Quiet Imagination',
    'The Caterpillar who LOVED shoes!',
    'I Hate Everyone',
    'A Day At Abbott Elementary',
    'It\'s Not Hansel and Gretel',
  ];

  @override
  Widget build(BuildContext context) {
    const titleLines = 2;
    const titleFontSize = 14.0;
    const titleLineHeight = 1.1;
    const titleGap = 8.0;
    const coverWidth = 110.0;
    const coverHeight = 150.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for books',
              hintStyle: const TextStyle(color: StudentTheme.secondaryGray),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: StudentTheme.secondaryGray,
                size: 24,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: StudentTheme.cardLightOrange),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: StudentTheme.cardLightOrange),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _searchBooks.length,
            itemBuilder: (context, i) {
              final title = _searchBooks[i];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const BookCoverPlaceholder(width: coverWidth, height: coverHeight),
                  const SizedBox(height: titleGap),
                  SizedBox(
                    height: titleFontSize * titleLineHeight * titleLines,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: titleLines,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: titleFontSize,
                        height: titleLineHeight,
                        fontWeight: FontWeight.w600,
                        color: StudentTheme.titleDark,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
