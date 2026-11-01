import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Incident Reporter',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        // Set a light grey background so the white card/text stands out
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), 
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We remove the AppBar for now to focus on the hero design
      // appBar: AppBar(title: const Text('Campus Incident Reporter')),
      
      body: SafeArea(
        child: Stack(
          children: [
            // LAYER 1: The Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.3, // Makes the image faint so text is readable
                child: Image.asset(
                  'assets/images/school_logo.png', // Must match pubspec.yaml exactly
                  fit: BoxFit.cover, // Stretches image to fill screen
                ),
              ),
            ),

            // LAYER 2: The Content (Text/Button)
            // This sits ON TOP of the image
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hello, Student 👋',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Help make our campus safer.\nReport issues and track their resolution.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // A dummy button to test interaction
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Report an Issue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
