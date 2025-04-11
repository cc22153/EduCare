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

          padding: const EdgeInsets.all(16.0),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Image.asset('lib/images/logo.png', height: 300),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Usuário', 
                  labelStyle: TextStyle(
                    color: Colors.white
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2)
                  )
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(
                    color: Colors.white
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2)
                  )
                ),
                obscureText: true,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton( 
                  onPressed: () {  
                    Navigator.push(  
                      context, 
                      MaterialPageRoute(
                        builder: (context) => const InicioAluno(),
                      ),
                    );
                  },
                  child: const Text('ENTRAR')
                ),
              ),

              const SizedBox(height: 5),

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
