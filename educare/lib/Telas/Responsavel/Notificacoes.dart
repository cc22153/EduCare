import 'package:flutter/material.dart';

class Notificacoes extends StatefulWidget {
  const Notificacoes({super.key});

  @override
  State<Notificacoes> createState() => _NotificacoesState();
}

class _NotificacoesState extends State<Notificacoes> {
  List<bool> lido = [false, false]; 
  bool estaBem = true;
  bool mostrarHumor = true; 
  bool mostrarAtividade = true;
  bool mostrarRelatorio = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (mostrarHumor) ...[
              const Text(
                'Como seu filho(a) está se sentindo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: estaBem ? Colors.green[300] : Colors.red[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  estaBem ? 'Estou bem!' : 'Não estou bem.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    mostrarHumor = false;
                  });
                },
                child: const Text('Visto'),
              ),
              const SizedBox(height: 20),
            ],

            if (mostrarAtividade) ...[
              const Text(
                'Atividades a serem realizadas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  title: const Text('Há uma atividade a ser realizada.'),
                  trailing: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      setState(() {
                        mostrarAtividade = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (mostrarRelatorio) ...[
              const Text(
                'Relatório da Professora:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  title: const Text(
                      'Hoje o aluno participou muito bem das atividades e se comportou de forma exemplar.'),
                  trailing: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      setState(() {
                        mostrarRelatorio = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
