import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Rotina extends StatefulWidget {
  const Rotina({super.key});

  @override
  State<Rotina> createState() => _RotinaState();
}

class _RotinaState extends State<Rotina> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> alunos = [];
  String? alunoSelecionadoId;

  List<Map<String, dynamic>> tarefas = [];

  final horarioController = TextEditingController();
  final tituloController = TextEditingController();
  final tarefaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarAlunosDoResponsavel();
  }

    
  Future<void> carregarAlunosDoResponsavel() async {
    final userId = supabase.auth.currentUser?.id;

    try {
      final response = await supabase
          .from('responsavel_aluno')
          .select('id_aluno')
          .eq('id_responsavel', userId!);

      // Lista final que vai armazenar os dados de id e nome
      List<Map<String, dynamic>> listaAlunos = [];

      for (var obj in response) {
        final idAluno = obj['id_aluno'];

        // Buscar o nome na tabela usuario usando o id do aluno
        final usuarioData = await supabase
            .from('usuario')
            .select('nome')
            .eq('id', idAluno)
            .single();

        final nomeAluno = usuarioData['nome'];

        listaAlunos.add({
          'id': idAluno,
          'nome': nomeAluno,
        });
      }

      setState(() {
        alunos = listaAlunos;
      });
    } catch (e) {
      print('Erro ao carregar alunos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar alunos')),
      );
    }
  }



  Future<void> carregarTarefas(String alunoId) async {
    final response = await supabase
        .from('rotina')
        .select()
        .eq('id_aluno', alunoId)
        .order('data_hora', ascending: true);

    setState(() {
      tarefas = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> adicionarTarefa() async {
    if (alunoSelecionadoId == null) return;
    final userId = supabase.auth.currentUser?.id;

    await supabase.from('rotina').insert({
      'id_aluno': alunoSelecionadoId,
      'titulo': tituloController.text,
      'data_hora': horarioController.text,
      'descricao': tarefaController.text,
      'id_criador': userId,
    });

    horarioController.clear();
    tarefaController.clear();

    await carregarTarefas(alunoSelecionadoId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotina'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown de alunos
            DropdownButton<String>(
              value: alunoSelecionadoId,
              hint: const Text("Selecione um aluno"),
              isExpanded: true,
              items: alunos.map<DropdownMenuItem<String>>((aluno) {
                return DropdownMenuItem<String>(
                  value: aluno['id'] as String,
                  child: Text(aluno['nome']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  alunoSelecionadoId = value;
                });
                if (value != null) carregarTarefas(value);
              },
            ),

            const SizedBox(height: 20),

            // Lista de tarefas
            Expanded(
              child: tarefas.isEmpty
                  ? const Center(child: Text("Nenhuma tarefa encontrada"))
                  : ListView.builder(
                      itemCount: tarefas.length,
                      itemBuilder: (context, index) {
                        final tarefa = tarefas[index];
                        return Card(
                          child: ListTile(
                            title: Text(tarefa['titulo']),
                            subtitle: Text("Descrição: ${tarefa['descricao']} Horário: ${tarefa['data_hora']}"),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            // Campos para adicionar tarefa
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Titulo:'),
            ),
            TextField(
              controller: horarioController,
              decoration: const InputDecoration(labelText: 'Horário:'),
            ),
            TextField(
              controller: tarefaController,
              decoration: const InputDecoration(labelText: 'Descrição da Tarefa:'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: adicionarTarefa,
              child: const Text('Adicionar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}
