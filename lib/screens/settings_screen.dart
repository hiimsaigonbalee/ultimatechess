import 'package:flutter/material.dart';

class ChessSettingsScreen extends StatefulWidget {
  const ChessSettingsScreen({super.key});

  @override
  _ChessSettingsScreenState createState() => _ChessSettingsScreenState();
}

class _ChessSettingsScreenState extends State<ChessSettingsScreen> {
  bool _isDarkTheme = false;
  String _selectedTimeControl = 'Blitz';
  bool _showValidMoves = true;
  bool _enableSound = true;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.blue[800],
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        color: _isDarkTheme ? Colors.grey[850] : Colors.white,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          children: [
            _buildSectionHeader('Giao diện'),
            _buildThemeSwitcher(),
            const Divider(),
            _buildSectionHeader('Thiết lập thời gian'),
            _buildDropdownTile(
              context,
              icon: Icons.timer,
              title: 'Kiểm soát thời gian',
              items: ['Blitz', 'Rapid', 'Classical'],
              selectedValue: _selectedTimeControl,
              onChanged: (value) {
                setState(() {
                  _selectedTimeControl = value!;
                });
              },
            ),
            const Divider(),
            _buildSectionHeader('Tùy chọn khác'),
            SwitchListTile(
              title: const Text('Hiển thị nước đi hợp lệ'),
              value: _showValidMoves,
              onChanged: (bool value) {
                setState(() {
                  _showValidMoves = value;
                });
              },
              activeColor: Colors.blue[300],
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Bật âm thanh'),
              value: _enableSound,
              onChanged: (bool value) {
                setState(() {
                  _enableSound = value;
                });
              },
              activeColor: Colors.blue[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher() {
    return GestureDetector(
      onTap: _toggleTheme,
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkTheme ? Colors.grey[700] : Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isDarkTheme ? 'Chế độ tối' : 'Chế độ sáng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isDarkTheme ? Colors.white : Colors.blue[900],
              ),
            ),
            Icon(
              _isDarkTheme ? Icons.nights_stay : Icons.wb_sunny,
              color: _isDarkTheme ? Colors.yellow : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required List<String> items,
        required String selectedValue,
        required Function(String?) onChanged,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: selectedValue,
        items: items
            .map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        ))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
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
          color: _isDarkTheme ? Colors.white : Colors.blue[800],
        ),
      ),
    );
  }
}