import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/student_profile_providers.dart';

class AvatarSelectionPage extends ConsumerStatefulWidget {
  const AvatarSelectionPage({super.key});

  @override
  ConsumerState<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends ConsumerState<AvatarSelectionPage> {
  int? _selectedIndex;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Large preview of selected avatar
                      _SelectedAvatarPreview(
                        selectedIndex: _selectedIndex,
                        accent: accent,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select your avatar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1,
                          padding: EdgeInsets.zero,
                          children: List.generate(6, (index) {
                            return _AvatarCircle(
                              index: index,
                              isSelected: _selectedIndex == index,
                              accent: accent,
                              onTap: () => setState(() => _selectedIndex = index),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _selectedIndex == null || _saving
                              ? null
                              : () async {
                                  setState(() => _saving = true);
                                  try {
                                    await ref
                                        .read(studentProfileRepositoryProvider)
                                        .updateAvatarIndex(_selectedIndex);
                                    if (!context.mounted) return;
                                    context.go('/student/enroll');
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not save avatar: $e')),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _saving = false);
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade500,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  "LET'S GO!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

class _SelectedAvatarPreview extends StatelessWidget {
  const _SelectedAvatarPreview({
    required this.selectedIndex,
    required this.accent,
  });

  final int? selectedIndex;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withAlpha(38),
        border: Border.all(color: accent, width: 3),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          selectedIndex != null
              ? _avatarIconFor(selectedIndex!)
              : Icons.person_outline_rounded,
          size: 56,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.index,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final int index;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? accent : Colors.black87,
            width: isSelected ? 4 : 2,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(
            _avatarIconFor(index),
            size: 40,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

IconData _avatarIconFor(int index) {
  switch (index) {
    case 0:
      return Icons.sentiment_satisfied_alt_outlined;
    case 1:
      return Icons.emoji_people_outlined;
    case 2:
      return Icons.face_retouching_natural_outlined;
    case 3:
      return Icons.psychology_alt_outlined;
    case 4:
      return Icons.self_improvement_outlined;
    case 5:
    default:
      return Icons.star_border_rounded;
  }
}

