import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../providers/incident_providers.dart';
import '../../utils/app_exception.dart';
import '../../widgets/loading_button.dart';

/// Staff only: pick a new status and add an optional note for the student.
class UpdateStatusSheet extends ConsumerStatefulWidget {
  const UpdateStatusSheet({super.key, required this.incident});

  final Incident incident;

  @override
  ConsumerState<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends ConsumerState<UpdateStatusSheet> {
  late IncidentStatus _selected = widget.incident.status;
  final _noteController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _noteController.text.trim();
    if (_selected == widget.incident.status && note.isEmpty) {
      setState(() => _error = 'Choose a different status or add a note.');
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await ref.read(incidentControllerProvider.notifier).updateStatus(
          incident: widget.incident,
          status: _selected,
          note: note,
        );
    if (success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Status updated to ${_selected.label}')),
      );
    } else if (mounted) {
      setState(() => _error = friendlyError(ref.read(incidentControllerProvider).error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(incidentControllerProvider).isLoading;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Update status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'The student sees the new status right away.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            for (final status in IncidentStatus.values)
              ListTile(
                leading: Icon(status.icon, color: status.color),
                title: Text(status.label),
                trailing: _selected == status
                    ? Icon(Icons.check_circle, color: primary)
                    : const Icon(Icons.circle_outlined, color: Colors.black26),
                selected: _selected == status,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: isSaving
                    ? null
                    : () => setState(() {
                          _selected = status;
                          _error = null;
                        }),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLength: 200,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note for the student (optional)',
                hintText: 'e.g. Plumber assigned, expected fix tomorrow',
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 4),
            LoadingButton(label: 'Save', isLoading: isSaving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
