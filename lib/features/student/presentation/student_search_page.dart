import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    const tilePadding = 4.0;
    const titleLines = 2;
    const titleFontSize = 12.0;
    const titleLineHeight = 1.15;
    const titleGap = 8.0;
    const coverHeight = 150.0;
    const titleHeight = titleFontSize * titleLineHeight * titleLines;
    const tileHeight = (tilePadding * 2) + coverHeight + titleGap + titleHeight;

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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              // Keeps tiles from getting huge on wider screens (web/tablet).
              maxCrossAxisExtent: 190,
              mainAxisExtent: tileHeight,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _searchBooks.length,
            itemBuilder: (context, i) {
              final title = _searchBooks[i];
              final id = title == "It's Not Hansel and Gretel" ? 'sample-1' : 'sample-1';
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go('/student/story/$id'),
                  child: Padding(
                    padding: const EdgeInsets.all(tilePadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: coverHeight,
                          child: BookCoverPlaceholder(useConstraints: true),
                        ),
                        const SizedBox(height: titleGap),
                        SizedBox(
                          height: titleHeight,
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
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
