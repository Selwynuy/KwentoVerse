import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/presentation/student_theme.dart';

class StoryManagementPage extends ConsumerStatefulWidget {
  const StoryManagementPage({
    super.key,
    this.storyId,
    this.createMode = false,
  });

  final String? storyId;
  final bool createMode;

  @override
  ConsumerState<StoryManagementPage> createState() =>
      _StoryManagementPageState();
}

class _StoryManagementPageState extends ConsumerState<StoryManagementPage> {
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publisherController = TextEditingController();
  final _publishingCityController = TextEditingController();

  int _selectedYear = DateTime.now().year;
  String? _selectedCategory;
  final List<String> _authors = [];
  final List<String> _copyrightLicenses = [];

  // Copyright
  bool? _isCopyrighted;

  // Upload state
  String? _storyFileName;
  double _storyUploadProgress = 0;
  bool _storyUploading = false;
  String? _storyStoragePath;

  String? _coverFileName;
  double _coverUploadProgress = 0;
  bool _coverUploading = false;
  String? _coverStoragePath;

  Uint8List? _coverPreviewBytes;

  bool _submitting = false;

  static final _years = List.generate(80, (i) => DateTime.now().year - i);

  static const _categories = [
    'Peace',
    'Science Fiction',
    'Self-Discovery',
    'Fable',
    'Adventure',
    'Fantasy',
    'Mystery',
    'Romance',
  ];

