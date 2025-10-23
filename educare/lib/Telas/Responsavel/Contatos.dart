import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Contatos extends StatefulWidget {
  const Contatos({super.key});

  @override
  State<Contatos> createState() => _ContatosState();
}

class _ContatosState extends State<Contatos> {
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

      // 1️⃣ Pegar alunos do responsável logado
      final alunosResp = await supabase
          .from('responsavel_aluno')
          .select('id_aluno')
          .eq('id_responsavel', userId);

      final idsAlunos = alunosResp.map((e) => e['id_aluno']).toList();

      if (idsAlunos.isEmpty) {
        setState(() {
          carregando = false;
        });
        return;
      }

      // 2️⃣ Pegar outros responsáveis desses alunos
      final outrosResp = await supabase
          .from('responsavel_aluno')
          .select('id_responsavel')
          .inFilter('id_aluno', idsAlunos);

      // Usar Set para garantir IDs únicos
      final idsResponsaveis =
          outrosResp.map((e) => e['id_responsavel']).toSet().toList();

      // Filtrar o próprio usuário
      idsResponsaveis.remove(userId); 
      
      // 3️⃣ Buscar contatos desses responsáveis
      if (idsResponsaveis.isNotEmpty) {
        final contatosResp = await supabase
            .from('contato')
            .select('nome,email,telefone')
            .inFilter('id_usuario', idsResponsaveis);

        contatos.addAll(List<Map<String, dynamic>>.from(contatosResp));
      }

      // 4️⃣ Pegar turmas dos alunos
      final turmasResp = await supabase
          .from('aluno')
          .select('id_turma')
          .inFilter('id', idsAlunos);

      final idsTurmas = turmasResp.map((e) => e['id_turma']).toSet().toList();

      // 5️⃣ Buscar professor da turma e contato
      if (idsTurmas.isNotEmpty) {
        final profTurma = await supabase
            .from('professor_turma')
            .select('id_professor')
            .inFilter('id_turma', idsTurmas);

        final idsProfessores = profTurma.map((e) => e['id_professor']).toSet().toList();
        
        if (idsProfessores.isNotEmpty) {
          final contatosProf = await supabase
              .from('contato')
              .select('nome,email,telefone')
              .inFilter('id_usuario', idsProfessores);

          contatos.addAll(List<Map<String, dynamic>>.from(contatosProf));
        }
      }
      
      // Filtra duplicados se houver (ex: mesmo responsável em diferentes alunos)
      final uniqueContatos = contatos
          .map((e) => e['email'] as String)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        // Refinamento: Título e ícone de voltar em branco
        title: const Center(
          child: Text(
            'CONTATOS', 
            style: TextStyle(color: Colors.white)
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : contatos.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum contato encontrado",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: contatos.length,
                    itemBuilder: (context, index) {
                      final contato = contatos[index];
                      // Alternamos as cores dos cartões para que a lista fique visualmente mais interessante
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
    );
  }
  
  // Widget customizado para o cartão de contato (Novo Design)
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
                color: Colors.lightBlue[700], // Cor de destaque
              ),
            ),
            const Divider(height: 15),
            
            // Telefone (Com Ícone e Ação Simulada)
            _buildContactRow(
              icon: Icons.phone_outlined,
              value: telefone,
              // O `onTap` aqui seria o local para implementar a chamada real
              onTap: () { /* Implementar link para chamada, ex: launchUrl(Uri.parse('tel:$telefone')); */ },
            ),
            
            // Email (Com Ícone e Ação Simulada)
            _buildContactRow(
              icon: Icons.email_outlined,
              value: email,
              // O `onTap` aqui seria o local para implementar o envio de e-mail
              onTap: () { /* Implementar link para e-mail, ex: launchUrl(Uri.parse('mailto:$email')); */ },
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
    // Usamos InkWell ou GestureDetector para dar um feedback visual no toque
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
                  color: Color.fromARGB(255, 61, 178, 217), // Cor azul para simular link
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}