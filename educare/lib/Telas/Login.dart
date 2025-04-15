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
              Image.asset('assets/images/logo.png', height: 300),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  floatingLabelStyle: TextStyle(
                      color: Color(0xFF009ADA), fontWeight: FontWeight.bold),
                  labelStyle: TextStyle(
                    color: Color(0xFF009ADA),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF009ADA), width: 1.3)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF009ADA), width: 2)),
                ),
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  floatingLabelStyle: TextStyle(
                      color: Color(0xFF009ADA), fontWeight: FontWeight.bold),
                  labelStyle: TextStyle(
                    color: Color(0xFF009ADA),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF009ADA), width: 1.3)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF009ADA), width: 2)),
                ),
                obscureText: true,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Cadastro(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      overlayColor:
                          WidgetStateProperty.all(Colors.transparent),
                      padding:
                          const WidgetStatePropertyAll(EdgeInsets.all(0))
                    ),
                    child: const Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF009ADA),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 380,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InicioAluno(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.all(20),
                    ),
                  ),
                  child: const Text(
                    'ENTRAR',
                    style: TextStyle(
                      color: Color(0xFF009ADA),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
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
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: const Text(
                  'Não tem uma conta? Cadastre-se',
                  style: TextStyle(fontSize: 12, color: Color(0xFF009ADA)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
