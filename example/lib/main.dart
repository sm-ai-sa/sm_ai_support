import 'package:example/sm_support_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SM AI Support Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const SupportDemoScreen(),
    );
  }
}

class SupportDemoScreen extends StatelessWidget {
  const SupportDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('SM AI Support Demo'), backgroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.support_agent, size: 100, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'SM AI Support Package Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Click the button below to open the support interface and test the package functionality.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Full Screen Support Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SMSupportPage()));
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Open Support'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SMSupportPage(isEnglish: true)));
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Open Support EN'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 32),

              const Text('Package Features:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Tenant-based configuration system'),
                  Text('• Auto-fetched categories and branding'),
                  Text('• Real-time chat interface'),
                  Text('• Media upload support'),
                  Text('• Session management'),
                  Text('• Bilingual support (EN/AR)'),
                  Text('• Customizable theme via API'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
