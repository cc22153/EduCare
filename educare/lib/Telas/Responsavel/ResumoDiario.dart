import 'package:flutter/material.dart';

class ResumoDiario extends StatelessWidget {
  
  const ResumoDiario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Text('RESUMO DIÁRIO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Essas foram as respostas que seu filho respondeu sobre o dia de hoje:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            Row(
              children: const [
                Text('Como se sentiu: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('😐 Neutro', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: const [
                Text('Atenção na aula: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Não', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),

           Row(
              children: const [
                Text('Opinião sobre as atividades: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Achei algumas faceis e \n outras dificeis', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
