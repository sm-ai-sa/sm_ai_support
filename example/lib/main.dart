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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB), primary: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SM AI Support',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.support_agent_rounded, size: 64, color: Color(0xFF2563EB)),
            ),

            const SizedBox(height: 24),

            // Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'VERSION 7.0',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB), letterSpacing: 1),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'AI-Powered Customer Support',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Demo Buttons
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Try Demo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),

            const SizedBox(height: 16),

            _buildDemoButton(
              context,
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Open Support',
              subtitle: 'Arabic interface',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SMSupportPage())),
            ),

            const SizedBox(height: 12),

            _buildDemoButton(
              context,
              icon: Icons.language_rounded,
              title: 'Open Support EN',
              subtitle: 'English interface',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SMSupportPage(isEnglish: true))),
            ),

            const SizedBox(height: 40),

            // Features
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Features',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),

            const SizedBox(height: 16),

            _buildFeature('Tenant-based configuration'),
            _buildFeature('Auto-fetched categories'),
            _buildFeature('Real-time chat'),
            _buildFeature('Media upload'),
            _buildFeature('Session management'),
            _buildFeature('Bilingual support (EN/AR)'),
            _buildFeature('Customizable theme', isLast: true),

            const SizedBox(height: 40),

            // Footer
            Text(
              'Powered by SM Platform',
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748B).withValues(alpha: 0.7)),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
          ),
        ],
      ),
    );
  }
}
