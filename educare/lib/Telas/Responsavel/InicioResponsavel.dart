import 'package:flutter/material.dart';
import 'Questionario.dart';
import 'Rotina.dart';
import 'Contatos.dart';

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
              Navigator.pop(context); // Fecha o pop-up
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
      body: Padding(
        padding: const EdgeInsets.all(90),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza os botões
          children: [
            botaoPadrao('RESUMO DIÁRIO', () {}),

            const SizedBox(height: 20),
            botaoPadrao('ROTINA', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Rotina()),
              );
            }),

            const SizedBox(height: 20),
            botaoPadrao('NOTIFICAÇÕES', () {}),

            const SizedBox(height: 20),
            botaoPadrao('CONTATO COM O PROFESSOR', () {
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

  // Função para criar botão padrão
  Widget botaoPadrao(String texto, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, // Preenche toda a largura disponível
      height: 60, // Altura do botão
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
