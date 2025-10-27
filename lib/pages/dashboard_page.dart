import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalPessoas = 0;

  @override
  void initState() {
    super.initState();
    carregarTotal();
  }

  Future<void> carregarTotal() async {
    final count = await DBHelper().countPessoas();
    setState(() => totalPessoas = count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total de Pessoas', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                Text(
                  '$totalPessoas',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
