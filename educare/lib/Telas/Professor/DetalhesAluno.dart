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

class _DetalhesAlunoState extends State<DetalhesAluno>
    with SingleTickerProviderStateMixin {
  final TextEditingController relatorioController = TextEditingController();
  final supabase = Supabase.instance.client;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  // Enviar relatório + notificação
  Future<void> enviarRelatorio() async {
    final String texto = relatorioController.text.trim();
    final String? professorId = supabase.auth.currentUser?.id;

    if (texto.isEmpty) {
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
      // 1️⃣ Inserir relatório
      await supabase.from('relatorios_professor').insert({
        'id_aluno': widget.idAluno,
        'id_professor': professorId,
        'texto': texto,
        'lido_resp': false,
      });

      // 2️⃣ Criar notificação para o responsável
      await supabase.from('notificacoes').insert({
        'titulo': 'Novo relatório do professor',
        'tipo': 'relatorio',
        'id_aluno': widget.idAluno,
        'visualizada': false,
        'enviado_em': DateTime.now().toIso8601String(),
      });

      relatorioController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório enviado e responsável notificado!'),
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar relatório: $e')),
      );
    }
  }

  Widget _styledTextField(
      {required TextEditingController controller,
      required String hint,
      int maxLines = 5}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF4FF),
      appBar: AppBar(
         backgroundColor: Colors.lightBlue[300],
        elevation: 4,
        centerTitle: true,
        title: Text(
          widget.nomeAluno,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // CARD DO ALUNO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xffF2F7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nomeAluno,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "📘 Turma: ${widget.turmaAluno}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TÍTULO
            const Text(
              "Relatório do Dia/Semana",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xff2A2A2A),
              ),
            ),
            const SizedBox(height: 12),

            // CAMPO DE TEXTO
            _styledTextField(
              controller: relatorioController,
              hint: "Escreva o relatório aqui...",
              maxLines: 7,
            ),

            const SizedBox(height: 30),

            // BOTÃO ENVIAR
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: enviarRelatorio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4A90E2),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "ENVIAR RELATÓRIO",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÃO VOLTAR
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Voltar",
                  style: TextStyle(
                    color: Color(0xff4A90E2),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
