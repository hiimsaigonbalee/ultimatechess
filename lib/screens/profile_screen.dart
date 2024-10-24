import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _gamesPlayedController = TextEditingController();
  final _gamesWonController = TextEditingController();
  final _eloController = TextEditingController();

  File? _avatar; // Biến này dùng để lưu trữ ảnh đại diện

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _countryController.text = data['country'] ?? '';
          _gamesPlayedController.text = data['gamesPlayed']?.toString() ?? '0';
          _gamesWonController.text = data['gamesWon']?.toString() ?? '0';
          _eloController.text = data['elo']?.toString() ?? '0';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path); // Lưu trữ ảnh đại diện cục bộ
      });
    }
  }

  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Cập nhật thông tin người dùng trong Firestore mà không có _avatarUrl
    await _firestore.collection('users').doc(user.uid).set({
      'name': _nameController.text,
      'email': _emailController.text,
      'country': _countryController.text,
      'gamesPlayed': int.tryParse(_gamesPlayedController.text) ?? 0,
      'gamesWon': int.tryParse(_gamesWonController.text) ?? 0,
      'elo': int.tryParse(_eloController.text) ?? 0,
      // Bỏ qua avatarUrl
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'THÔNG TIN NGƯỜI CHƠI',
          style: TextStyle(
            fontFamily: 'Dancing Script',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        backgroundColor: Colors.blue[200],
        iconTheme: IconThemeData(
          color: Colors.white, // Đổi màu nút "Back"
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Center( // Sử dụng Center để căn giữa
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
              crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60, // Tăng kích thước avatar
                        backgroundImage: _avatar != null
                            ? FileImage(_avatar!) // Hiển thị ảnh đại diện cục bộ
                            : null,
                        child: (_avatar == null)
                            ? Icon(Icons.add_a_photo, size: 60, color: Colors.white)
                            : null,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 150),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: 'Quốc gia',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _gamesPlayedController,
                  decoration: InputDecoration(
                    labelText: 'Số game đã chơi',
                    prefixIcon: Icon(Icons.sports_esports),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _gamesWonController,
                  decoration: InputDecoration(
                    labelText: 'Số game đã thắng',
                    prefixIcon: Icon(Icons.emoji_events),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _eloController,
                  decoration: InputDecoration(
                    labelText: 'Elo',
                    prefixIcon: Icon(Icons.star),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _gamesPlayedController.dispose();
    _gamesWonController.dispose();
    _eloController.dispose();
    super.dispose();
  }
}

