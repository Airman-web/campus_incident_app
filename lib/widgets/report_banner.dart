import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// The rounded campus photo card at the top of the home screen.
class ReportBanner extends StatelessWidget {
  const ReportBanner({
    super.key,
    this.onPressed,
    this.title = 'See an issue on campus?',
    this.subtitle = 'Report it and help improve our campus.',
    this.buttonLabel = 'Report an Issue',
    this.buttonIcon = Icons.add_circle_outline,
  });

  final VoidCallback? onPressed;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData buttonIcon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 190,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              campusPhotoAsset,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.1),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    primary.withValues(alpha: 0.92),
                    primary.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: Icon(buttonIcon),
                      label: Text(buttonLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
