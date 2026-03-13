import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/presentation/avatar_icons.dart';
import '../../student/presentation/student_theme.dart';
import '../data/principal_providers.dart';

class PrincipalEducatorsPage extends ConsumerStatefulWidget {
  const PrincipalEducatorsPage({super.key});

  @override
  ConsumerState<PrincipalEducatorsPage> createState() =>
      _PrincipalEducatorsPageState();
}

class _PrincipalEducatorsPageState
    extends ConsumerState<PrincipalEducatorsPage> {
  int _tabIndex = 0; // 0 = Active, 1 = Revoked Access
  final _searchController = TextEditingController();
  String _query = '';
  final Set<String> _pending = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleRevoke(SchoolEducatorDetail educator) async {
    setState(() => _pending.add(educator.userId));
    final client = ref.read(supabaseClientProvider);
    try {
      if (educator.isRevoked) {
        await restoreEducator(client, educator.userId);
      } else {
        await revokeEducator(client, educator.userId);
      }
      ref.invalidate(principalSchoolEducatorsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _pending.remove(educator.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final educatorsAsync = ref.watch(principalSchoolEducatorsProvider);

    return Scaffold(
      backgroundColor: StudentTheme.surfaceCream,
      body: Column(
        children: [
          // ── App bar ────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: StudentTheme.titleDark,
                    ),
                    onPressed: () => context.go('/educator/home'),
                  ),
                  const Expanded(
                    child: Text(
                      'KwentoVerse',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: StudentTheme.titleDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // ── Tabs ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _TabChip(
                  label: 'Active',
                  selected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Revoked Access',
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Section label ──────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Educators',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: StudentTheme.titleDark,
                ),
              ),
            ),
          ),

          // ── Search ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search for books',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: StudentTheme.secondaryGray,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: StudentTheme.secondaryGray,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: StudentTheme.cardLightOrange),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: StudentTheme.cardLightOrange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: StudentTheme.primaryOrange, width: 1.5),
                ),
              ),
            ),
          ),

          // ── List ───────────────────────────────────────────────────
          Expanded(
            child: educatorsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: StudentTheme.primaryOrange),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Could not load educators: $e',
                  style:
                      const TextStyle(color: StudentTheme.secondaryGray),
                ),
              ),
              skipLoadingOnReload: true,
              data: (educators) {
                final filtered = educators.where((e) {
                  final matchesTab =
                      _tabIndex == 0 ? !e.isRevoked : e.isRevoked;
                  final matchesSearch = _query.isEmpty ||
                      e.fullName.toLowerCase().contains(_query);
                  return matchesTab && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _tabIndex == 0
                          ? 'No active educators.'
                          : 'No revoked educators.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: StudentTheme.secondaryGray,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final educator = filtered[i];
                    final isPrincipal = educator.role == 'principal';
                    return _EducatorRow(
                      educator: educator,
                      isPrincipal: isPrincipal,
                      isPending: _pending.contains(educator.userId),
                      onToggleRevoke:
                          isPrincipal ? null : () => _toggleRevoke(educator),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? StudentTheme.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? StudentTheme.primaryOrange
                : StudentTheme.cardLightOrange,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : StudentTheme.titleDark,
          ),
        ),
      ),
    );
  }
}

class _EducatorRow extends StatelessWidget {
  const _EducatorRow({
    required this.educator,
    required this.isPrincipal,
    required this.isPending,
    required this.onToggleRevoke,
  });

  final SchoolEducatorDetail educator;
  final bool isPrincipal;
  final bool isPending;
  final VoidCallback? onToggleRevoke;

  @override
  Widget build(BuildContext context) {
    final icon = educator.avatarIndex != null
        ? avatarIconFor(educator.avatarIndex!)
        : Icons.person_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudentTheme.cardLightOrange),
      ),
      child: Row(
        children: [
          // ⋮ drag handle (decorative, matches design)
          const Icon(Icons.drag_indicator_rounded,
              size: 18, color: StudentTheme.secondaryGray),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: StudentTheme.cardLightOrange,
            child: Icon(icon, size: 22, color: StudentTheme.primaryOrange),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  educator.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: StudentTheme.titleDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isPrincipal
                      ? 'Principal'
                      : educator.isRevoked
                          ? 'Educator — Revoked'
                          : 'Educator',
                  style: const TextStyle(
                    fontSize: 11,
                    color: StudentTheme.secondaryGray,
                  ),
                ),
              ],
            ),
          ),
          if (!isPrincipal)
            isPending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: StudentTheme.primaryOrange,
                    ),
                  )
                : IconButton(
              icon: Icon(
                educator.isRevoked
                    ? Icons.person_add_rounded
                    : Icons.person_remove_rounded,
                size: 22,
                color: educator.isRevoked
                    ? StudentTheme.primaryOrange
                    : StudentTheme.secondaryGray,
              ),
              onPressed: onToggleRevoke,
              tooltip: educator.isRevoked ? 'Restore access' : 'Revoke access',
            ),
        ],
      ),
    );
  }
}
