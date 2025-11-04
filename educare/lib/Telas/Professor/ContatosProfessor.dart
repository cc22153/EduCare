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
    // ... (Sua lógica de busca de contatos existente, mantida)
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1️⃣ Pegar turmas do professor logado
      final turmasResp = await supabase
          .from('professor_turma')
          .select('id_turma')
          .eq('id_professor', userId);

      final idsTurmas = turmasResp.map((e) => e['id_turma']).toList();

      if (idsTurmas.isEmpty) {
        setState(() {
          carregando = false;
        });
        return;
      }

      // 2️⃣ Pegar alunos dessas turmas
      final alunosResp = await supabase
          .from('aluno')
          .select('id')
          .inFilter('id_turma', idsTurmas);

      final idsAlunos = alunosResp.map((e) => e['id']).toList();

      if (idsAlunos.isEmpty) {
        setState(() {
          carregando = false;
        });
        return;
      }

      // 3️⃣ Pegar responsáveis desses alunos
      final responsaveisResp = await supabase
          .from('responsavel_aluno')
          .select('id_responsavel')
          .inFilter('id_aluno', idsAlunos);

      final idsResponsaveis =
          responsaveisResp.map((e) => e['id_responsavel']).toSet().toList(); // Usando toSet para unicidade

      // 4️⃣ Buscar contatos desses responsáveis
      if (idsResponsaveis.isNotEmpty) {
        final contatosResp = await supabase
            .from('contato')
            .select('nome,email,telefone')
            .inFilter('id_usuario', idsResponsaveis);

        contatos.addAll(List<Map<String, dynamic>>.from(contatosResp));
      }
      
      // Filtra duplicados se houver (ex: mesmo responsável em diferentes alunos)
      final uniqueContatos = contatos
          .map((e) => e['email'] as String?) // Lidar com e-mails nulos
          .where((email) => email != null && email.isNotEmpty)
          .toSet()
          .map((email) => contatos.firstWhere((e) => e['email'] == email))
          .toList();
      
      contatos = uniqueContatos;

      setState(() {
        carregando = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar contatos: $e');
      setState(() {
        carregando = false;
      });
    }
  }
  
  // Widget customizado para o cartão de contato (Reutilizado do Contatos.dart)
  Widget _buildContatoCard({
    required String nome,
    required String telefone,
    required String email,
    required Color cardColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome (Destaque Principal)
            Text(
              nome,
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue[700], 
              ),
            ),
            const Divider(height: 15),
            
            // Telefone (Com Ícone)
            _buildContactRow(
              icon: Icons.phone_outlined,
              value: telefone,
              // onTap: () { /* Implementar link para chamada */ },
            ),
            
            // Email (Com Ícone)
            _buildContactRow(
              icon: Icons.email_outlined,
              value: email,
              // onTap: () { /* Implementar link para e-mail */ },
            ),
          ],
        ),
      ),
    );
  }

  // Widget para cada linha de contato (Telefone/Email)
  Widget _buildContactRow({
    required IconData icon,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap, 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(
              icon, 
              color: Colors.grey[600], 
              size: 20
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 61, 178, 217), 
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
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
            'CONTATOS DOS RESPONSÁVEIS',
            style: TextStyle(color: Colors.white),
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : contatos.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum contato encontrado",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: contatos.length,
                    itemBuilder: (context, index) {
                      final contato = contatos[index];
                      // Alternamos as cores dos cartões
                      final bool isEven = index % 2 == 0;
                      final Color cardColor = isEven 
                        ? const Color.fromARGB(255, 230, 245, 255) // Azul claro
                        : Colors.white; // Branco
                        
                      return _buildContatoCard(
                        nome: contato['nome'] ?? 'Nome Indisponível',
                        telefone: contato['telefone'] ?? 'Telefone Indisponível',
                        email: contato['email'] ?? 'E-mail Indisponível',
                        cardColor: cardColor,
                      );
                    },
                  ),
      ),
    );
  }
}