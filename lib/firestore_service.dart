import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Menambahkan berita baru
  Future<void> addItem(String title, String description, String category, [String? imageUrl]) async {
    try {
      await _db.collection('news').add({
        'title': title,
        'description': description,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  // Mengambil semua berita
  Stream<List<Map<String, dynamic>>> getNews() {
    return _db.collection('news').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // Menggunakan null check jika data tidak ada
        return {
          'id': doc.id,
          'title': data['title'] ?? 'No Title', // default 'No Title' jika null
          'description': data['description'] ?? 'No Description', // default 'No Description' jika null
          'category': data['category'] ?? 'No Category', // default 'No Category' jika null
        };
      }).toList();
    });
  }

  // Menghapus berita
  Future<void> deleteItem(String id) async {
    try {
      await _db.collection('news').doc(id).delete();
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  // Mengupdate berita
  Future<void> updateItem(String id, String title, String description, String category, [String? imageUrl]) async {
    try {
      await _db.collection('news').doc(id).update({
        'title': title,
        'description': description,
        'category': category,
      });
    } catch (e) {
      print("Error updating item: $e");
    }
  }
}
