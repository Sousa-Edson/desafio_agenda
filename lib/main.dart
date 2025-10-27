import 'dart:io';

import 'package:desafio_agenda/db/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'pages/home_page.dart';
import 'models/pessoa.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desafio Agenda',
      // theme: ThemeData(primarySwatch: Colors.blue),
      theme: ThemeData(
        primarySwatch: Colors.orange, // Isso muda a cor principal
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange, // Cor da AppBar
          foregroundColor: Colors.white, // Cor do título e ícones
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Cor do botão
            foregroundColor: Colors.white, // Cor do texto
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
        scaffoldBackgroundColor: Colors.white, // Cor de fundo geral
      ),
      home: const HomePage(),
      routes: {'/editar': (context) => AdicionarPessoaPageEditar()},
    );
  }
}

// Tela de edição (reaproveitando AdicionarPessoaPage)
class AdicionarPessoaPageEditar extends StatefulWidget {
  const AdicionarPessoaPageEditar({super.key});

  @override
  State<AdicionarPessoaPageEditar> createState() =>
      _AdicionarPessoaPageEditarState();
}

class _AdicionarPessoaPageEditarState extends State<AdicionarPessoaPageEditar> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  XFile? foto;
  final ImagePicker picker = ImagePicker();
  Pessoa? pessoa;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(this.context)!.settings.arguments;
    if (arg != null && arg is Pessoa) {
      pessoa = arg;
      nomeController.text = pessoa!.nome;
      telefoneController.text = pessoa!.telefone;
      if (pessoa!.fotoPath != null) {
        foto = XFile(pessoa!.fotoPath!);
      }
    }
  }

  Future<void> pickImage() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => foto = picked);
  }

  Future<void> salvarPessoa() async {
    if (_formKey.currentState!.validate() && pessoa != null) {
      String? path = pessoa!.fotoPath;
      if (foto != null) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = basename(foto!.path);
        final savedPath = '${dir.path}/$fileName';
        await foto!.saveTo(savedPath);
        path = savedPath;
      }
      pessoa!.nome = nomeController.text;
      pessoa!.telefone = telefoneController.text;
      pessoa!.fotoPath = path;
      await DBHelper().updatePessoa(pessoa!);
      Navigator.pop(this.context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Pessoa')),
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
                onPressed: () {
                  salvarPessoa();
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
