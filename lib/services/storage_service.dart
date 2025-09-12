import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadChantierPdf({
    required String userId,
    required String chantierId,
    required Uint8List data,
  }) async {
    final String path = 'users/$userId/chantier_reports/$chantierId.pdf';
    final ref = _storage.ref().child(path);
    final meta = SettableMetadata(contentType: 'application/pdf');
    await ref.putData(data, meta);
    return ref.getDownloadURL();
  }
}
