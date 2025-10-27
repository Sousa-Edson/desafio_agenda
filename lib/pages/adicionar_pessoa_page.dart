import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/db_helper.dart';
import '../models/pessoa.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class AdicionarPessoaPage extends StatefulWidget {
  const AdicionarPessoaPage({super.key});

  @override
  State<AdicionarPessoaPage> createState() => _AdicionarPessoaPageState();
}

class _AdicionarPessoaPageState extends State<AdicionarPessoaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  XFile? foto;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => foto = picked);
    }
  }

  Future<void> salvarPessoa() async {
    if (_formKey.currentState!.validate()) {
      String? path;
      if (foto != null) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = basename(foto!.path);
        final savedPath = '${dir.path}/$fileName';
        await foto!.saveTo(savedPath);
        path = savedPath;
      }
      final pessoa = Pessoa(
        nome: nomeController.text,
        telefone: telefoneController.text,
        fotoPath: path,
      );
      await DBHelper().insertPessoa(pessoa);
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('Pessoa adicionada!')));
      nomeController.clear();
      telefoneController.clear();
      setState(() => foto = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Pessoa')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      foto != null
                          ? FileImage(File(foto!.path))
                          : AssetImage('lib/images/default.png')
                              as ImageProvider,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Digite o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Digite o telefone' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: salvarPessoa,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
