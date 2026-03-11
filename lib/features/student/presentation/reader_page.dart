import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../dictionary/data/dictionary_providers.dart';
import '../../dictionary/data/local_dictionary_repository.dart';
import '../../dictionary/domain/dictionary_term.dart';
import '../../stories/data/story_providers.dart';
import '../data/story_read_providers.dart';
import 'student_theme.dart';

class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  late final PageController _pageController;
  final FlutterTts _tts = FlutterTts();

  int _pageIndex = 0;
  bool _isSpeaking = false;
  double _rate = 0.48;
  bool _showCompletionCta = false;

  void _onBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      // If the reader is opened directly (no stack), go back to story details.
      context.go('/student/story/${widget.storyId}');
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _isSpeaking = true);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _toggleReadAloud(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }
    await _speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyByIdProvider(widget.storyId));

    return storyAsync.when(
      loading: () => Scaffold(
        backgroundColor: StudentTheme.surfaceCream,
        appBar: AppBar(
          title: const Text('Reader'),
          backgroundColor: StudentTheme.surfaceCream,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: StudentTheme.titleDark),
            onPressed: () => _onBack(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: StudentTheme.surfaceCream,
        appBar: AppBar(
          title: const Text('Reader'),
          backgroundColor: StudentTheme.surfaceCream,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: StudentTheme.titleDark),
            onPressed: () => _onBack(context),
          ),
        ),
        body: Center(
          child: Text(
            'Failed to load story',
            style: StudentTheme.body,
          ),
        ),
      ),
      data: (story) {
        if (story == null) {
          return Scaffold(
            backgroundColor: StudentTheme.surfaceCream,
            appBar: AppBar(
              title: const Text('Reader'),
              backgroundColor: StudentTheme.surfaceCream,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: StudentTheme.titleDark),
                onPressed: () => _onBack(context),
              ),
            ),
            body: const Center(child: Text('Story not found')),
          );
        }

        final paragraphs = story.paragraphs;
        final total = paragraphs.isEmpty ? 1 : paragraphs.length;
        final currentText = paragraphs.isEmpty ? '' : paragraphs[_pageIndex.clamp(0, total - 1)];

        return Scaffold(
          backgroundColor: StudentTheme.surfaceCream,
          appBar: AppBar(
            backgroundColor: StudentTheme.surfaceCream,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: StudentTheme.titleDark),
              onPressed: () => _onBack(context),
            ),
            title: Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StudentTheme.titleDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            actions: [
              IconButton(
                tooltip: _isSpeaking ? 'Stop' : 'Read aloud',
                onPressed: () => _toggleReadAloud(currentText),
                icon: Icon(
                  _isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                  color: StudentTheme.primaryOrange,
                ),
              ),
              IconButton(
                tooltip: 'Reading speed',
                onPressed: () => _showSpeedSheet(context),
                icon: const Icon(Icons.tune_rounded, color: StudentTheme.primaryOrange),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                _ProgressBar(current: _pageIndex + 1, total: total),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: total,
                    onPageChanged: (idx) {
                      setState(() {
                        _pageIndex = idx;
                        _showCompletionCta = idx == total - 1;
                      });
                    },
                    itemBuilder: (context, i) {
                      final text = paragraphs[i];
                      return _ReaderPageBody(
                        text: text,
                        onLongPressWord: (word) => _openDictionary(context, rawToken: word),
                      );
                    },
                  ),
                ),
                _PagerBar(
                  canPrev: _pageIndex > 0,
                  canNext: _pageIndex < total - 1,
                  onPrev: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  ),
                  onNext: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  ),
                ),
                if (_showCompletionCta)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: StudentTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Mark story as read when student starts the quiz.
                          await ref
                              .read(storyReadRepositoryProvider)
                              .markRead(widget.storyId);
                          ref.invalidate(myReadStoriesProvider);
                          if (!context.mounted) return;
                          GoRouter.of(context)
                              .go('/student/evaluation/${widget.storyId}/combined');
                        },
                        child: const Text(
                          'Start Quiz',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDictionary(BuildContext context, {required String rawToken}) async {
    final term = ref.read(dictionaryLookupProvider(rawToken));
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _DictionarySheet(
          rawToken: rawToken,
          term: term,
          onSpeak: (t) => _speak(t),
        );
      },
    );
  }

  Future<void> _showSpeedSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Read-aloud speed', style: StudentTheme.sectionHeader),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Slow', style: StudentTheme.caption.copyWith(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _rate,
                          min: 0.22,
                          max: 0.72,
                          divisions: 10,
                          activeColor: StudentTheme.primaryOrange,
                          onChanged: (v) async {
                            setModalState(() => _rate = v);
                            setState(() => _rate = v);
                            await _tts.setSpeechRate(_rate);
                          },
                        ),
                      ),
                      Text('Fast', style: StudentTheme.caption.copyWith(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Tip: long-press a word to open the dictionary.', style: StudentTheme.caption),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final v = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: StudentTheme.primaryOrange.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(StudentTheme.primaryOrange),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Page $current', style: StudentTheme.caption),
              Text('$total pages', style: StudentTheme.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReaderPageBody extends StatelessWidget {
  const _ReaderPageBody({required this.text, required this.onLongPressWord});

  final String text;
  final ValueChanged<String> onLongPressWord;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
          child: _WordWrapText(text: text, onLongPressWord: onLongPressWord),
        ),
      ),
    );
  }
}

