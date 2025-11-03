import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class DetalhesAluno extends StatefulWidget {
  final String nomeAluno;
  final String turmaAluno;
  final String idAluno; 

  const DetalhesAluno({
    super.key,
    required this.nomeAluno,
    required this.turmaAluno,
    required this.idAluno, 
  });

  @override
  State<DetalhesAluno> createState() => _DetalhesAlunoState();
}

class _DetalhesAlunoState extends State<DetalhesAluno> {
  final TextEditingController relatorioController = TextEditingController();
  final supabase = Supabase.instance.client; 

  // Lógica de envio com INSERT no Supabase
  Future<void> enviarRelatorio() async {
    // ignore: use_build_context_synchronously
    final BuildContext context = this.context; 
    final relatorioTexto = relatorioController.text.trim();
    final professorId = supabase.auth.currentUser?.id;
    
    if (relatorioTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O relatório não pode estar vazio.')),
      );
      return;
    }

    if (professorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não logado.')),
      );
      return;
    }
    
    try {
      // INSERT na nova tabela
      await supabase.from('relatorios_professor').insert({
        'id_aluno': widget.idAluno, // ID do aluno
        'id_professor': professorId, // ID do professor logado
        'texto': relatorioTexto,
        'lido_resp': false, // Inicia como não lido
      });
      
      relatorioController.clear(); // Limpa o campo
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relatório enviado com sucesso!')),
      );
      if (mounted) {
        Navigator.pop(context); // Volta para a tela anterior
      }
      
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao enviar relatório: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar o relatório: ${e.toString()}')),
      );
    }
  }
  
  // Widget para TextField estilizado (Reutilizado das telas anteriores)
  Widget _buildStyledTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.nomeAluno,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do Aluno
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Turma: ${widget.turmaAluno}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 30),

            // Título do Relatório
            const Text(
              'Relatório do Dia/Semana:',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0), 
              ),
            ),
            const SizedBox(height: 10),
            
            // Campo de Texto para o Relatório (Estilizado)
            _buildStyledTextField(
              relatorioController,
              'Escreva o relatório aqui...',
              maxLines: 7,
            ),
            
            const SizedBox(height: 40),

            // Botão ENVIAR RELATÓRIO
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 85, 158, 88),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                onPressed: enviarRelatorio, 
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'ENVIAR RELATÓRIO',
                  style: TextStyle(
                    fontSize: 18, 
                    color: Colors.white, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Botão Voltar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}