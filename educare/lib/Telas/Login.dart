import 'package:flutter/material.dart';
import 'Cadastro.dart';


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
            children: [
              Image.asset('images/logo.png', height: 100),
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(labelText: 'Usuário'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {},
                child: Text('ENTRAR'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                   context,
                   MaterialPageRoute(
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
