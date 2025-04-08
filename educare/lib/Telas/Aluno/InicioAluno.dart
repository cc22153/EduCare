import 'package:flutter/material.dart';
import '/Telas/Login.dart';
import 'DiarioAluno.dart';
import 'EstadoEmocional.dart';
import 'AtividadesAluno.dart';
import 'ContatosAluno.dart';

class InicioAluno extends StatefulWidget {
  const InicioAluno({super.key});

  @override
  State<InicioAluno> createState() => InicioAlunoState();
}

class InicioAlunoState extends State<InicioAluno> {
  @override
  void initState() {
    super.initState();
  
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.lightBlue[100],

      appBar: AppBar(  title: Align(alignment: Alignment.centerLeft, child: Text('Início'), ),

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
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context); 
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              ); 
              },
            ),
          ],
        ),
      ),
        body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            botaoPadrao('DIÁRIO', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiarioAluno()),
              );
            }),
            const SizedBox(height: 50),
            botaoPadrao('ESTADO EMOCIONAL', () {
              Navigator.push(
                context,
               MaterialPageRoute(builder: (context) => const EstadoEmocional()),
              );
            }),
            const SizedBox(height: 50),
            botaoPadrao('ATIVIDADES', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AtividadesAluno()),
              );
            }),
            const SizedBox(height: 50),
            botaoPadrao('CONTATOS', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContatosAluno()),
              );
            }),
          ],
        ),
      ),
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
