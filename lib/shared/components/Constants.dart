import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

const String apiKey = 'your-api-key';

const Map<String, dynamic> generationConfig = {
  "temperature": 0.9,
  "top_p": 1,
  "top_k": 0,
  "max_output_tokens": 2048,
  "response_mime_type": "text/plain",
};

const List<Map<String, String>> safetySettings = [
  {
    'category': 'HARM_CATEGORY_HARASSMENT',
    'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
  },
  {
    'category': 'HARM_CATEGORY_HATE_SPEECH',
    'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
  },
  {
    'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
    'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
  },
  {
    'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
    'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
  }
];



String getOs() => Platform.operatingSystem;

Future<String?> getDeviceToken() async {
  return await FirebaseMessaging.instance.getToken();
}

dynamic uId;

const String profile =
    'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.webp';