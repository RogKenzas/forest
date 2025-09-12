import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _prefsUidKey = 'session_uid';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    UserRole role = UserRole.agent,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        final UserModel userModel = UserModel(
          id: result.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          username: username,
          role: role,
          dateJoined: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toMap());

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsUidKey, result.user!.uid);

        return userModel;
      }
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
    return null;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });

        final doc =
            await _firestore.collection('users').doc(result.user!.uid).get();

        if (doc.exists) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefsUidKey, result.user!.uid);
          return UserModel.fromMap(doc.data()!);
        }
      }
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsUidKey);
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  Future<UserModel?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUid = prefs.getString(_prefsUidKey);
      if (storedUid == null || storedUid.isEmpty) return null;

      // Si FirebaseAuth a déjà un utilisateur, on l'utilise, sinon on récupère Firestore
      final firebaseUser = _auth.currentUser;
      final String uidToUse = firebaseUser?.uid ?? storedUid;

      final doc = await _firestore.collection('users').doc(uidToUse).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error restoring session: $e');
    }
    return null;
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<int> getUserCount() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting user count: $e');
      return 0;
    }
  }
}