class _WordWrapText extends StatelessWidget {
  const _WordWrapText({required this.text, required this.onLongPressWord});

  final String text;
  final ValueChanged<String> onLongPressWord;

  static const _dictionary = LocalDictionaryRepository();

  @override
  Widget build(BuildContext context) {
    final tokens = _tokenize(text);
    final baseStyle = const TextStyle(
      fontSize: 18,
      height: 1.55,
      color: StudentTheme.titleDark,
      fontWeight: FontWeight.w500,
    );

    return Wrap(
      children: [
        for (final t in tokens)
          if (t.isSpace)
            Text(t.raw, style: baseStyle)
          else
            Builder(
              builder: (context) {
                final isDictWord = _dictionary.lookup(t.raw) != null;
                final style = isDictWord
                    ? baseStyle.copyWith(
                        color: StudentTheme.primaryOrange,
                        fontWeight: FontWeight.w700,
                      )
                    : baseStyle;

                return GestureDetector(
                  onLongPress: () => onLongPressWord(t.raw),
                  onTap: isDictWord ? () => onLongPressWord(t.raw) : null,
                  behavior: HitTestBehavior.translucent,
                  child: Text(t.raw, style: style),
                );
              },
            ),
      ],
    );
  }
}

class _PagerBar extends StatelessWidget {
  const _PagerBar({
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
  });

  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _NavButton(
              label: 'Previous',
              enabled: canPrev,
              onTap: onPrev,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NavButton(
              label: 'Next',
              enabled: canNext,
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.enabled, required this.onTap});

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: StudentTheme.primaryOrange,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _DictionarySheet extends StatelessWidget {
  const _DictionarySheet({
    required this.rawToken,
    required this.term,
    required this.onSpeak,
  });

  final String rawToken;
  final DictionaryTerm? term;
  final ValueChanged<String> onSpeak;

  @override
  Widget build(BuildContext context) {
    final displayWord = term?.word ?? rawToken;
    final pronunciation = term?.pronunciation;
    final meaning = term?.meaning;
    final example = term?.example;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayWord,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: StudentTheme.titleDark,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Read aloud',
                  onPressed: () => onSpeak(displayWord),
                  icon: const Icon(Icons.volume_up_rounded, color: StudentTheme.primaryOrange),
                ),
              ],
            ),
            if (pronunciation != null) ...[
              Text(pronunciation, style: StudentTheme.caption.copyWith(fontSize: 12)),
              const SizedBox(height: 10),
            ],
            _DictionaryCard(
              title: 'Meaning',
              child: Text(
                meaning ?? 'No definition found for this word yet.',
                style: StudentTheme.body.copyWith(height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
            _DictionaryCard(
              title: 'Example',
              child: Text(
                example ?? 'Try reading the sentence again and infer the meaning from context.',
                style: StudentTheme.body.copyWith(height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DictionaryCard extends StatelessWidget {
  const _DictionaryCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudentTheme.surfaceCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudentTheme.cardLightOrange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StudentTheme.sectionHeaderSecondary),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _Token {
  const _Token(this.raw, {required this.isSpace});
  final String raw;
  final bool isSpace;
}

List<_Token> _tokenize(String text) {
  final out = <_Token>[];
  final re = RegExp(r'(\s+)');
  var start = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > start) {
      out.add(_Token(text.substring(start, m.start), isSpace: false));
    }
    out.add(_Token(m.group(0) ?? ' ', isSpace: true));
    start = m.end;
  }
  if (start < text.length) {
    out.add(_Token(text.substring(start), isSpace: false));
  }
  return out;
}

