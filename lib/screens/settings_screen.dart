import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class ChessSettingsScreen extends StatefulWidget {
  const ChessSettingsScreen({super.key});

  @override
  _ChessSettingsScreenState createState() => _ChessSettingsScreenState();
}

class _ChessSettingsScreenState extends State<ChessSettingsScreen> {
  bool _isDarkTheme = false;
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('Light'); // Mặc định là Light
  }

  @override
  void dispose() {
    _controller.dispose(); // Dừng controller khi không còn sử dụng
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;

      // Dừng hoạt ảnh hiện tại
      _controller.isActive = false;

      // Cập nhật controller với hoạt ảnh tương ứng
      _controller = SimpleAnimation(_isDarkTheme ? 'Day_to_night' : 'Night_to_day');

      // Kích hoạt lại controller
      _controller.isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CÀI ĐẶT',
          style: TextStyle(
            fontFamily: 'Dancing Script',
            fontSize: 20,
            fontWeight: FontWeight.bold,// Đổi kiểu chữ thành Dancing Script
            color: Colors.white,           // Đổi màu chữ thành trắng
          ),
        ),
        backgroundColor: _isDarkTheme ? Colors.blue[200] : Colors.blue[800],
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, // Đổi màu nút "Back"
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        children: [
          _buildSectionHeader('Giao diện'),
          _buildRiveThemeSwitcher(),
          Divider(),
          _buildSectionHeader('Thiết lập thời gian'),
          _buildDropdownTile(
            context,
            icon: Icons.timer,
            title: 'Kiểm soát thời gian',
            items: ['Blitz', 'Rapid', 'Classical'],
            onChanged: (value) {},
          ),
          Divider(),
          _buildSectionHeader('Tùy chọn khác'),
          SwitchListTile(
            title: Text('Hiển thị nước đi hợp lệ'),
            value: true,
            onChanged: (bool value) {},
            activeColor: Colors.blue[200],
          ),
          Divider(),
          SwitchListTile(
            title: Text('Bật âm thanh'),
            value: true,
            onChanged: (bool value) {},
            activeColor: Colors.blue[300],
          ),
        ],
      ),
    );
  }

  Widget _buildRiveThemeSwitcher() {
    return GestureDetector(
      onTap: _toggleTheme,
      child: SizedBox(
        height: 100,
        child: RiveAnimation.asset(
          'assets/switch/switch_button.riv', // Đường dẫn tới file Rive của bạn
          controllers: [_controller],
          // Thêm điều kiện kiểm tra hoạt ảnh nếu cần
          fit: BoxFit.cover, // Giúp hiển thị toàn bộ nội dung
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required List<String> items,
        required Function(String?) onChanged,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: DropdownButton<String>(
        items: items
            .map((item) => DropdownMenuItem(
          value: item.toLowerCase(),
          child: Text(item),
        ))
            .toList(),
        onChanged: onChanged,
        underline: SizedBox(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[200],
        ),
      ),
    );
  }
}
