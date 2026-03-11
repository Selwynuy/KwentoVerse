import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../stories/data/story_providers.dart';
import '../../stories/domain/story.dart';
import 'student_theme.dart';

class StudentHomePage extends ConsumerStatefulWidget {
  const StudentHomePage({super.key});

  @override
  ConsumerState<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<StudentHomePage> {
  static const _educators = [
    'Alina Slyshik',
    'Josh Funk',
    'Mandy Archer',
    'Zietlow Miller',
    'Hannah Peters',
  ];

  final _schoolSearchController = TextEditingController();
  String _appliedSchoolBookQuery = '';

  @override
  void dispose() {
    _schoolSearchController.dispose();
    super.dispose();
  }

  void _applySchoolBookSearch() {
    setState(() => _appliedSchoolBookQuery = _schoolSearchController.text);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _clearSchoolBookSearch() {
    _schoolSearchController.clear();
    setState(() => _appliedSchoolBookQuery = '');
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(searchStoriesProvider(_appliedSchoolBookQuery));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSchoolCard(),
        const SizedBox(height: 20),
        _buildEducatorSection(),
        const SizedBox(height: 20),
        _buildSchoolLibrarySection(),
        const SizedBox(height: 16),
        storiesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: StudentTheme.primaryOrange),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Could not load school books.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StudentTheme.secondaryGray, fontSize: 14),
              ),
            ),
          ),
          data: (stories) => _buildBookGrid(stories),
        ),
      ],
    );
  }

  Widget _buildSchoolCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.school_rounded,
            color: StudentTheme.titleDark,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'GSC SPED Integrated School',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: StudentTheme.titleDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducatorSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Educator',
                style: StudentTheme.sectionTitle,
              ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'See More',
                        style: StudentTheme.actionLabel,
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 18, color: StudentTheme.titleDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _educators.length,
              separatorBuilder: (_, i) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final name = _educators[i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          size: 28,
                          color: StudentTheme.primaryOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 76,
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.15,
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
      ),
    );
  }

  Widget _buildSchoolLibrarySection() {
    final hasText = _schoolSearchController.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School Library',
          style: StudentTheme.sectionTitle,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _schoolSearchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _applySchoolBookSearch(),
          decoration: InputDecoration(
            hintText: 'Search for books',
            hintStyle: const TextStyle(color: StudentTheme.secondaryGray),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: StudentTheme.secondaryGray,
              size: 22,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasText)
                  IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: StudentTheme.secondaryGray,
                    onPressed: _clearSchoolBookSearch,
                  ),
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search_rounded, size: 22),
                  color: StudentTheme.secondaryGray,
                  onPressed: _applySchoolBookSearch,
                ),
              ],
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBookGrid(List<Story> stories) {
    const titleLines = 2;
    const titleFontSize = 12.0;
    const titleLineHeight = 1.15;
    final emptyQuery = _appliedSchoolBookQuery.trim().isEmpty;

    if (stories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudentTheme.cardLightOrange,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 6),
            Icon(Icons.search_off_rounded, color: StudentTheme.secondaryGray, size: 40),
            const SizedBox(height: 10),
            Text(
              emptyQuery ? 'No books in your school yet.' : 'No books match your search',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: StudentTheme.titleDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emptyQuery ? '' : 'Try a different keyword.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: StudentTheme.secondaryGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.2)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    child: AspectRatio(
                      aspectRatio: 110 / 150,
                      child: _BookCover(story: story),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: titleFontSize * titleLineHeight * titleLines,
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
          );
        },
      ),
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
