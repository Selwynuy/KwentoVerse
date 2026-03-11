import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../stories/data/story_providers.dart';
import '../../stories/domain/story.dart';
import 'student_theme.dart';

class StudentSearchPage extends ConsumerStatefulWidget {
  const StudentSearchPage({super.key});

  @override
  ConsumerState<StudentSearchPage> createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends ConsumerState<StudentSearchPage> {
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

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

    final storiesAsync = ref.watch(searchStoriesProvider(_query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            controller: _queryController,
            onChanged: (value) => setState(() => _query = value),
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
          child: storiesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: StudentTheme.primaryOrange),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Could not load books. Sign in and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StudentTheme.secondaryGray, fontSize: 14),
                ),
              ),
            ),
            data: (stories) {
              if (stories.isEmpty) {
                return Center(
                  child: Text(
                    _query.isEmpty ? 'No books in your school yet.' : 'No books match "$_query".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: StudentTheme.secondaryGray, fontSize: 14),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 190,
                  mainAxisExtent: tileHeight,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: stories.length,
                itemBuilder: (context, i) {
                  final story = stories[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go('/student/story/${story.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(tilePadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: coverHeight,
                              child: _BookCover(story: story),
                            ),
                            const SizedBox(height: titleGap),
                            SizedBox(
                              height: titleHeight,
                              child: Text(
                                story.title,
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
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    final imageProvider = _coverImageProvider(story);
    return Container(
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageProvider == null
          ? const Center(
              child: Icon(Icons.auto_stories_rounded, size: 48, color: StudentTheme.primaryOrange),
            )
          : Image(image: imageProvider, fit: BoxFit.cover),
    );
  }

  ImageProvider? _coverImageProvider(Story story) {
    if (story.coverStoragePath != null && story.coverStoragePath!.trim().isNotEmpty) {
      return NetworkImage(story.coverStoragePath!);
    }
    if (story.coverAssetPath != null && story.coverAssetPath!.trim().isNotEmpty) {
      return AssetImage(story.coverAssetPath!);
    }
    return null;
  }
}
