import 'package:flutter/material.dart';

class EditarDadosResponsavel extends EditarDadosResponsavel {
  const EditarDadosResponsavel({super.key});

  @override
  State<EditarDadosResponsavel> createState() => EditarDadosResponsavelState();
}

class EditarDadosResponsavelState extends State<EditarDadosResponsavel> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Usuário')),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const TextField(decoration: InputDecoration(labelText: 'Telefone')),
            const TextField(decoration: InputDecoration(labelText: 'Senha')),
            const SizedBox(height: 20),
        
            const SizedBox(height: 30),
            ElevatedButton(
             Navigator.pop(context);

              child: const Text('ATUALIZAR'),
            ),
          ],
        ),
      ),
    );
  }
}
