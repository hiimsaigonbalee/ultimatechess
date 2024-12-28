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
  final _countryController = TextEditingController();
  final _gamesPlayedController = TextEditingController();
  final _gamesWonController = TextEditingController();
  final _eloController = TextEditingController();

  File? _avatar;
  String? _avatarUrl;
  bool _isLoading = false;

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
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _countryController.text = data['country'] ?? '';
            _gamesPlayedController.text = data['gamesPlayed']?.toString() ?? '0';
            _gamesWonController.text = data['gamesWon']?.toString() ?? '0';
            _eloController.text = data['elo']?.toString() ?? '0';
            _avatarUrl = data['avatarUrl'];
          });
        } else {
          _showSnackBar('Không tìm thấy thông tin người dùng.');
        }
      } catch (e) {
        _showSnackBar('Lỗi khi tải thông tin người dùng: $e');
      }
    } else {
      _showSnackBar('Không tìm thấy người dùng.');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null) {
      _showSnackBar('Bạn cần đăng nhập để lưu thông tin.');
      return;
    }

    if (_nameController.text.isEmpty || _countryController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? avatarUrl = _avatarUrl;

    if (_avatar != null) {
      final ref =
      FirebaseStorage.instance.ref().child('avatars').child('${user.uid}.jpg');
      try {
        await ref.putFile(_avatar!);
        avatarUrl = await ref.getDownloadURL();
      } catch (e) {
        _showSnackBar('Lỗi khi tải ảnh lên: $e');
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'country': _countryController.text,
        'gamesPlayed': int.tryParse(_gamesPlayedController.text) ?? 0,
        'gamesWon': int.tryParse(_gamesWonController.text) ?? 0,
        'elo': int.tryParse(_eloController.text) ?? 0,
        'avatarUrl': avatarUrl,
      }, SetOptions(merge: true));

      _showSnackBar('Lưu thông tin thành công!');
    } catch (e) {
      _showSnackBar('Lỗi khi lưu thông tin: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông Tin Người Chơi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: _avatar != null
                            ? FileImage(_avatar!)
                            : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
                        child: (_avatar == null && _avatarUrl == null)
                            ? const Icon(Icons.person, size: 70, color: Colors.grey)
                            : null,
                        backgroundColor: Colors.grey[200],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blueAccent,
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildInputCard(_nameController, 'Tên', Icons.person),
                const SizedBox(height: 20),
                _buildInputCard(_countryController, 'Quốc gia', Icons.flag),
                const SizedBox(height: 20),
                _buildInputCard(_gamesPlayedController, 'Số game đã chơi',
                    Icons.sports_esports,
                    isNumeric: true),
                const SizedBox(height: 20),
                _buildInputCard(
                    _gamesWonController, 'Số game đã thắng', Icons.emoji_events,
                    isNumeric: true),
                const SizedBox(height: 20),
                _buildInputCard(_eloController, 'Elo', Icons.star,
                    isNumeric: true),
                if (_isLoading)
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _saveUserProfile,
        child: const Icon(Icons.save),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Lưu thông tin',
      ),
    );
  }

  Widget _buildInputCard(TextEditingController controller, String label,
      IconData icon,
      {bool isNumeric = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: InputBorder.none,
          ),
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _gamesPlayedController.dispose();
    _gamesWonController.dispose();
    _eloController.dispose();
    super.dispose();
  }
}