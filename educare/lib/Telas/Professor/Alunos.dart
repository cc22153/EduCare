import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'DetalhesAluno.dart';
import 'AdicionarAluno.dart';

class Alunos extends StatefulWidget {
  const Alunos({super.key});

  @override
  State<Alunos> createState() => _AlunosState();
}

class _AlunosState extends State<Alunos> with SingleTickerProviderStateMixin {
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
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<List<Map<String, dynamic>>> carregarAlunos() async {
    final userId = supabase.auth.currentUser!.id;

    final turmasResponse = await supabase
        .from('professor_turma')
        .select('id_turma')
        .eq('id_professor', userId);

    List<Map<String, dynamic>> listaAlunos = [];

    for (final item in turmasResponse) {
      final idTurma = item['id_turma'];

      final alunosResponse = await supabase
          .from('aluno')
          .select('id, id_turma')
          .eq('id_turma', idTurma);

      final turmaResponse = await supabase
          .from('turma')
          .select('nome, escola')
          .eq('id', idTurma)
          .single();

      for (final aluno in alunosResponse) {
        final usuarioResponse = await supabase
            .from('usuario')
            .select('nome')
            .eq('id', aluno['id'])
            .single();

        listaAlunos.add({
          'id': aluno['id'],
          'nome': usuarioResponse['nome'],
          'turma': turmaResponse['nome'],
          'escola': turmaResponse['escola'],
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 250)); 
    _controller.forward(); 

    return listaAlunos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF4FF),
      appBar: AppBar(
        title: const Text(
          'Alunos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue[300],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff4A90E2),
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdicionarAluno()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: carregarAlunos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xff4A90E2),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ocorreu um erro ao carregar os alunos.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final alunos = snapshot.data ?? [];

          if (alunos.isEmpty) {
            return Center(
              child: Text(
                'Nenhum aluno encontrado.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alunos.length,
              itemBuilder: (context, index) {
                final aluno = alunos[index];

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 80)),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xffFFFFFF),
                        Color(0xffF1F7FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(
                      aluno['nome'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff2A2A2A),
                      ),
                    ),
                    subtitle: Text(
                      "🏫 ${aluno['escola']}\n📘 Turma: ${aluno['turma']}",
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xff4A90E2),
                      size: 28,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesAluno(
                            nomeAluno: aluno['nome'],
                            turmaAluno: aluno['turma'],
                            idAluno: aluno['id'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
