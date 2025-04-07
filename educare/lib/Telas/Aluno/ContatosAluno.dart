import 'package:flutter/material.dart';

class ContatosAluno extends StatelessWidget {
  const ContatosAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('CONTATOS'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contato('Professor(a): Maria', 'maria@escola.com', '(11) 99999-9999'),
            const Divider(),

            contato('Coordenador(a): João', 'joao@escola.com', '(11) 98888-8888'),
            const Divider(),

            contato('Psicóloga: Ana', 'ana@escola.com', '(11) 97777-7777'),
            const Divider(),

            contato('Orientador(a): Pedro', 'pedro@escola.com', '(11) 96666-6666'),
          ],
        ),
      ),
    );
  }

  Widget contato(String nome, String email, String telefone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nome,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.email, size: 20),
            const SizedBox(width: 5),
            Text(email),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.phone, size: 20),
            const SizedBox(width: 5),
            Text(telefone),
          ],
        ),
      ],
    );
  }
}
