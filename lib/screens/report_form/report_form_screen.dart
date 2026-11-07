import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/incident_category.dart';
import '../../providers/incident_providers.dart';
import '../../utils/app_exception.dart';
import '../../utils/snackbars.dart';
import '../../utils/validators.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/photo_picker_field.dart';

/// The form a student fills in to report an incident.
class ReportFormScreen extends ConsumerStatefulWidget {
  const ReportFormScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const ReportFormScreen());

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();

  // Local form state. setState is fine here because nothing outside
  // this screen needs to know about it.
  IncidentCategory? _category;
  File? _photo;
  bool _showCategoryError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      // Smaller photos upload faster and use less storage.
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 75,
      );
      if (picked != null && mounted) setState(() => _photo = File(picked.path));
    } catch (_) {
      if (mounted) {
        showError(context, const AppException('Could not open the camera or gallery.'));
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final formIsValid = _formKey.currentState!.validate();
    setState(() => _showCategoryError = _category == null);
    if (!formIsValid || _category == null) return;

    final success = await ref.read(incidentControllerProvider.notifier).submit(
          title: _titleController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          category: _category!,
          photo: _photo,
        );
    if (!mounted) return;

    if (success) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Report submitted. You can track it in Reports.')),
      );
    } else {
      showError(context, ref.read(incidentControllerProvider).error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(incidentControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const _FieldLabel('Select a category'),
              CategorySelector(
                selected: _category,
                errorText: _showCategoryError ? 'Please choose a category' : null,
                onSelected: (category) => setState(() {
                  _category = category;
                  _showCategoryError = false;
                }),
              ),
              if (_category == IncidentCategory.safety) const _SafetyNotice(),
              const _FieldLabel('Title'),
              TextFormField(
                controller: _titleController,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Briefly describe the issue'),
                validator: (value) =>
                    Validators.text(value, label: 'Title', min: 5, max: 80),
              ),
              const _FieldLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLength: 1000,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'What happened, when did you notice it, and who is affected?',
                ),
                validator: (value) =>
                    Validators.text(value, label: 'Description', min: 10, max: 1000),
              ),
              const _FieldLabel('Location'),
              TextFormField(
                controller: _locationController,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Block B, Room 204',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) =>
                    Validators.text(value, label: 'Location', min: 2, max: 100),
              ),
              const _FieldLabel('Add a photo (optional)'),
              PhotoPickerField(
                photo: _photo,
                onPick: isSubmitting ? null : _pickPhoto,
                onRemove: isSubmitting ? null : () => setState(() => _photo = null),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your name is shared with campus staff only. '
                'Please avoid photos that show people\'s faces or personal details.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Submit Report',
                isLoading: isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

/// Reminder that the app is not for emergencies.
class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: errorColor),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'If someone is in danger right now, contact campus security '
              'directly. This app is not monitored around the clock.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
