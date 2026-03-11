import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../stories/data/story_providers.dart';
import '../../stories/domain/story.dart';
import '../../../shared/images/local_file_image.dart';
import 'student_theme.dart';

class StoryDetailsPage extends ConsumerStatefulWidget {
  const StoryDetailsPage({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<StoryDetailsPage> createState() => _StoryDetailsPageState();
}

class _StoryDetailsPageState extends ConsumerState<StoryDetailsPage> {
  int _rating = 0;
  bool _isInLibrary = false;
  bool _ratingSubmitted = false;

  void _onBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go('/student/library');
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyByIdProvider(widget.storyId));

    return storyAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Failed to load story')),
      ),
      data: (story) {
        if (story == null) {
          return _NotFoundState(storyId: widget.storyId);
        }

        final myRating = ref.watch(storyMyRatingProvider(widget.storyId)).when(
              data: (v) => v,
              loading: () => null,
              error: (_, __) => null,
            );
        final displayedRating = myRating ?? _rating;
        final hasRated = myRating != null || _ratingSubmitted;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(storyByIdProvider(widget.storyId));
                    ref.invalidate(storyMyRatingProvider(widget.storyId));
                    await ref.read(storyByIdProvider(widget.storyId).future);
                  },
                  child: CustomScrollView(
                    slivers: [
                    SliverToBoxAdapter(
                      child: _HeroHeader(
                        story: story,
                        onBack: () => _onBack(context),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              story.title,
                              style: StudentTheme.sectionTitle.copyWith(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.author,
                              style: StudentTheme.caption.copyWith(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            _MetaRow(
                              readsCount: story.readsCount,
                              averageRating: story.averageRating,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _PillButton(
                                    label: _isInLibrary ? 'Added' : 'Add',
                                    icon: _isInLibrary ? Icons.check_rounded : Icons.add_rounded,
                                    filled: false,
                                    onTap: () =>
                                        setState(() => _isInLibrary = !_isInLibrary),
                                    height: 44,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _PillButton(
                                    label: 'Read',
                                    icon: Icons.menu_book_rounded,
                                    filled: true,
                                    onTap: () => context.go('/student/reader/${story.id}'),
                                    height: 44,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text('Description', style: StudentTheme.sectionHeader),
                            const SizedBox(height: 8),
                            Text(
                              story.description,
                              style: StudentTheme.body.copyWith(height: 1.35),
                            ),
                            const SizedBox(height: 8),
                            if (story.genre != null || story.publicationDate != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (story.genre != null)
                                    Text(
                                      'Genre: ${story.genre}',
                                      style: StudentTheme.caption.copyWith(
                                        fontSize: 12,
                                        color: StudentTheme.secondaryGray,
                                      ),
                                    ),
                                  if (story.publicationDate != null)
                                    Text(
                                      'Publication Date: ${story.publicationDate}',
                                      style: StudentTheme.caption.copyWith(
                                        fontSize: 12,
                                        color: StudentTheme.secondaryGray,
                                      ),
                                    ),
                                ],
                              ),
                            const SizedBox(height: 12),
                        Text('Rate this book', style: StudentTheme.sectionHeaderSecondary),
                        const SizedBox(height: 8),
                        _StarRating(
                          rating: displayedRating,
                          onSetRating: (v) => setState(() {
                            _rating = v;
                            _ratingSubmitted = false;
                          }),
                        ),
                        if (hasRated) ...[
                          const SizedBox(height: 6),
                          Text(
                            'You rated this ${myRating ?? _rating}/5',
                            style: StudentTheme.caption.copyWith(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _rating > 0
                                  ? (hasRated
                                      ? StudentTheme.primaryOrange.withValues(alpha: 0.6)
                                      : StudentTheme.primaryOrange)
                                  : StudentTheme.primaryOrange.withValues(alpha: 0.3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: _rating > 0
                                ? () async {
                                    if (widget.storyId != 'sample-1') {
                                      try {
                                        await ref
                                            .read(supabaseStoryRepositoryProvider)
                                            .submitRating(widget.storyId, _rating);
                                        ref.invalidate(storyMyRatingProvider(widget.storyId));
                                      } catch (_) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text('Could not save rating')),
                                          );
                                        }
                                        return;
                                      }
                                    }
                                    setState(() => _ratingSubmitted = true);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Thanks for rating this book!'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: Text(
                              hasRated ? 'Rating submitted' : 'Submit rating',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState({required this.storyId});
  final String storyId;

  void _onBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go('/student/library');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 44,
                  color: StudentTheme.primaryOrange.withValues(alpha: 0.85),
                ),
                const SizedBox(height: 10),
                const Text('Story not found', style: StudentTheme.sectionHeader),
                const SizedBox(height: 6),
                Text(
                  'No story for id: $storyId',
                  textAlign: TextAlign.center,
                  style: StudentTheme.caption.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _onBack(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.story, required this.onBack});
  final Story story;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const heroHeight = 180.0;
    const coverHeight = 130.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroBackground(story: story),
          Positioned(
            left: 6,
            top: 6,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CoverImage(
                story: story,
                height: coverHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final provider = storyCoverProvider(story);
    if (provider != null) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(image: provider, fit: BoxFit.cover),
            Container(color: Colors.black.withValues(alpha: 0.30)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StudentTheme.primaryOrange.withValues(alpha: 0.80),
            const Color(0xFF92400E),
          ],
        ),
      ),
      child: Container(color: Colors.black.withValues(alpha: 0.22)),
    );
  }
}

ImageProvider? storyCoverProvider(Story story) {
  // 1) local downloaded cover (mobile/desktop only)
  final local = localFileImageProvider(story.localCoverPath);
  if (local != null) return local;

  // 2) network cover (future: convert storage path -> signed/public url)
  // If you later decide to store a full URL, set it here.
  if (story.coverStoragePath != null && story.coverStoragePath!.trim().isNotEmpty) {
    // Placeholder: treat as URL for now.
    return NetworkImage(story.coverStoragePath!);
  }

  // 3) asset fallback
  if (story.coverAssetPath != null && story.coverAssetPath!.trim().isNotEmpty) {
    return AssetImage(story.coverAssetPath!);
  }

  return null;
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.story, required this.height});

  final Story story;
  final double height;

  @override
  Widget build(BuildContext context) {
    final provider = storyCoverProvider(story);
    final width = height * 0.78;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: provider == null
            ? Container(
                color: StudentTheme.cardLightOrange,
                child: const Center(
                  child: Icon(Icons.auto_stories_rounded, size: 48, color: StudentTheme.primaryOrange),
                ),
              )
            : Image(image: provider, fit: BoxFit.cover),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.readsCount, required this.averageRating});
  final int? readsCount;
  final double? averageRating;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (readsCount != null) _PillTag(icon: Icons.menu_book_rounded, label: '${_formatReads(readsCount!)} reads'),
        if (averageRating != null)
          _PillTag(
            icon: Icons.star_rounded,
            label: averageRating!.toStringAsFixed(1),
          ),
      ],
    );
  }

