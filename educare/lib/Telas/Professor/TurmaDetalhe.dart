import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TurmaDetalhe extends StatefulWidget {
  final String turmaId;
  final String turmaNome;

  const TurmaDetalhe({
    super.key,
    required this.turmaId,
    required this.turmaNome,
  });

  @override
  State<TurmaDetalhe> createState() => _TurmaDetalheState();
}

class _TurmaDetalheState extends State<TurmaDetalhe> {
  List<Map<String, dynamic>> alunos = [];
  bool carregando = true;
  String codigoTurma = "";

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => carregando = true);

    // Busca a turma para pegar o código
    final turma = await Supabase.instance.client
        .from('turma')
        .select()
        .eq('id', widget.turmaId)
        .single();

    codigoTurma = turma['id'];

    // Busca os alunos dessa turma
    final alunosDaTurma = await Supabase.instance.client
        .from('aluno')
        .select('id')
        .eq('id_turma', widget.turmaId);

    // Extrai apenas os IDs dos usuários dos alunos
    final idsUsuarios = alunosDaTurma.map((a) => a['id']).toList();

    List<Map<String, dynamic>> alunosInfo = [];

    if (idsUsuarios.isNotEmpty) {
      var id;
      for( id in idsUsuarios){
        // Busca os dados dos usuários usando in_()
        final response = await Supabase.instance.client
            .from('usuario')
            .select()
            .eq('id', id);

        alunosInfo += List<Map<String, dynamic>>.from(response);
      }
    }

    setState(() {
      alunos = alunosInfo;
      carregando = false;
    });
  }


  Future<void> adicionarAluno() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    if (nome.isEmpty || email.isEmpty) return;

    await Supabase.instance.client.from('alunos').insert({
      'nome': nome,
      'email': email,
      'turma_id': widget.turmaId,
    });

    _nomeController.clear();
    _emailController.clear();

    await carregarDados();
  }

  Future<void> removerAluno(String alunoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remover Aluno"),
        content: const Text("Tem certeza que deseja remover este aluno?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: const Text("Remover", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('alunos')
          .delete()
          .eq('id', alunoId);

      await carregarDados();
    }
  }

  void mostrarDialogAdicionarAluno() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adicionar Aluno"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              adicionarAluno();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[300],
            ),
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turmaNome),
        backgroundColor: Colors.blue[300],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Código da Turma:\n$codigoTurma",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Código copiado!"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: alunos.isEmpty
                      ? const Center(
                          child: Text("Nenhum aluno nesta turma."),
                        )
                      : ListView.builder(
                          itemCount: alunos.length,
                          itemBuilder: (context, index) {
                            final aluno = alunos[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(aluno['nome']),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      removerAluno(aluno['id']),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarDialogAdicionarAluno,
        backgroundColor: Colors.blue[300],
        child: const Icon(Icons.add),
      ),
    );
  }
}
