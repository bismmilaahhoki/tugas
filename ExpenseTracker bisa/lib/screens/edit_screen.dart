import 'package:flutter/material.dart';
import 'package:praktikum_mobile/helpers/db_helper.dart';

class ExpenseFormScreen extends StatefulWidget {
  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _transactionType = 'Pengeluaran'; // Default value (Pengeluaran)
  String? _selectedCategory; // Nilai dropdown untuk kategori

  // Kategori berdasarkan jenis transaksi
  List<String> _expenseCategories = [
    'Makanan & Minuman',
    'Transportasi',
    'Hiburan',
    'Belanja',
  ]; // Kategori untuk Pengeluaran

  List<String> _incomeCategories = [
    'Gaji',
    'Investasi',
  ]; // Kategori untuk Pemasukan

  // Menyimpan transaksi ke database
  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text;
      double amount = double.tryParse(_amountController.text) ?? 0.0;

      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jumlah harus lebih besar dari nol')),
        );
        return;
      }

      final transaction = {
        'title': title,
        'amount': amount,
        'category': _selectedCategory ?? 'Lainnya',
        'type': _transactionType ?? 'Pengeluaran',
      };

      try {
        int result =
            await DatabaseHelper.instance.insertTransaction(transaction);
        print('Data berhasil disimpan dengan ID: $result');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
        // Reset form and state
        _formKey.currentState!.reset();
        setState(() {
          _transactionType = 'Pengeluaran';
          _selectedCategory = null;
        });
      } catch (e) {
        print('Gagal menyimpan transaksi: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Pengeluaran/Pemasukan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Pilihan Pengeluaran/Pemasukan (Dropdown)
              DropdownButtonFormField<String>(
                value: _transactionType,
                decoration: InputDecoration(
                  labelText: 'Pilih Jenis Transaksi',
                ),
                onChanged: (value) {
                  setState(() {
                    _transactionType = value;
                    // Update categories based on transaction type
                    if (_transactionType == 'Pengeluaran') {
                      _selectedCategory = null;
                      _expenseCategories = [
                        'Makanan & Minuman',
                        'Transportasi',
                        'Hiburan',
                        'Belanja',
                      ];
                    } else {
                      _selectedCategory = null;
                      _expenseCategories = [
                        'Gaji',
                        'Investasi',
                      ];
                    }
                  });
                },
                items: ['Pengeluaran', 'Pemasukan']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Pilih jenis transaksi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Input Judul
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul Transaksi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul transaksi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Input Jumlah
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Jumlah Rp'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Pilihan Kategori (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Pilih Kategori',
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                items: (_transactionType == 'Pengeluaran'
                        ? _expenseCategories
                        : _incomeCategories)
                    .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Pilih kategori transaksi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Tombol Simpan
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text('Simpan Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
