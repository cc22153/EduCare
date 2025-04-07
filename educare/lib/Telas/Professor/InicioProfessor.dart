import 'package:flutter/material.dart';
import '/Telas/Cadastro.dart';
import '/Telas/Login.dart';
import 'Alunos.dart';
import 'AtividadesProfessor.dart';
import 'NotificacoesProfessor.dart';
import 'ContatosProfessor.dart';

class InicioProfessor extends StatefulWidget {
  const InicioProfessor({super.key});

  @override
  State<InicioProfessor> createState() => InicioProfessorState();
}

class InicioProfessorState extends State<InicioProfessor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Início'),
        backgroundColor: Colors.lightBlue[300],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Dados'),
              onTap: () {
                Navigator.pop(context); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context); 
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            botaoPadrao('ALUNOS', () {
               Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Alunos()),
                    );
            }),
         
            const SizedBox(height: 20),
            botaoPadrao('NOTIFICAÇÕES', () {
               Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificacoesProfessor()),
                    );
            }),
            const SizedBox(height: 20),
            botaoPadrao('CONTATOS', () {
              Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContatosProfessor()),
                    );
              Navigator.pop(context); 
            }),
          ],
        ),
      ),
    );
  }

  Widget botaoPadrao(String texto, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue[300],
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      onPressed: onPressed,
      child: Text(
        texto,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
