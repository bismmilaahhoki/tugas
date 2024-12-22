import 'package:flutter/material.dart';
import 'package:praktikum_mobile/helpers/db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper.instance.getTransactions();
    setState(() {
      _expenses = expenses;
    });
  }

  double _calculateTotal(String type) {
    return _expenses.fold<double>(0.0, (sum, expense) {
      final amount = (expense['amount'] ?? 0.0) as double;
      return expense['type'] == type ? sum + amount : sum;
    });
  }

  double _calculateBalance() {
    return _calculateTotal('Pemasukan') - _calculateTotal('Pengeluaran');
  }

  Future<void> _deleteExpense(int id) async {
    final confirm = await _showConfirmationDialog();
    if (confirm == true) {
      await DatabaseHelper.instance.deleteTransaction(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi berhasil dihapus'), backgroundColor: Colors.green),
      );
      _loadExpenses();
    }
  }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Transaksi'),
        content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus')),
        ],
      ),
    );
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense['title'] ?? 'Tanpa Judul'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jumlah: Rp ${expense['amount'] ?? 0.0}'),
            Text('Kategori: ${expense['category'] ?? 'Tidak Ada'}'),
            Text('Jenis: ${expense['type'] ?? 'Tidak Ada'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _calculateBalance();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatCard('Total Pemasukan', _calculateTotal('Pemasukan'), Colors.green),
                SizedBox(width: 16),
                _buildStatCard('Total Pengeluaran', _calculateTotal('Pengeluaran'), Colors.red),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Saldo Anda: Rp ${balance.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _expenses.isEmpty
                  ? Center(child: Text('Tidak ada pengeluaran', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return _buildExpenseCard(expense);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/edit').then((value) => _loadExpenses()),
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
              SizedBox(height: 8),
              Text('Rp ${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          Icons.attach_money,
          color: expense['type'] == 'Pengeluaran' ? Colors.red : Colors.green,
        ),
        title: Text(expense['title']),
        subtitle: Text('Rp ${expense['amount']} - ${expense['type']}'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteExpense(expense['id']),
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }
}
