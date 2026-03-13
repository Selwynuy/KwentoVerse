import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../stories/data/story_cover_url.dart';
import '../../stories/data/story_providers.dart';
import '../../stories/domain/story.dart';
import '../data/co_educator_providers.dart';
import '../data/educator_profile_providers.dart';
import '../../student/presentation/student_theme.dart';
import '../../student/data/school_educators_repository.dart';

class EducatorHomePage extends ConsumerStatefulWidget {
  const EducatorHomePage({super.key});

  @override
  ConsumerState<EducatorHomePage> createState() => _EducatorHomePageState();
}

class _EducatorHomePageState extends ConsumerState<EducatorHomePage> {
  final _searchController = TextEditingController();
  String _appliedQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    setState(() => _appliedQuery = _searchController.text);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _appliedQuery = '');
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(searchStoriesProvider(_appliedQuery));
    final profileAsync = ref.watch(myEducatorProfileProvider);
    final coEducatorsAsync = ref.watch(coEducatorsProvider);

    final schoolName = profileAsync.maybeWhen(
      data: (p) => p.schoolName ?? 'My School',
      orElse: () => 'My School',
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SchoolCard(name: schoolName),
        const SizedBox(height: 20),
        _CoEducatorSection(educatorsAsync: coEducatorsAsync),
        const SizedBox(height: 20),
        _buildLibraryHeader(),
        const SizedBox(height: 16),
        storiesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: StudentTheme.primaryOrange),
            ),
          ),
          error: (e, st) => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Could not load school books.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StudentTheme.secondaryGray, fontSize: 14),
              ),
            ),
          ),
          data: (stories) => _BookGrid(
            stories: stories,
            emptyQuery: _appliedQuery.trim().isEmpty,
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryHeader() {
    final hasText = _searchController.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('School Library', style: StudentTheme.sectionTitle),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _applySearch(),
          decoration: InputDecoration(
            hintText: 'Search for books',
            hintStyle: const TextStyle(color: StudentTheme.secondaryGray),
            prefixIcon: const Icon(
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
                    onPressed: _clearSearch,
                  ),
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search_rounded, size: 22),
                  color: StudentTheme.secondaryGray,
                  onPressed: _applySearch,
                ),
              ],
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StudentTheme.cardLightOrange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StudentTheme.cardLightOrange),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.school_rounded,
            color: StudentTheme.titleDark,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
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
}

class _CoEducatorSection extends StatelessWidget {
  const _CoEducatorSection({required this.educatorsAsync});
  final AsyncValue<List<SchoolEducator>> educatorsAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Co-Educators', style: StudentTheme.sectionTitle),
            ],
          ),
          const SizedBox(height: 10),
          educatorsAsync.when(
            loading: () => const SizedBox(
              height: 92,
              child: Center(
                child: CircularProgressIndicator(
                  color: StudentTheme.primaryOrange,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, st) => const SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  'Could not load educators.',
                  style: TextStyle(
                    color: StudentTheme.secondaryGray,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            data: (educators) {
              if (educators.isEmpty) {
                return const SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      'No other educators yet.',
                      style: TextStyle(
                        color: StudentTheme.secondaryGray,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: educators.length,
                  separatorBuilder: (e, st) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final name = educators[i].fullName;
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
                          child: const CircleAvatar(
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.stories, required this.emptyQuery});
  final List<Story> stories;
  final bool emptyQuery;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudentTheme.cardLightOrange,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: StudentTheme.primaryOrange.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 6),
            const Icon(
              Icons.search_off_rounded,
              color: StudentTheme.secondaryGray,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              emptyQuery
                  ? 'No books in your school yet.'
                  : 'No books match your search.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: StudentTheme.titleDark,
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
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.2),
        ),
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
              onTap: () =>
                  context.go('/educator/story/${story.id}'),
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
                  Text(
                    story.title,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookCover extends ConsumerWidget {
  const _BookCover({required this.story});
  final Story story;

  static Widget _placeholder() => const Center(
        child: Icon(
          Icons.auto_stories_rounded,
          size: 48,
          color: StudentTheme.primaryOrange,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final String? networkUrl = story.coverStoragePath != null &&
            story.coverStoragePath!.trim().isNotEmpty
        ? storyCoverPublicUrl(client, story.coverStoragePath!)
        : null;
    final String? assetPath = story.coverAssetPath != null &&
            story.coverAssetPath!.trim().isNotEmpty
        ? story.coverAssetPath
        : null;

    return Container(
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: networkUrl != null
          ? Image.network(
              networkUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : assetPath != null
              ? Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
    );
  }
}

