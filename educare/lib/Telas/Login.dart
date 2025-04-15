import 'package:flutter/material.dart';
import 'Cadastro.dart';
import 'Aluno/InicioAluno.dart';
import '../services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool isLoading = false;

  Future<void> _realizarLogin() async {
    setState(() {
      isLoading = true;
    });

    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    final response = await AuthService.login(email, senha);

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      // Login bem-sucedido
      print('Usuário logado: $response');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InicioAluno()),
      );
    } else {
      // Erro no login
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro de login'),
          content: const Text('Usuário ou senha inválidos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 300),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  floatingLabelStyle: TextStyle(
                      color: Color(0xFF009ADA), fontWeight: FontWeight.bold),
                  labelStyle: TextStyle(color: Color(0xFF009ADA)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009ADA), width: 1.3)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009ADA), width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  floatingLabelStyle: TextStyle(
                      color: Color(0xFF009ADA), fontWeight: FontWeight.bold),
                  labelStyle: TextStyle(color: Color(0xFF009ADA)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009ADA), width: 1.3)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009ADA), width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 380,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _realizarLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'ENTRAR',
                          style: TextStyle(
                            color: Color(0xFF009ADA),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Cadastro()));
                },
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
