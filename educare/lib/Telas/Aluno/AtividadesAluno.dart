import 'package:flutter/material.dart';

class AtividadesAluno extends StatelessWidget {

  const AtividadesAluno({super.key});

  final String atividade = 'Resolver as atividades da página 10 do livro.';
  final String comentario = 'Pode resolver com calma, se precisar, pode pedir ajuda para seus pais. Entregar dia 07/08';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('ATIVIDADES'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const SizedBox(height: 20),
            const Text(
              'Professora Ana enviou uma atividade',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Atividade:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                atividade.isNotEmpty ? atividade : 'Nenhuma atividade disponível.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Comentários:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                comentario.isNotEmpty ? comentario : 'Nenhum comentário disponível.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),

            
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Atividade marcada como concluída!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[400],
              ),
              child: const Text(
                'CONCLUÍDA',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
