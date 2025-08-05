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
  
  List<Map<String, String>> listaAlunos = [
    {'nome': 'Aluno 1', 'turma': '3º Ano A'},
    {'nome': 'Aluno 2', 'turma': '2º Ano B'},
    {'nome': 'Aluno 3', 'turma': '1º Ano C'},
  ];

  final supabase = Supabase.instance.client;

  void removerAluno(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover Aluno'),
          content: const Text('Deseja realmente remover este aluno?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  listaAlunos.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('REMOVER'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> carregarAlunos() async {
  final userId = supabase.auth.currentUser!.id;

  // 1. Buscar as turmas do professor
  final turmasResponse = await supabase
      .from('professor_turma')
      .select()
      .eq('id_professor', userId);

  List<Map<String, dynamic>> listaAlunos = [];

  for (final item in turmasResponse) {
    final idTurma = item['id_turma'];

    // 2. Buscar alunos da turma
    final alunosResponse = await supabase
        .from('aluno')
        .select()
        .eq('id_turma', idTurma);

    for (final aluno in alunosResponse) {
      // 3. Buscar nome da turma
      final turmaResponse = await supabase
          .from('turma')
          .select()
          .eq('id', idTurma)
          .single(); // Pega apenas o primeiro

      final nomeTurma = turmaResponse['nome'];

      listaAlunos.add({
        'nome': aluno['nome'],
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
              return Card(
                child: ListTile(
                  title: Text(listaAlunos[index]['nome']!),
                  subtitle: Text('Turma: ${listaAlunos[index]['turma']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removerAluno(index);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesAluno(
                          nomeAluno: listaAlunos[index]['nome']!,
                          turmaAluno: listaAlunos[index]['turma']!,
                        ),
                      ),
                    );
                  },
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
