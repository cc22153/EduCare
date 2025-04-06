import 'package:flutter/material.dart';
//import 'TelaAtividades.dart';

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
  final TextEditingController observacoesController = TextEditingController();
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
            TextField(
              controller: observacoesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escreva as observações...',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Relatório do dia/Semana:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: relatorioController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escreva o relatório...',
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[300]),
                  onPressed: () {
                    Navigator.pop(context); // Apenas volta
                  },
                  child: const Text('CONCLUIR'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[300]),
                  onPressed: () {
                  ///  Navigator.push(
              //        context,
              //        MaterialPageRoute(
                 //         builder: (context) => const TelaAtividades()),
               //     );
                  },
                  child: const Text('ATIVIDADES'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
