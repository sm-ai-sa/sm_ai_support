import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SupportWebViewPage extends StatefulWidget {
  const SupportWebViewPage({super.key});

  @override
  State<SupportWebViewPage> createState() => _SupportWebViewPageState();
}

class _SupportWebViewPageState extends State<SupportWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://sandbox.unicode.team/ar/landing'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support WebView')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