  static const _philippinesIpDisclaimer =
      "By confirming that the work being uploaded is not the user's own, the user acknowledges the requirement to have proper authorization or the right to use the copyrighted work. Under the Intellectual Property Code of the Philippines (Republic Act No. 8293), unauthorized use, reproduction, or distribution of copyrighted works may result in legal consequences.\n\nThe user must ensure that they have obtained the necessary permissions, licenses, or are using the work under fair use provisions. If uncertain about the status of the work, the user is advised to consult a legal expert before uploading.";

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _publishingCityController.dispose();
    super.dispose();
  }

  // ── Upload handlers ──────────────────────────────────────────────────

  Future<void> _pickAndUploadStory() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'epub'],
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    final bytes = picked.bytes ?? (picked.path != null ? await File(picked.path!).readAsBytes() : null);
    if (bytes == null) return;

    setState(() {
      _storyFileName = picked.name;
      _storyUploading = true;
      _storyUploadProgress = 0;
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id ?? 'unknown';
      final ext = picked.extension ?? 'pdf';
      final path = 'stories/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage.from('story-files').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: _mimeFor(ext), upsert: true),
      );

      setState(() {
        _storyStoragePath = path;
        _storyUploadProgress = 1;
        _storyUploading = false;
      });
    } catch (e) {
      setState(() => _storyUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Story upload failed: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final fileName = picked.name;
    final ext = fileName.split('.').last.toLowerCase();

    setState(() {
      _coverPreviewBytes = bytes;
      _coverFileName = fileName;
      _coverUploading = true;
      _coverUploadProgress = 0;
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id ?? 'unknown';
      final path = 'covers/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage.from('story-files').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
      );

      setState(() {
        _coverStoragePath = path;
        _coverUploadProgress = 1;
        _coverUploading = false;
      });
    } catch (e) {
      setState(() => _coverUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cover upload failed: $e')),
        );
      }
    }
  }

  String _mimeFor(String ext) {
    return switch (ext.toLowerCase()) {
      'pdf' => 'application/pdf',
      'epub' => 'application/epub+zip',
      _ => 'text/plain',
    };
  }

  // ── Submit / Create Evaluations ──────────────────────────────────────

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a story title.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;

      // Fetch school_id from educator profile
      final profile = await client
          .from('profiles')
          .select('school_id')
          .eq('id', userId!)
          .maybeSingle();
      final schoolId = profile?['school_id'] as String?;

      final pubYear = _selectedYear.toString();

      final row = await client.from('stories').insert({
        'title': title,
        'summary': _descriptionController.text.trim(),
        'author': _authors.join(', '),
        'genre': _selectedCategory,
        'isbn': _isbnController.text.trim().isNotEmpty ? _isbnController.text.trim() : null,
        'publisher': _publisherController.text.trim().isNotEmpty ? _publisherController.text.trim() : null,
        'publishing_city': _publishingCityController.text.trim().isNotEmpty ? _publishingCityController.text.trim() : null,
        'publication_date': pubYear,
        'cover_storage_path': _coverStoragePath,
        'content_storage_path': _storyStoragePath,
        'school_id': schoolId,
        'is_copyrighted': _isCopyrighted,
        'copyright_licenses': _copyrightLicenses.isEmpty ? null : _copyrightLicenses,
        'uploader_id': userId,
      }).select('id').single();

      final storyId = row['id'] as String;
      if (mounted) context.go('/educator/analytics/$storyId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create story: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Copyright dialog ─────────────────────────────────────────────────

  Future<void> _showCopyrightDialog() async {
    final answer = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: StudentTheme.surfaceCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Is the story being uploaded protected by copyright?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: StudentTheme.titleDark,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          _DialogButton(
            label: 'No',
            filled: false,
            onTap: () => Navigator.of(ctx).pop(false),
          ),
          const SizedBox(width: 12),
          _DialogButton(
            label: 'Yes',
            filled: true,
            onTap: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (answer == null) return;
    setState(() => _isCopyrighted = answer);
    if (answer) {
      await _showDisclaimerDialog();
      await _showAddCopyrightLicenseDialog();
    }
  }

  Future<void> _showDisclaimerDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DisclaimerDialog(
        disclaimer: _philippinesIpDisclaimer,
        onAgree: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  // ── Add-author dialog ────────────────────────────────────────────────

  Future<void> _showAddAuthorDialog() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StudentTheme.surfaceCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Author's Name",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: StudentTheme.titleDark,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: _inputDecoration('Full name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _DialogButton(
                label: 'Cancel',
                filled: false,
                onTap: () => Navigator.of(ctx).pop(),
              ),
              const SizedBox(width: 8),
              _DialogButton(
                label: 'Confirm',
                filled: true,
                onTap: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              ),
            ],
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name != null && name.isNotEmpty) {
      setState(() => _authors.add(name));
    }
  }

  // ── Add-copyright-license dialog ─────────────────────────────────────

  Future<void> _showAddCopyrightLicenseDialog() async {
    final ctrl = TextEditingController();
    final license = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StudentTheme.surfaceCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Copyright License / Proof of Permission',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: StudentTheme.titleDark,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: _inputDecoration('License reference or description'),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _DialogButton(
                label: 'Cancel',
                filled: false,
                onTap: () => Navigator.of(ctx).pop(),
              ),
              const SizedBox(width: 8),
              _DialogButton(
                label: 'Confirm',
                filled: true,
                onTap: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              ),
            ],
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (license != null && license.isNotEmpty) {
      setState(() => _copyrightLicenses.add(license));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: StudentTheme.secondaryGray,
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StudentTheme.cardLightOrange),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StudentTheme.cardLightOrange),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: StudentTheme.primaryOrange, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentTheme.surfaceCream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Back arrow + title ───────────────────────────────────
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: StudentTheme.titleDark,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
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
            const SizedBox(height: 8),

            // ── Story File + Cover card ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: StudentTheme.cardLightOrange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.menu_book_rounded, size: 16, color: StudentTheme.titleDark),
                      SizedBox(width: 6),
                      Text(
                        'Story File',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: StudentTheme.titleDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _UploadButton(
                          icon: Icons.upload_file_rounded,
                          label: 'Upload Story',
                          uploading: _storyUploading,
                          done: _storyStoragePath != null,
                          onTap: _storyUploading ? null : _pickAndUploadStory,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _UploadButton(
                          icon: Icons.image_rounded,
                          label: 'Upload Story Cover',
                          uploading: _coverUploading,
                          done: _coverStoragePath != null,
                          onTap: _coverUploading ? null : _pickAndUploadCover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CoverPreview(
                    bytes: _coverPreviewBytes,
                    uploading: _coverUploading,
                    done: _coverStoragePath != null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Story title ──────────────────────────────────────────
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('Add story title'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),

            // ── Description ──────────────────────────────────────────
            TextField(
              controller: _descriptionController,
              decoration: _inputDecoration('Add story description'),
              minLines: 4,
              maxLines: 6,
            ),
            const SizedBox(height: 10),

            // ── ISBN ─────────────────────────────────────────────────
            TextField(
              controller: _isbnController,
              decoration: _inputDecoration('Add ISBN'),
            ),
            const SizedBox(height: 10),

            // ── Publisher ─────────────────────────────────────────────
            TextField(
              controller: _publisherController,
              decoration: _inputDecoration('Add publisher'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),

            // ── Publishing city ──────────────────────────────────────
            TextField(
              controller: _publishingCityController,
              decoration: _inputDecoration('Add publishing city'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),

            // ── Year + Category row ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _DropdownField<int>(
                    hint: 'Year of Publication',
                    value: _selectedYear,
                    items: _years,
                    itemLabel: (y) => y.toString(),
                    onChanged: (y) {
                      if (y != null) setState(() => _selectedYear = y);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DropdownField<String>(
                    hint: 'Category',
                    value: _selectedCategory,
                    items: _categories,
                    itemLabel: (c) => c,
                    onChanged: (c) => setState(() => _selectedCategory = c),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Verification section ─────────────────────────────────
            const Text(
              'Verification',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: StudentTheme.titleDark,
              ),
            ),
            const SizedBox(height: 8),

            // Authors list
            ...List.generate(
              _authors.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _Chip(
                  label: _authors[i],
                  icon: Icons.person_rounded,
                  onRemove: () => setState(() => _authors.removeAt(i)),
                ),
              ),
            ),

            _AddItemButton(
              label: '+ Add Author Name',
              onTap: _showAddAuthorDialog,
            ),
            const SizedBox(height: 6),
            const Text(
              'Copyright',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: StudentTheme.secondaryGray,
              ),
            ),
            const SizedBox(height: 4),
            // Copyright block
            if (_isCopyrighted == null)
              _AddItemButton(
                label: 'Is this story copyrighted?',
                onTap: _showCopyrightDialog,
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _StatusChip(
                  label: _isCopyrighted!
                      ? 'Copyrighted — license required'
                      : 'Public Domain',
                  icon: _isCopyrighted!
                      ? Icons.lock_rounded
                      : Icons.public_rounded,
                  onRemove: () => setState(() {
                    _isCopyrighted = null;
                    _copyrightLicenses.clear();
                  }),
                ),
              ),
              if (_isCopyrighted == true) ...[
                ...List.generate(
                  _copyrightLicenses.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _Chip(
                      label: _copyrightLicenses[i],
                      icon: Icons.gavel_rounded,
                      onRemove: () =>
                          setState(() => _copyrightLicenses.removeAt(i)),
                    ),
                  ),
                ),
                _AddItemButton(
                  label: 'Add copyright license',
                  onTap: _showAddCopyrightLicenseDialog,
                ),
              ],
            ],

            const SizedBox(height: 24),

            // ── Create Evaluations button ────────────────────────────
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: StudentTheme.primaryOrange,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    StudentTheme.primaryOrange.withValues(alpha: 0.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Create Evaluations',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable widgets ───────────────────────────────────────────────────

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.icon,
    required this.label,
    required this.uploading,
    required this.done,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool uploading;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: uploading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: StudentTheme.primaryOrange,
              ),
            )
          : Icon(
              done ? Icons.check_circle_rounded : icon,
              size: 16,
              color: StudentTheme.primaryOrange,
            ),
      label: Text(
        uploading ? 'Uploading…' : label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: StudentTheme.primaryOrange,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: StudentTheme.primaryOrange),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.label, required this.fraction});

  final String label;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: StudentTheme.secondaryGray,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 5,
            backgroundColor: StudentTheme.cardLightOrange,
            valueColor:
                const AlwaysStoppedAnimation(StudentTheme.primaryOrange),
          ),
        ),
      ],
    );
  }
}

