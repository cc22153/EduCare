import 'package:flutter/material.dart';
import 'Questionario.dart';
import 'Rotina.dart';
import 'Contatos.dart';
import 'ResumoDiario.dart';
import 'Notificacoes.dart';
import '/Telas/login.dart';
import 'EditarDadosResponsavel.dart';

class InicioResponsavel extends StatefulWidget {
  const InicioResponsavel({super.key});

  @override
  State<InicioResponsavel> createState() => InicioResponsavelState();
}

class InicioResponsavelState extends State<InicioResponsavel> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      mostrarPopUpQuestionario();
    });
  }

  void mostrarPopUpQuestionario() {
    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text('Questionário'),
          
          content: const Text(
              'Agora responda um questionário rápido sobre seu filho(a) para que o app seja mais personalizado.'),
          actions: [
            TextButton(
            onPressed: () {
              Navigator.pop(context); 
            },
            child: const Text('FECHAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Questionario()),
              ); // Vai para a tela do questionário
              },
              child: const Text('RESPONDER'),
            ),
          ],
        );
      },
    );
  }

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditarDadosResponsavel()),
              ); 
              },
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            botaoPadrao('RESUMO DIÁRIO', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResumoDiario()),
              );
            }),
            const SizedBox(height: 20),
            botaoPadrao('ROTINA', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Rotina()),
              );
            }),
            const SizedBox(height: 20),
            botaoPadrao('NOTIFICAÇÕES', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notificacoes()),
              );
            }),
            const SizedBox(height: 20),
            botaoPadrao('CONTATOS', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Contatos()),
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
