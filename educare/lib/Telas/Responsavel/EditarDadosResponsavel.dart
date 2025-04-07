import 'package:flutter/material.dart';

class EditarDadosResponsavel extends StatefulWidget {
  const EditarDadosResponsavel({super.key});

  @override
  State<EditarDadosResponsavel> createState() => EditarDadosResponsavelState();
}

class EditarDadosResponsavelState extends State<EditarDadosResponsavel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Editar Dados'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'Usuário')),
              const TextField(decoration: InputDecoration(labelText: 'Email')),
              const TextField(decoration: InputDecoration(labelText: 'Telefone')),
              const TextField(decoration: InputDecoration(labelText: 'Senha')),
              const TextField(decoration: InputDecoration(labelText: 'Nome do filho(a)')),
              const TextField(decoration: InputDecoration(labelText: 'Usuário')),
              const TextField(decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
              const TextField(decoration: InputDecoration(labelText: 'Idade'), keyboardType: TextInputType.number),
              const TextField(decoration: InputDecoration(labelText: 'Turma')),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[300],
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                ),
                child: const Text('ATUALIZAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
