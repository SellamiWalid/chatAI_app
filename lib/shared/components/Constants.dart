import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

const String apiKey = 'Your_Api_Key';

// For Gemini Pro
const Map<String, dynamic> generationConfig = {
  'temperature': 0.9,
  'topK': 1,
  'topP': 1,
  'maxOutputTokens': 2048,
  'stopSequences': []
};

// For Gemini Vision
const Map<String, dynamic> generationConfigForVision = {
  'temperature': 0.4,
  'topK': 32,
  'topP': 1,
  'maxOutputTokens': 4096,
  'stopSequences': []
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


// curl \
// -H 'Content-Type: application/json' \
// -d '{"contents":[{"parts":[{"text":"Write a story about a magic backpack"}]}]}' \
// -X POST https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?
// key=Your_Api_Key
