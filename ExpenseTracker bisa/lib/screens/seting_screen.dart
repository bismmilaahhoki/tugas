import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true; // Untuk menampilkan loading state
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'John Doe';
      _isLoading = false; // Loading selesai
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus semua data
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showEditUserNameDialog() {
    final nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah Nama Pengguna'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: 'Masukkan nama pengguna baru'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final newUserName = nameController.text.trim();
              if (newUserName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nama pengguna tidak boleh kosong')),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', newUserName);
              setState(() {
                _userName = newUserName;
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Nama pengguna berhasil diperbarui')),
              );
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildUserNameTile(),
                  Divider(),
                  _buildLogoutTile(context),
                ],
              ),
            ),
    );
  }

  Widget _buildUserNameTile() {
    return ListTile(
      title: Text('Nama Pengguna'),
      subtitle: Text(_userName),
      trailing: Icon(Icons.edit),
      onTap: _showEditUserNameDialog,
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      title: Text('Keluar'),
      trailing: Icon(
        Icons.exit_to_app,
        color: Colors.redAccent,
      ),
      onTap: () => _logout(context),
    );
  }
}
