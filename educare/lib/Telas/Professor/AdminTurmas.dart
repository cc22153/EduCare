import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'TurmaDetalhe.dart';

class AdminTurmas extends StatefulWidget {
  final String idProfessor;

  const AdminTurmas({super.key, required this.idProfessor});

  @override
  State<AdminTurmas> createState() => _AdminTurmasState();
}

class _AdminTurmasState extends State<AdminTurmas> {
  List<Map<String, dynamic>> turmas = [];
  bool carregando = true;

  // Campos do popup
  final _nomeController = TextEditingController();
  final _escolaController = TextEditingController();
  String turnoSelecionado = "Vespertino";

  @override
  void initState() {
    super.initState();
    carregarTurmas();
  }

  Future<void> carregarTurmas() async {
    setState(() => carregando = true);

    // Pega IDs das turmas do professor
    final turmaIds = await Supabase.instance.client
        .from('professor_turma')
        .select('id_turma')
        .eq('id_professor', widget.idProfessor);

    if (turmaIds.isEmpty) {
      setState(() {
        turmas = [];
        carregando = false;
      });
      return;
    }

    final ids = turmaIds.map((t) => t['id_turma']).toList();

    final response = await Supabase.instance.client
        .from('turma')
        .select()
        .inFilter('id', ids)
        .order('nome', ascending: true);

    setState(() {
      turmas = List<Map<String, dynamic>>.from(response);
      carregando = false;
    });
  }

  Future<void> criarTurma() async {
    final nome = _nomeController.text.trim();
    final escola = _escolaController.text.trim();

    if (nome.isEmpty || escola.isEmpty) return;

    // Cria turma (UUID do Supabase é automático)
    final turmaInsert = await Supabase.instance.client
        .from('turma')
        .insert({
          'nome': nome,
          'escola': escola,
          'turno': turnoSelecionado,
        })
        .select()
        .single();

    // Relaciona com o professor
    await Supabase.instance.client.from('professor_turma').insert({
      'id_professor': widget.idProfessor,
      'id_turma': turmaInsert['id'],
    });

    _nomeController.clear();
    _escolaController.clear();
    turnoSelecionado = "Vespertino";

    await carregarTurmas();
  }

  void mostrarDialogCriarTurma() {
    showGeneralDialog(
      context: context,
      barrierLabel: "Criar Turma",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(22),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Criar Nova Turma",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome da Turma",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _escolaController,
                    decoration: const InputDecoration(
                      labelText: "Escola",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: turnoSelecionado,
                    decoration: const InputDecoration(
                      labelText: "Turno",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "Vespertino", child: Text("Vespertino")),
                      DropdownMenuItem(
                          value: "Integral", child: Text("Integral")),
                      DropdownMenuItem(
                          value: "Noturno", child: Text("Noturno")),
                    ],
                    onChanged: (v) => setState(() => turnoSelecionado = v!),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("Cancelar"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await criarTurma();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                        ),
                        child: const Text("Criar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Minhas Turmas",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue[300],
        elevation: 2,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : turmas.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhuma turma cadastrada.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: turmas.length,
                  itemBuilder: (context, index) {
                    final turma = turmas[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TurmaDetalhe(
                              turmaId: turma['id'],
                              turmaNome: turma['nome']
                            ),
                          ),
                        ).then((_) => carregarTurmas());
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue[200],
                              child: const Icon(Icons.school,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    turma['nome'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "${turma['escola']} • ${turma['turno']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 28),
                          ],
                        ),
                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[300],
        onPressed: mostrarDialogCriarTurma,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
