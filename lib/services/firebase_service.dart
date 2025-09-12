import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      // Seed essences par défaut si absentes
      await FirestoreService().seedDefaultEssences();
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  }
}
