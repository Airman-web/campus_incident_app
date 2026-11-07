import 'dart:io';

import 'package:flutter/material.dart';

/// "Tap to add a photo" box, or a preview of the chosen photo.
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  final File? photo;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final chosenPhoto = photo;

    if (chosenPhoto == null) {
      return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 110,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: primary, size: 30),
                const SizedBox(height: 6),
                const Text('Tap to add a photo', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            chosenPhoto,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filledTonal(
            tooltip: 'Remove photo',
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
