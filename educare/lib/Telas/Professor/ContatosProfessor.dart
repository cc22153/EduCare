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
          responsaveisResp.map((e) => e['id_responsavel']).toList();

      // 4️⃣ Buscar contatos desses responsáveis
      if (idsResponsaveis.isNotEmpty) {
        final contatosResp = await supabase
            .from('contato')
            .select('nome,email,telefone')
            .inFilter('id_usuario', idsResponsaveis);

        contatos.addAll(List<Map<String, dynamic>>.from(contatosResp));
      }

      setState(() {
        carregando = false;
      });
    } catch (e) {
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
        title: const Text('Contatos dos Responsáveis'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : contatos.isEmpty
                ? const Center(child: Text("Nenhum contato encontrado"))
                : ListView.builder(
                    itemCount: contatos.length,
                    itemBuilder: (context, index) {
                      final contato = contatos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contato['nome'] ?? '',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                contato['telefone'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                contato['email'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
