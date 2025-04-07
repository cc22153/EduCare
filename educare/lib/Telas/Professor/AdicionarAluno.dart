import 'package:flutter/material.dart';

class Adicionaraluno extends StatefulWidget {
  const Adicionaraluno({super.key});

  @override
  State<Adicionaraluno> createState() => AdicionarAlunoState();
}

class AdicionarAlunoState extends State<Adicionaraluno> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController turmaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Cadastro Aluno'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Aluno (a):',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: turmaController,
              decoration: const InputDecoration(
                labelText: 'Turma:',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Responsável:',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aqui você pode salvar o aluno
              },
              child: const Text('ADICIONAR'),
            ),
          ],
        ),
      ),
    );
  }
}
