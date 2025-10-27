import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/db_helper.dart';
import '../models/pessoa.dart';

class ListaPessoasPage extends StatefulWidget {
  const ListaPessoasPage({super.key});

  @override
  State<ListaPessoasPage> createState() => _ListaPessoasPageState();
}

class _ListaPessoasPageState extends State<ListaPessoasPage> {
  List<Pessoa> pessoas = [];
  String filtro = '';

  @override
  void initState() {
    super.initState();
    carregarPessoas();
  }

  Future<void> carregarPessoas() async {
    final lista = await DBHelper().getPessoas(filtro: filtro);
    setState(() => pessoas = lista);
  }

  void abrirModal(Pessoa pessoa) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(pessoa.nome),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      pessoa.fotoPath != null
                          ? FileImage(File(pessoa.fotoPath!))
                          : AssetImage('lib/images/default.png')
                              as ImageProvider,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(pessoa.telefone),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: pessoa.telefone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Número copiado!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navegar para edição
                  Navigator.pushNamed(
                    context,
                    '/editar',
                    arguments: pessoa,
                  ).then((_) => carregarPessoas());
                },
                child: const Text('Editar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Pessoas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nome',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                filtro = v;
                carregarPessoas();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pessoas.length,
              itemBuilder: (context, index) {
                final p = pessoas[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        p.fotoPath != null
                            ? FileImage(File(p.fotoPath!))
                            : AssetImage('lib/images/default.png')
                                as ImageProvider,
                  ),
                  title: Text(p.nome),
                  subtitle: Text(p.telefone),
                  onTap: () => abrirModal(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
