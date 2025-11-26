import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContatosProfessor extends StatefulWidget {
  const ContatosProfessor({super.key});

  @override
  State<ContatosProfessor> createState() => _ContatosProfessorState();
}

class _ContatosProfessorState extends State<ContatosProfessor> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> contatos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarContatos();
  }

  Future<void> carregarContatos() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final turmasResp = await supabase
          .from('professor_turma')
          .select('id_turma')
          .eq('id_professor', userId);

      final idsTurmas = turmasResp.map((e) => e['id_turma']).toList();
      if (idsTurmas.isEmpty) {
        setState(() => carregando = false);
        return;
      }

      final alunosResp = await supabase
          .from('aluno')
          .select('id')
          .inFilter('id_turma', idsTurmas);

      final idsAlunos = alunosResp.map((e) => e['id']).toList();
      if (idsAlunos.isEmpty) {
        setState(() => carregando = false);
        return;
      }

      final responsaveisResp = await supabase
          .from('responsavel_aluno')
          .select('id_responsavel')
          .inFilter('id_aluno', idsAlunos);

      final idsResponsaveis =
          responsaveisResp.map((e) => e['id_responsavel']).toSet().toList();

      if (idsResponsaveis.isNotEmpty) {
        final contatosResp = await supabase
            .from('contato')
            .select('nome,email,telefone')
            .inFilter('id_usuario', idsResponsaveis);

        contatos = List<Map<String, dynamic>>.from(contatosResp);
      }

      final uniqueContatos = contatos
          .map((e) => e['email'] as String?)
          .where((email) => email != null && email.isNotEmpty)
          .toSet()
          .map((email) => contatos.firstWhere((e) => e['email'] == email))
          .toList();

      contatos = uniqueContatos;

      setState(() => carregando = false);
    } catch (e) {
      print('Erro ao carregar contatos: $e');
      setState(() => carregando = false);
    }
  }

  // ---------------------- UI MELHORADA ----------------------

  Widget _buildContatoCard({
    required String nome,
    required String telefone,
    required String email,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do responsável
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.lightBlue[200],
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nome,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            Divider(color: Colors.grey[300]),

            const SizedBox(height: 10),

            // Telefone
            _buildContactRow(
              icon: Icons.phone_rounded,
              label: "Telefone",
              value: telefone,
            ),

            const SizedBox(height: 8),

            // Email
            _buildContactRow(
              icon: Icons.email_rounded,
              label: "E-mail",
              value: email,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue[800], size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF0077B6),
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ---------------------- BUILD ----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text(
          'CONTATOS DOS RESPONSÁVEIS',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : contatos.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum contato encontrado",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: contatos.length,
                    itemBuilder: (context, index) {
                      final c = contatos[index];
                      return _buildContatoCard(
                        nome: c['nome'] ?? "Nome não informado",
                        telefone: c['telefone'] ?? "Telefone não informado",
                        email: c['email'] ?? "E-mail não informado",
                      );
                    },
                  ),
      ),
    );
  }
}
