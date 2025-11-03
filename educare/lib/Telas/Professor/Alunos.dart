import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'DetalhesAluno.dart';
import 'AdicionarAluno.dart';

class Alunos extends StatefulWidget {
  const Alunos({super.key});

  @override
  State<Alunos> createState() => _AlunosState();
}

class _AlunosState extends State<Alunos> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> carregarAlunos() async {
    final userId = supabase.auth.currentUser!.id;

  
    final turmasResponse = await supabase
        .from('professor_turma')
        .select()
        .eq('id_professor', userId);

    List<Map<String, dynamic>> listaAlunos = [];

    for (final item in turmasResponse) {
      final idTurma = item['id_turma'];

      
      final alunosResponse =
          await supabase.from('aluno').select().eq('id_turma', idTurma);

      for (final aluno in alunosResponse) {
       
        final turmaResponse = await supabase
            .from('turma')
            .select()
            .eq('id', idTurma)
            .single(); 

        final nomeTurma = turmaResponse['nome'];

        final nomeAluno = await supabase
            .from('usuario')
            .select('nome')
            .eq('id', aluno['id'])
            .single();

        listaAlunos.add({
          'id': aluno['id'], // Adicionando o ID do aluno
          'nome': nomeAluno['nome'],
          'escola': turmaResponse['escola'],
          'turma': nomeTurma,
        });
      }
    }

    return listaAlunos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Alunos'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: carregarAlunos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final listaAlunos = snapshot.data ?? [];

          if (listaAlunos.isEmpty) {
            return const Center(child: Text('Nenhum aluno encontrado.'));
          }

          return ListView.builder(
            itemCount: listaAlunos.length,
            itemBuilder: (context, index) {
              final alunoData = listaAlunos[index];

              return Padding(
                padding: const EdgeInsets.all(8.0), 
                child: Card(
                  child: ListTile(
                    title: Text(alunoData['nome'] ?? ''),
                    subtitle: Text(
                        'Colégio: ${alunoData['escola']}\nTurma: ${alunoData['turma'] ?? ''}'),
                    onTap: () {
                      // Passando o ID do aluno para a tela de Detalhes
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesAluno(
                            nomeAluno: alunoData['nome'] ?? 'Sem nome',
                            turmaAluno: alunoData['turma'] ?? 'Sem turma',
                            idAluno: alunoData['id'] ?? '', // Passa o ID
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[300],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdicionarAluno()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
