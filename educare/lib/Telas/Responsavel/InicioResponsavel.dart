import 'package:flutter/material.dart';
import 'Questionario.dart';
import 'Rotina.dart';

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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('RESUMO DIÁRIO')),

            ElevatedButton(onPressed: () // vai para tela Rotina
            { 
              Navigator.push( context,
              MaterialPageRoute(builder: (context) => const Rotina(),), );}, child: const Text('ROTINA')),
          
            ElevatedButton(onPressed: () {}, child: const Text('NOTIFICAÇÕES')),
          
            ElevatedButton(onPressed: () {}, child: const Text('CONTATO COM O PROFESSOR')),
          ],
        ),
      ),
    );
  }
}
