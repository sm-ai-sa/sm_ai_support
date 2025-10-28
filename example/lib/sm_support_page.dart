// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

class SMSupportPage extends StatelessWidget {
  bool isEnglish;
  SMSupportPage({super.key, this.isEnglish = false});

  @override
  Widget build(BuildContext context) {
    return SMSupport(
      parentContext: context,
      smSupportData: SMSupportData(
        appName: 'UNI-SUPPORT',
        locale: isEnglish ? SMSupportLocale.en : SMSupportLocale.ar,
        tenantId: '1',
        apiKey: '17841476553120002', // Test API key for sandbox
        secretKey: 'test_secret_key_67890', // Test secret key for HMAC signing
        baseUrl: 'http://localhost:3000/api/core', // REST API base URL
        socketBaseUrl: 'wss://sandbox.unicode.team/ws', // WebSocket base URL
      ),
    );
  }
}

