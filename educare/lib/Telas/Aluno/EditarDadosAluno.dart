import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarDadosAluno extends StatefulWidget {
 
  final String alunoId; 
  const EditarDadosAluno({super.key, required this.alunoId});

  @override
  State<EditarDadosAluno> createState() => _EditarDadosAlunoState();
}

class _EditarDadosAlunoState extends State<EditarDadosAluno> {
  final supabase = Supabase.instance.client;


  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final turmaIdController = TextEditingController(); // Se for código/ID

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDadosAluno();
  }

  Future<void> carregarDadosAluno() async {
    final userId = widget.alunoId;
    if (userId.isEmpty) return;

    try {
     
      final nomeData = await supabase
          .from('usuario')
          .select('nome')
          .eq('id', userId)
          .maybeSingle();

     
      final contatoData = await supabase
          .from('contato')
          .select('email, telefone')
          .eq('id_usuario', userId)
          .maybeSingle();
          
      final alunoData = await supabase
          .from('aluno')
          .select('id_turma')
          .eq('id', userId)
          .maybeSingle();

      if (mounted) {
        if (nomeData != null) nomeController.text = nomeData['nome'] ?? '';
        if (contatoData != null) {
          emailController.text = contatoData['email'] ?? '';
          telefoneController.text = contatoData['telefone'] ?? '';
        }
        if (alunoData != null) {
          turmaIdController.text = alunoData['id_turma']?.toString() ?? ''; 
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar dados do Aluno: $e');
    }

    setState(() {
      carregando = false;
    });
  }
  
  
  Future<void> atualizarDados() async {
    final userId = widget.alunoId;
    if (userId.isEmpty) return;

    try {
    
      await supabase.from('usuario').update({
        'nome': nomeController.text,
      }).eq('id', userId);

   
       await supabase.from('contato').upsert({
        'id_usuario': userId, 
        'email': emailController.text,
        'telefone': telefoneController.text,
      }, onConflict: 'id_usuario'); 
      
    
      await supabase.from('aluno').update({
        'id_turma': turmaIdController.text, 
      }).eq('id', userId); 
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados do Aluno atualizados com sucesso!')),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao atualizar dados do Aluno: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar os dados do aluno')),
      );
    }
  }

 
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
          ? const Center(child: CircularProgressIndicator(color: Colors.lightBlue))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo Nome
                    _buildStyledTextField(nomeController, 'Nome do Aluno'),
                    const SizedBox(height: 15),

                    // Campo Email (do Aluno)
                    _buildStyledTextField(emailController, 'Email de Contato do Aluno', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15),
                    
                    // Campo Telefone (do Aluno)
                    _buildStyledTextField(telefoneController, 'Telefone de Contato do Aluno', keyboardType: TextInputType.phone),
                    const SizedBox(height: 15),

                    // Campo Código da Turma
                    _buildStyledTextField(turmaIdController, 'Código/ID da Turma'),
                    const SizedBox(height: 25),
                    
                    // Botão SALVAR ALTERAÇÕES
                    SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: atualizarDados,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 61, 178, 217), // Cor do botão da Rotina
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'SALVAR ALTERAÇÕES DO ALUNO',
                          style: TextStyle(
                            fontSize: 18, 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}