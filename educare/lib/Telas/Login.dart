// ignore_for_file: use_build_context_synchronously

import 'package:educare/Services/supabase.dart';
import 'package:educare/Telas/Professor/InicioProfessor.dart';
import 'package:educare/Telas/Responsavel/InicioResponsavel.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );

      final userId = response.user?.id;
      if (userId == null) {
          throw const AuthException("Usuário ou senha incorretos.");
      }
      
      // Busca o tipo do usuário no Supabase
      Map<String, dynamic>? aluno;
      final usuario = await supabase
          .from('usuario')
          .select()
          .eq('id', userId)
          .single();

      final tipo = usuario['tipo_usuario'];
      
      if (tipo == 'aluno') {
          aluno = await supabase
            .from('aluno')
            .select()
            .eq('id', userId) 
            .single();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => InicioAluno(usuario: usuario, aluno: aluno!)),
          );
      } else if (tipo == 'professor') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InicioProfessor()),
          );
      } else if (tipo == 'responsavel') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InicioResponsavel()),
          );
      } else {
          _mostrarErro('Usuário sem tipo definido. Entre em contato com o suporte.');
      }
        
    } on AuthException catch (e) {
        String mensagem = 'E-mail ou senha incorretos.';
        if (!e.message.contains('Invalid login credentials')) {
            mensagem = e.message;
        }
        _mostrarErro(mensagem);
    } catch (e) {
        // ignore: avoid_print
        print('Erro no login/redirecionamento: $e');
        _mostrarErro('Erro inesperado ao realizar login.');
    } finally {
        setState(() {
            isLoading = false;
        });
    }
  }

  // FUNÇÃO PARA RECUPERAÇÃO DE SENHA
  Future<void> _esqueciMinhaSenha() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _mostrarErro('Por favor, digite seu e-mail no campo "Usuário" para redefinição de senha.');
      return;
    }
    
    try {
        await supabase.auth.resetPasswordForEmail(
            email,
           
            redirectTo: 'io.supabase.educare://login/reset-password',
        );
        _mostrarErro('Link de redefinição enviado para o e-mail: $email. Verifique sua caixa de entrada.');
    } on AuthException catch (e) {
        _mostrarErro('Erro ao enviar link de redefinição: ${e.message}');
    } catch (e) {
        _mostrarErro('Erro inesperado. Tente novamente.');
    }
  }


  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erro de Autenticação'),
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
          padding: const EdgeInsets.all(20.0), // Aumentei o padding para melhor visualização
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 250), //  Reduzi a logo para mais espaço
                const SizedBox(height: 40),
                
              
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
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
                
                const SizedBox(height: 30),
               
             
                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _realizarLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15), 
                      backgroundColor: const Color(0xFF009ADA), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                              'ENTRAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20, //Tamanho 
                              ),
                            ),
                  ),
                ),
                
                const SizedBox(height: 10),
                // BOTÃO CADASTRE-SE 
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Cadastro()));
                  },
                  child: const Text(
                    'Não tem uma conta? Cadastre-se',
                    style: TextStyle(fontSize: 14, color: Color(0xFF009ADA)), // ⬅️ Tamanho coerente
                  ),
                ),

                TextButton(
                  onPressed: _esqueciMinhaSenha,
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(fontSize: 14, color: Color(0xFF009ADA)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}