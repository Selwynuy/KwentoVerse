import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/student_profile_providers.dart';
import 'avatar_icons.dart';
import 'student_theme.dart';

class StudentProfilePage extends ConsumerStatefulWidget {
  const StudentProfilePage({super.key});

  @override
  ConsumerState<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends ConsumerState<StudentProfilePage> {
  static const _accent = StudentTheme.primaryOrange;
  static const _bg = Colors.white;
  int? _pendingAvatarIndex;
  bool _savingAvatar = false;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final profileAsync = ref.watch(myStudentProfileProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: _accent)),
              error: (e, _) => _ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(myStudentProfileProvider),
              ),
              data: (profile) {
                final effectiveUserId = userId ?? profile.id;
                final selectedAvatarIndex = _pendingAvatarIndex ?? profile.avatarIndex;
                final hasChange = selectedAvatarIndex != profile.avatarIndex;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  children: [
                    Center(
                      child: _AvatarCircle(
                        radius: 64,
                        accent: _accent,
                        avatarIndex: selectedAvatarIndex,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        profile.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: _UserIdRow(
                        userId: effectiveUserId,
                        onCopy: () async {
                          await Clipboard.setData(ClipboardData(text: effectiveUserId));
                          if (!context.mounted) return;
                          _showToast(context, 'Copied to clipboard');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (profile.schoolName != null && profile.schoolName!.trim().isNotEmpty)
                      Center(
                        child: Text(
                          profile.schoolName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      'Change your avatar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _QuickAvatarRow(
                      accent: _accent,
                      selectedIndex: selectedAvatarIndex,
                      onTap: (idx) => setState(() => _pendingAvatarIndex = idx),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: !hasChange || _savingAvatar
                            ? null
                            : () async {
                                setState(() => _savingAvatar = true);
                                try {
                                  await ref
                                      .read(studentProfileRepositoryProvider)
                                      .updateAvatarIndex(selectedAvatarIndex);
                                  ref.invalidate(myStudentProfileProvider);
                                  if (!context.mounted) return;
                                  setState(() => _pendingAvatarIndex = null);
                                  _showToast(context, 'Changes Applied');
                                } catch (e) {
                                  if (!context.mounted) return;
                                  _showToast(context, 'Could not save avatar: $e');
                                } finally {
                                  if (mounted) setState(() => _savingAvatar = false);
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: _savingAvatar
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Apply Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

void _showToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(
        message,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
      duration: const Duration(milliseconds: 1400),
    ),
  );
}

class _UserIdRow extends StatelessWidget {
  const _UserIdRow({required this.userId, required this.onCopy});

  final String? userId;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'UserID: ${userId ?? '—'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.copy_rounded,
                size: 16,
                color: onCopy == null ? Colors.grey.shade400 : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _QuickAvatarRow extends StatelessWidget {
  const _QuickAvatarRow({
    required this.accent,
    required this.selectedIndex,
    required this.onTap,
  });

  final Color accent;
  final int? selectedIndex;
  final ValueChanged<int?> onTap;

  static const _count = 6;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 3 * 54 + 2 * 14,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1,
          padding: EdgeInsets.zero,
          children: List.generate(_count, (i) {
            return GestureDetector(
              onTap: () => onTap(i),
              child: _SmallAvatarChip(
                accent: accent,
                index: i,
                isSelected: selectedIndex == i,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SmallAvatarChip extends StatelessWidget {
  const _SmallAvatarChip({
    required this.accent,
    required this.index,
    required this.isSelected,
  });

  final Color accent;
  final int index;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: isSelected ? accent : Colors.black87,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(avatarIconFor(index), size: 26, color: Colors.black87),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.radius,
    required this.accent,
    required this.avatarIndex,
  });

  final double radius;
  final Color accent;
  final int? avatarIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withAlpha(31),
        border: Border.all(color: accent, width: 3),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          avatarIndex != null ? avatarIconFor(avatarIndex!) : Icons.person_rounded,
          size: radius * 0.95,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              'Could not load profile',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 4),
            Text(
              message.length > 120 ? '${message.substring(0, 120)}…' : message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}


