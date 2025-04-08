import 'package:educare/Telas/Responsavel/Rotina.dart';
import 'package:flutter/material.dart';
import 'Cadastro.dart';
import 'Aluno/InicioAluno.dart';

class Login extends StatelessWidget {

  const Login({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.lightBlue[100],

      body: Center(

        child: Padding(

          padding: EdgeInsets.all(16.0),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const SizedBox(height: 40),
              Image.asset('lib/images/logo.png', height: 300),

              const TextField(
                decoration: InputDecoration(labelText: 'Usuário'),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),

               const SizedBox(height: 30),

              ElevatedButton( onPressed: () {  Navigator.push(  context, MaterialPageRoute(
               builder: (context) => const InicioAluno(),
                ),
               );
              },
                child: Text('ENTRAR'),
              ),

               const SizedBox(height: 20),

              TextButton(
                onPressed: () { Navigator.push( context, MaterialPageRoute(

                builder: (context) => const Cadastro(),
                  ),
               );
               },
                child: const Text('Não tem uma conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
