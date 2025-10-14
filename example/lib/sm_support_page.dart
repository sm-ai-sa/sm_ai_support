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
        tenantId: '3',
        apiKey: 'your_api_key_here', // Replace with your actual API key
        secretKey: 'your_secret_key_here', // Required: Secret key for HMAC request signing
      ),
    );
  }
}
