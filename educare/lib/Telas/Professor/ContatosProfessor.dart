import 'package:flutter/material.dart';

class ContatosProfessor extends StatelessWidget {
  const ContatosProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('CONTATOS'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            contatoCard(),
          ],
        ),
      ),
    );
  }

  Widget contatoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nome do Aluno\nSérie X\n\nRESPONSÁVEL : (xx) xxxxx-xxxx\n EMAIL: JOÃOZINHO123@gmail',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
