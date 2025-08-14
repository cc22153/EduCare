import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'TurmaDetalhe.dart';

class AdminTurmas extends StatefulWidget {
  final String idProfessor; // vem do login do professor

  const AdminTurmas({super.key, required this.idProfessor});

  @override
  State<AdminTurmas> createState() => _AdminTurmasState();
}

class _AdminTurmasState extends State<AdminTurmas> {
  List<Map<String, dynamic>> turmas = [];
  bool carregando = true;
  final _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarTurmas();
  }

  Future<void> carregarTurmas() async {
    setState(() => carregando = true);
    final turmaId = await Supabase.instance.client
        .from('professor_turma')
        .select()
        .eq('id_professor', widget.idProfessor)
        .single();

    final response = await Supabase.instance.client
        .from('turma')
        .select()
        .eq('id', turmaId['id_turma'])
        .order('nome', ascending: true);

    setState(() {
      turmas = List<Map<String, dynamic>>.from(response);
      carregando = false;
    });
  }

  Future<void> criarTurma() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    await Supabase.instance.client.from('turmas').insert({
      'nome': nome,
      'id_professor': widget.idProfessor,
      'codigo': gerarCodigoTurma(), // código único para alunos entrarem
    });

    _nomeController.clear();
    await carregarTurmas();
  }

  Future<void> apagarTurma(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Apagar Turma"),
        content: const Text("Tem certeza que deseja apagar esta turma?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: const Text("Apagar", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.from('turmas').delete().eq('id', id);
      await carregarTurmas();
    }
  }

  String gerarCodigoTurma() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    return List.generate(6, (index) => chars[(chars.length * (index + DateTime.now().microsecond) % chars.length) ~/ 1]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Turmas"),
        backgroundColor: Colors.blue[300],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: "Nome da nova turma",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: criarTurma,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[300],
                        ),
                        child: const Text("Criar"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: turmas.isEmpty
                      ? const Center(child: Text("Nenhuma turma cadastrada."))
                      : ListView.builder(
                          itemCount: turmas.length,
                          itemBuilder: (context, index) {
                            final turma = turmas[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(turma['nome']),
                                subtitle: Text("Código: ${turma['id']}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => apagarTurma(turma['id']),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TurmaDetalhe(
                                        turmaId: turma['id'],
                                        turmaNome: turma['nome'],
                                      ),
                                    ),
                                  ).then((_) => carregarTurmas());
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
