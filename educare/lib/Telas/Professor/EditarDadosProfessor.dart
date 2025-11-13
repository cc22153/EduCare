import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarDadosProfessor extends StatefulWidget {
  const EditarDadosProfessor({super.key});

  @override
  State<EditarDadosProfessor> createState() => EditarDadosProfessorState();
}

class EditarDadosProfessorState extends State<EditarDadosProfessor> {
  final supabase = Supabase.instance.client;

  // Controllers para manter os dados dos campos
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController(); // Apenas para simular a mudança de senha

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  // Lógica para buscar os dados do professor logado
  Future<void> carregarDadosUsuario() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Busca o Nome na tabela 'usuario'
      final nome = await supabase
          .from('usuario')
          .select('nome')
          .eq('id', userId)
          .maybeSingle();

      // 2. Busca o Email e Telefone na tabela 'contato'
      final dados = await supabase
          .from('contato')
          .select('email, telefone')
          .eq('id_usuario', userId)
          .maybeSingle();

      if (mounted) {
        if (nome != null) {
          nomeController.text = nome['nome'] ?? '';
        }
        if (dados != null) {
          emailController.text = dados['email'] ?? '';
          telefoneController.text = dados['telefone'] ?? '';
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar dados: $e');
    }

    setState(() {
      carregando = false;
    });
  }
  
  // Lógica para atualizar os dados
  Future<void> atualizarDados() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Atualiza o nome na tabela 'usuario'
      await supabase.from('usuario').update({
        'nome': nomeController.text,
      }).eq('id', userId);

      // 2. Atualiza/Insere o contato na tabela 'contato'
      // Usamos upsert para inserir se não existir ou atualizar se existir (baseado em id_usuario)
       await supabase.from('contato').upsert({
        'id_usuario': userId, 
        'email': emailController.text,
        'telefone': telefoneController.text,
      }, onConflict: 'id_usuario'); 
      
      // 3. Lógica para mudar a senha (Se a senhaController.text for diferente de vazio, você precisaria usar supabase.auth.updateUser)
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao atualizar: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar os dados')),
      );
    }
  }

  // Widget para TextField estilizado (Reutilizado das telas anteriores)
  Widget _buildStyledTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, bool obscure = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black87), 
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.lightBlue[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
        ),
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
            'EDITAR DADOS', 
            style: TextStyle(color: Colors.white)
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo Nome
                    _buildStyledTextField(nomeController, 'Nome'),
                    const SizedBox(height: 15),

                    // Campo Email
                    _buildStyledTextField(emailController, 'Email', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15),
                    
                    // Campo Telefone
                    _buildStyledTextField(telefoneController, 'Telefone', keyboardType: TextInputType.phone),
                    const SizedBox(height: 15),
                    
                    // Campo Senha (Apenas para nova senha)
                    _buildStyledTextField(senhaController, 'Nova Senha (deixe vazio para manter a atual)', obscure: true),
                    
                    const SizedBox(height: 40),
                    
                    // Botão SALVAR ALTERAÇÕES
                    SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: atualizarDados,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 61, 178, 217),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'SALVAR ALTERAÇÕES',
                          style: TextStyle(
                            fontSize: 18, 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
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
}