  static String _formatReads(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(n >= 10000000 ? 0 : 1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}K';
    return n.toString();
  }
}

class _PillTag extends StatelessWidget {
  const _PillTag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: StudentTheme.primaryOrange),
          const SizedBox(width: 6),
          Text(label, style: StudentTheme.caption.copyWith(color: StudentTheme.titleDark)),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.onSetRating});
  final int rating;
  final ValueChanged<int> onSetRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudentTheme.cardLightOrange),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final v = i + 1;
          final filled = v <= rating;
          return IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onSetRating(v),
            icon: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: filled ? StudentTheme.primaryOrange : StudentTheme.secondaryGray,
              size: 28,
            ),
          );
        }),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? StudentTheme.primaryOrange : StudentTheme.cardCream;
    final fg = filled ? Colors.white : StudentTheme.titleDark;
    final border = filled ? null : Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.20));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: border),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Text(label, style: StudentTheme.actionLabel.copyWith(color: fg, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.filled,
    this.height = 48,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? StudentTheme.primaryOrange : StudentTheme.cardCream;
    final fg = filled ? Colors.white : StudentTheme.titleDark;
    final border = filled ? null : Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.20));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: height,
          decoration: BoxDecoration(border: border, borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
              Text(label, style: StudentTheme.actionLabel.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

