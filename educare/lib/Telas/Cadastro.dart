import 'package:flutter/material.dart';
import 'Responsavel/PosCadastro.dart';
import 'Professor/InicioProfessor.dart';

class Cadastro extends StatefulWidget {

  const Cadastro({super.key});

@override
  State<Cadastro> createState() => CadastroState();
}

class CadastroState extends State<Cadastro> {
  
  String tipoUsuario = ""; // variavel criada por enquanto

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
            const Text('Você é:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton(
                  
                  onPressed: () {
                   setState(() {
                  tipoUsuario = "Educador";
                   });
                   },
                  child: const Text('EDUCADOR'),
                ),

                ElevatedButton(
                    onPressed: () {
                setState(() {
                  tipoUsuario = "Responsavel";
                  });
                 },
                child: const Text('RESPONSÁVEL'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (tipoUsuario.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, selecione se você é Educador ou Responsável.'),
                    ),
                  );
                } else {
                  if (tipoUsuario == "Educador") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InicioProfessor()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PosCadastro()),
                    );
                  }
                }
              },
              child: const Text('CADASTRAR'),
            ),
          ],
        ),
      ),
    );
  }
}