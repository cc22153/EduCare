import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RotinaAluno extends StatefulWidget {
  const RotinaAluno({super.key});

  @override
  State<RotinaAluno> createState() => _RotinaAlunoState();
}

class _RotinaAlunoState extends State<RotinaAluno> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> carregarRotina() async {
    final userId = supabase.auth.currentUser!.id;

    // Buscar informações do aluno logado
    final alunoResponse = await supabase
        .from('aluno')
        .select()
        .eq('id', userId)
        .single();

    final idAluno = alunoResponse['id'];

    // Buscar rotina do aluno
    final rotinaResponse = await supabase
        .from('rotina')
        .select()
        .eq('id_aluno', idAluno)
        .order('data_hora', ascending: true);

    return rotinaResponse.map((item) {
      return {
        'horario': item['data_hora'] ?? '',
        'atividade': item['titulo'] ?? '',
        'descricao': item['descricao'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Rotina do Aluno',  style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue[300],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: carregarRotina(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final rotina = snapshot.data ?? [];

          if (rotina.isEmpty) {
            return const Center(child: Text('Nenhuma rotina cadastrada.',  style: TextStyle(color: Colors.white)), );
          }

          return ListView.builder(
            itemCount: rotina.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.blue),
                  title: Text(rotina[index]['atividade']),
                  subtitle: Text('${rotina[index]['descricao']}\nHorário: ${rotina[index]['horario']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
