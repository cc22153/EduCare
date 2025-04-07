import 'package:flutter/material.dart';

class DiarioAluno extends StatefulWidget {
  const DiarioAluno({super.key});

  @override
  State<DiarioAluno> createState() => _DiarioAlunoState();
}

class _DiarioAlunoState extends State<DiarioAluno> {

  String? emocaoSelecionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Text('DIÁRIO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Como você se sentiu hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                emocaoButton('😊', 'Feliz'),
                emocaoButton('😐', 'Neutro'),
                emocaoButton('😢', 'Triste'),
                emocaoButton('😠', 'Irritado'),
                emocaoButton('😰', 'Ansioso'),
                emocaoButton('😴', 'Cansado'),
              ],
            ),
             const SizedBox(height: 20),
            const Text('Você conseguiu prestar atenção na aula hoje?'),
            TextField(
              onChanged: (value) {
    
              },
            ),
            const SizedBox(height: 20),
            const Text('O que achou das atividades que a professora passou?'),
            TextField(
              onChanged: (value) {
           
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
              ),
              onPressed: () {
                if (emocaoSelecionada != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Resposta enviada!')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selecione uma emoção!')),
                  );
                }
              },
              child: const Text('ENVIAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget emocaoButton(String emoji, String emocao) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              emocaoSelecionada = emocao;
            });
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(15),
            backgroundColor: emocaoSelecionada == emocao
                ? Colors.lightBlue[300]
                : Colors.white,
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
        ),
        Text(
          emocao,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
