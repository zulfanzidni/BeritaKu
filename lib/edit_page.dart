import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart'; // Pastikan FirestoreService sudah disiapkan

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  void _addItem() {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      _firestoreService.addItem(
        _titleController.text,
        _descriptionController.text,
        _categoryController.text,
      );
      _titleController.clear();
      _descriptionController.clear();
      _categoryController.clear();
    }
  }

  void _deleteItem(String id) {
    _firestoreService.deleteItem(id);
  }

  void _updateItem(String id) {
    _firestoreService.updateItem(
      id,
      _titleController.text,
      _descriptionController.text,
      _categoryController.text,
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navigasi ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BeritaKu"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Form untuk menambahkan berita
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Judul Berita'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi Berita'),
                ),
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Kategori'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addItem,
                  child: Text('Tambah Berita'),
                ),
              ],
            ),
          ),
          // Menampilkan berita dari Firestore
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getNews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final news = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    final item = news[index];
                    final itemId = item['id'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['category'] ?? 'No Category',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item['title'] ?? 'No Title',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item['description'] ?? 'No Description',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _titleController.text = item['title'] ?? '';
                                        _descriptionController.text = item['description'] ?? '';
                                        _categoryController.text = item['category'] ?? '';
                                        _updateItem(itemId);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _deleteItem(itemId),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Tombol Logout di bawah
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Tombol lebar penuh
              ),
            ),
          ),
        ],
      ),
    );
  }
}
