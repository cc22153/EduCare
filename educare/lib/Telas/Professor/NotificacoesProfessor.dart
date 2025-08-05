import 'package:flutter/material.dart';

class NotificacoesProfessor extends StatefulWidget {
  const NotificacoesProfessor({super.key});

  @override
  State<NotificacoesProfessor> createState() => _NotificacoesProfessorState();
}

class _NotificacoesProfessorState extends State<NotificacoesProfessor> {
  bool visto = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('NOTIFICAÇÕES'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!visto)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nome do Aluno\nSérie X\n\nEstou mal, preciso de ajuda.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  visto = true;
                });
              },
              child: const Text('VISTO'),
            ),
          ],
        ),
      ),
    );
  }
}