class _FormatHintRow extends StatelessWidget {
  const _FormatHintRow({required this.icon, required this.hint});

  final IconData icon;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: StudentTheme.secondaryGray),
        const SizedBox(width: 6),
        Text(
          hint,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: StudentTheme.secondaryGray,
          ),
        ),
      ],
    );
  }
}

class _CoverPreview extends StatelessWidget {
  const _CoverPreview({
    required this.bytes,
    required this.uploading,
    required this.done,
  });

  final Uint8List? bytes;
  final bool uploading;
  final bool done;

  Widget _buildContent() {
    if (bytes == null) {
      return Container(
        color: StudentTheme.cardLightOrange,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 28,
              color: StudentTheme.primaryOrange.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 6),
            const Text(
              'No cover yet',
              style: TextStyle(fontSize: 10, color: StudentTheme.secondaryGray),
            ),
          ],
        ),
      );
    }
    final image = Image.memory(bytes!, fit: BoxFit.cover);
    if (uploading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          image,
          Container(color: Colors.black26),
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: StudentTheme.primaryOrange,
            ),
          ),
        ],
      );
    }
    if (done) {
      return Stack(
        fit: StackFit.expand,
        children: [
          image,
          Positioned(
            right: 6,
            bottom: 6,
            child: Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: Colors.green.shade600,
            ),
          ),
        ],
      );
    }
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 120,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: StudentTheme.cardLightOrange),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 4),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StudentTheme.cardLightOrange),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              fontSize: 12,
              color: StudentTheme.secondaryGray,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.expand_more_rounded,
            color: StudentTheme.secondaryGray,
            size: 20,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: const TextStyle(
                      fontSize: 13,
                      color: StudentTheme.titleDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AddItemButton extends StatelessWidget {
  const _AddItemButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: StudentTheme.cardLightOrange),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              size: 18,
              color: StudentTheme.primaryOrange,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: StudentTheme.secondaryGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  final String label;
  final IconData icon;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: StudentTheme.cardLightOrange,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: StudentTheme.primaryOrange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: StudentTheme.titleDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: StudentTheme.secondaryGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  final String label;
  final IconData icon;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: StudentTheme.primaryOrange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: StudentTheme.titleDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: StudentTheme.secondaryGray,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dialogs ──────────────────────────────────────────────────────────────────

class _DisclaimerDialog extends StatefulWidget {
  const _DisclaimerDialog({
    required this.disclaimer,
    required this.onAgree,
  });

  final String disclaimer;
  final VoidCallback onAgree;

  @override
  State<_DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<_DisclaimerDialog> {
  bool _hasScrolledToBottom = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pos = _scrollController.position;
      if (pos.maxScrollExtent <= 0) {
        setState(() => _hasScrolledToBottom = true);
      }
    });
  }

  void _onScroll() {
    if (!_hasScrolledToBottom && mounted) {
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 16) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StudentTheme.surfaceCream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Disclaimer',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: StudentTheme.titleDark,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 240,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Text(
              widget.disclaimer,
              style: const TextStyle(
                fontSize: 12,
                height: 1.55,
                color: StudentTheme.titleDark,
              ),
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: _hasScrolledToBottom ? widget.onAgree : null,
          style: FilledButton.styleFrom(
            backgroundColor: StudentTheme.primaryOrange,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                StudentTheme.primaryOrange.withValues(alpha: 0.4),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'I agree to this',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: StudentTheme.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child:
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: StudentTheme.titleDark,
        side: const BorderSide(color: StudentTheme.cardLightOrange),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
