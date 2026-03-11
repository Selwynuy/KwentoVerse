import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/school_providers.dart';
import '../data/school_repository.dart';

class EnrollmentPage extends ConsumerStatefulWidget {
  const EnrollmentPage({super.key});

  @override
  ConsumerState<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends ConsumerState<EnrollmentPage> {
  static const _accent = Color(0xFFF59E0B);

  List<School> _schools = [];
  String _searchQuery = '';
  School? _selectedSchool;
  bool _loading = true;
  String? _error;
  bool _enrolling = false;

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    final repo = ref.read(schoolRepositoryProvider);
    try {
      final schoolId = await repo.getCurrentUserSchoolId();
      if (mounted && schoolId != null) {
        context.go('/student/home');
        return;
      }
      final list = await repo.getSchools();
      if (mounted) setState(() => _schools = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<School> get _filteredSchools {
    if (_searchQuery.trim().isEmpty) return _schools;
    final q = _searchQuery.trim().toLowerCase();
    return _schools.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _onEnroll() async {
    final school = _selectedSchool;
    if (school == null || _enrolling) return;
    setState(() => _enrolling = true);
    final repo = ref.read(schoolRepositoryProvider);
    try {
      await repo.enroll(school.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enrolled'),
          content: const Text('Student is enrolled.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      context.go('/student/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enrollment failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/student/avatar-select'),
        ),
        title: const Text(
          'Enroll',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Status banner (lighter, less dominant)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _accent.withAlpha(102),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 28, color: _accent),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'You are not enrolled yet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'My School',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search schools',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      prefixIcon: Icon(Icons.search_rounded, size: 22, color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _accent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Choose your school',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // School list
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: _accent))
                        : _error != null
                            ? _ErrorState(
                                message: _error!,
                                onRetry: () {
                                  setState(() => _error = null);
                                  _loadSchools();
                                },
                              )
                            : _filteredSchools.isEmpty
                                ? _EmptySearchState(hasQuery: _searchQuery.trim().isNotEmpty)
                                : ListView.separated(
                                    itemCount: _filteredSchools.length,
                                    separatorBuilder: (_, i) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final school = _filteredSchools[index];
                                      final isSelected = _selectedSchool?.id == school.id;
                                      return _SchoolTile(
                                        school: school,
                                        isSelected: isSelected,
                                        onTap: () => setState(() => _selectedSchool = school),
                                      );
                                    },
                                  ),
                  ),
                  const SizedBox(height: 24),
                  // Primary CTA
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _selectedSchool != null && !_enrolling ? _onEnroll : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _enrolling
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enroll', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SchoolTile extends StatelessWidget {
  const _SchoolTile({
    required this.school,
    required this.isSelected,
    required this.onTap,
  });

  final School school;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFF59E0B) : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  school.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: Color(0xFFF59E0B), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              hasQuery ? 'No schools match your search' : 'No schools available',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
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
              'Could not load schools',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 4),
            Text(
              message.length > 80 ? '${message.substring(0, 80)}…' : message,
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
