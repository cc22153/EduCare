import 'package:flutter/material.dart';
import 'InicioResponsavel.dart';

class Questionario extends StatelessWidget {
  const Questionario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Text('Questionário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _pergunta('Qual o nível do autismo do seu filho(a)?'),
            _pergunta('Qual costuma ser o comportamento dele(a)? (Ex: agitado, quieto...)'),
            _pergunta('Quais são as atividades favoritas dele(a)?'),
            _pergunta('Quais são os principais gatilhos? (Ex: barulho...)'),
            _pergunta('Como a criança costuma se comunicar?'),
            _pergunta('Ele(a) tem alguma sensibilidade sensorial? (Ex: sons, textura, etc)'),
            _pergunta('Há algum tipo de interação social que a criança prefira ou evite?'),
            _pergunta('Quais são as melhores estratégias de ensino para essa criança?'),
            _pergunta('Existem dificuldades em alguma área acadêmica?'),
            _pergunta('A criança tem algum plano de tratamento específico que deve ser seguido?'),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                
               Navigator.push(

                   context,

                   MaterialPageRoute(

                    builder: (context) => const InicioResponsavel(),
                  ),
               );
              },
              child: const Text('ENVIAR QUESTIONÁRIO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pergunta(String texto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
