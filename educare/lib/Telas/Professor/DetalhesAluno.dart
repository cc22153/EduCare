import 'package:flutter/material.dart';
import 'AtividadesProfessor.dart';

class DetalhesAluno extends StatefulWidget {
  final String nomeAluno;
  final String turmaAluno;

  const DetalhesAluno({
    super.key,
    required this.nomeAluno,
    required this.turmaAluno,
  });

  @override
  State<DetalhesAluno> createState() => _DetalhesAlunoState();
}

class _DetalhesAlunoState extends State<DetalhesAluno> {
  final TextEditingController relatorioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: Text(widget.nomeAluno),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Série: ${widget.turmaAluno}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            const Text('Observações:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Nenhuma observação disponível.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Relatório do dia/Semana:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: relatorioController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escreva o relatório...',
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AtividadesProfessor()),
                    );
              },
              child: const Text('ATIVIDADES'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('CONCLUIR'),
            ),
          ],
        ),
      ),
    );
  }
}
