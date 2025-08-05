// ignore_for_file: use_build_context_synchronously

import 'package:educare/Services/supabase.dart';
import 'package:educare/Telas/Professor/InicioProfessor.dart';
import 'package:educare/Telas/Responsavel/InicioResponsavel.dart';
import 'package:flutter/material.dart';
import 'Cadastro.dart';
import 'Aluno/InicioAluno.dart';

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

    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: senha,
    );

    // Buscar o tipo do usuário no Supabase
    final userId = response.user?.id;
    Map<String, dynamic> aluno;
    final usuario = await supabase
        .from('usuario')
        .select()
        .eq('id', userId!)
        .single();

      if(usuario['tipo_usuario'] == "aluno"){
        aluno = await supabase
          .from('aluno')
          .select()
          .eq('id', usuario['id']) // ou .eq('id', idUsuario) se for direto
          .single();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => InicioAluno(usuario: usuario, aluno: aluno)),
          );
      }

    setState(() {
      isLoading = false;
    });

    if (usuario['tipo_usuario'] != null) {
      final tipo = usuario['tipo_usuario'];
      print(tipo);

      // Redirecionar para a tela correta
      if (tipo == 'professor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioProfessor()), // <- criar depois
        );
      } else if (tipo == 'responsavel') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioResponsavel()), // <- criar depois
        );
      }
    } else {
      _mostrarErro('Usuário sem tipo definido.');
    }
    }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erro'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
