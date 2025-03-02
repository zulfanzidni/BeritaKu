import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Menambahkan image_picker
import 'package:firebase_storage/firebase_storage.dart'; // Menambahkan firebase_storage
import 'dart:io'; // Untuk file gambar
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
  File? _imageFile; // Menyimpan file gambar yang dipilih
  final ImagePicker _picker = ImagePicker(); // Untuk memilih gambar

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengupload gambar ke Firebase Storage
  Future<String?> _uploadImage() async {
    if (_imageFile != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await imageRef.putFile(_imageFile!);
        String downloadURL = await imageRef.getDownloadURL();
        return downloadURL; // Mengembalikan URL gambar
      } catch (e) {
        print("Error uploading image: $e");
        return null;
      }
    }
    return null;
  }

  void _addItem() async {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      // Upload gambar dan dapatkan URL-nya
      String? imageUrl = await _uploadImage();
      
      // Simpan data ke Firestore, termasuk URL gambar
      _firestoreService.addItem(
        _titleController.text,
        _descriptionController.text,
        _categoryController.text,
        imageUrl, // Menyimpan URL gambar
      );

      _titleController.clear();
      _descriptionController.clear();
      _categoryController.clear();
      setState(() {
        _imageFile = null; // Reset gambar setelah menambah item
      });
    }
  }

  void _deleteItem(String id) {
    _firestoreService.deleteItem(id);
  }

  void _updateItem(String id) async {
    // Upload gambar jika ada perubahan gambar
    String? imageUrl = await _uploadImage();
    
    _firestoreService.updateItem(
      id,
      _titleController.text,
      _descriptionController.text,
      _categoryController.text,
      imageUrl, // Update URL gambar
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
                // Tombol untuk memilih gambar
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pilih Gambar'),
                ),
                // Menampilkan gambar yang dipilih (preview)
                _imageFile != null
                    ? Image.file(_imageFile!, height: 150, width: 150)
                    : Text('Tidak ada gambar yang dipilih'),
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
            child: StreamBuilder<List<Map<String, dynamic>>>( // Menampilkan berita
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
                                item['imageUrl'] != null
                                    ? Image.network(item['imageUrl'], height: 150, width: 150) // Menampilkan gambar dari URL
                                    : SizedBox.shrink(),
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
