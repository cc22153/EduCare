import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Login.dart'; 

class RedefinirSenha extends StatefulWidget {
  
  const RedefinirSenha({super.key});

  @override
  State<RedefinirSenha> createState() => _RedefinirSenhaState();
}

class _RedefinirSenhaState extends State<RedefinirSenha> {
  final supabase = Supabase.instance.client;
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  bool isLoading = false;

  // Lógica de atualização da senha
  Future<void> _atualizarSenha() async {
    final BuildContext context = this.context;
    final novaSenha = senhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (novaSenha.isEmpty || confirmarSenha.isEmpty) {
      _mostrarErro('Todos os campos são obrigatórios.');
      return;
    }
    if (novaSenha != confirmarSenha) {
      _mostrarErro('A senha e a confirmação de senha não coincidem.');
      return;
    }
    if (novaSenha.length < 6) {
      _mostrarErro('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() => isLoading = true);

    try {
   
      await supabase.auth.updateUser(
        UserAttributes(password: novaSenha),
      );

      // Sucesso
     
      _mostrarSucesso('Sua senha foi redefinida com sucesso! Por favor, faça login.');
      
      // Limpa os campos e navega para o login
      senhaController.clear();
      confirmarSenhaController.clear();
  
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (Route<dynamic> route) => false,
      );

    } on AuthException catch (e) {
      _mostrarErro('Erro ao redefinir: ${e.message}');
    } catch (e) {
      _mostrarErro('Erro inesperado: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  
 
  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erro', style: TextStyle(color: Colors.red)),
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

  void _mostrarSucesso(String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sucesso!', style: TextStyle(color: Colors.green)),
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
      appBar: AppBar(
        title: const Center(
          child: Text(
            'REDEFINIR SENHA',
            style: TextStyle(color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // Não permite voltar para evitar quebra de fluxo
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Digite sua nova senha. Ela deve ter no mínimo 6 caracteres.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              
              // Campo Nova Senha
              _buildStyledTextField(senhaController, 'Nova Senha', true),
              const SizedBox(height: 15),
              
              // Campo Confirmar Senha
              _buildStyledTextField(confirmarSenhaController, 'Confirmar Nova Senha', true),
              
              const SizedBox(height: 40),
              
              // Botão Redefinir
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _atualizarSenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 61, 178, 217),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'REDEFINIR SENHA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  
  Widget _buildStyledTextField(TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.lightBlue[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
        ),
      ),
    );
  }
}