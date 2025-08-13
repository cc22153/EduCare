import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/Telas/Login.dart';
import 'Alunos.dart';
import 'NotificacoesProfessor.dart';
import 'ContatosProfessor.dart';
import 'EditarDadosProfessor.dart';

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

      appBar: AppBar(  title: const Align(alignment: Alignment.centerLeft, child: Text('Início'), ),
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
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditarDadosProfessor() ),
              );
              },
            ),
                        ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Login()),
                  (Route<dynamic> route) => false, // remove todas as rotas anteriores
                );
              },
            ),
              ListTile(
        leading: const Icon(Icons.delete_forever),
        title: const Text('Excluir Conta'),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Excluir Conta'),
                content: const Text(
                    'Tem certeza que deseja excluir sua conta? Esta ação não poderá ser desfeita.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                     
                      Navigator.pop(context); 
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                   child: const Text('Excluir'),
                  ),
                ],
              );
            },
          );
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

      const SizedBox(height: 50),
            botaoPadrao('ALUNOS', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Alunos()),
              );
            }),
  
     const SizedBox(height: 50),
            botaoPadrao('NOTIFICAÇÕES', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificacoesProfessor()),
              );
            }),

      const SizedBox(height: 50),
            botaoPadrao('CONTATOS', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContatosProfessor()),
              );
            }),
      ],
     ),
    )
    );
  } 

  Widget botaoPadrao(String texto, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, 
      height: 60, 
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

