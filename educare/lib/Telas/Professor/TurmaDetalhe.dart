import 'dart:async';
import 'package:educare/Telas/Professor/Alunos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _TurmaDetalheState extends State<TurmaDetalhe> with SingleTickerProviderStateMixin {
  bool carregando = true;

  Map<String, dynamic> turma = {};
  List<Map<String, dynamic>> alunos = [];

  // controllers (edição)
  final nomeCtrl = TextEditingController();
  final escolaCtrl = TextEditingController();
  String turnoSelecionado = "Vespertino";

  // add aluno (email)
  final alunoEmailCtrl = TextEditingController();

  // animação simples para o card
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    carregarTudo();
  }

  @override
  void dispose() {
    _animController.dispose();
    nomeCtrl.dispose();
    escolaCtrl.dispose();
    alunoEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> carregarTudo() async {
    setState(() => carregando = true);

    try {
      // busca turma
      final turmaResp = await Supabase.instance.client
          .from('turma')
          .select()
          .eq('id', widget.turmaId)
          .maybeSingle();

      if (turmaResp == null) {
        // turma não encontrada (possivelmente excluída)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Turma não encontrada.'), backgroundColor: Colors.red),
          );
          Navigator.pop(context);
        }
        return;
      }

      turma = Map<String, dynamic>.from(turmaResp);

      // busca alunos ligados pela tabela 'aluno' (campo id_turma)
      final alunosResp = await Supabase.instance.client
          .from('aluno')
          .select('id')
          .eq('id_turma', widget.turmaId);

      alunos = [];

      for (final a in alunosResp) {
        final userId = a['id'];

        // buscar nome no banco (tabela usuario)
        final usuario = await Supabase.instance.client
            .from('usuario')
            .select('nome')
            .eq('id', userId)
            .maybeSingle();

        // buscar email no auth
        final authUser = await Supabase.instance.client
            .rpc('buscar_usuario_por_id', params: {'user_id': userId})
            .maybeSingle();

        alunos.add({
          'id': userId,
          'nome': usuario?['nome'] ?? 'Sem nome',
          'email': authUser?['email'] ?? 'Email não encontrado',
        });
      }


      // start animation
      _animController.forward(from: 0);
    } catch (e) {
      // erro genérico
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  // ----- POPUP ANIMADO (ESCALA + OPACITY) -----
  Future<T?> _showAnimatedDialog<T>({required Widget child}) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dialog',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => Center(child: child),
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim.value),
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  // ----- EDITAR TURMA -----
  void editarTurmaPopup() {
    nomeCtrl.text = turma['nome'] ?? '';
    escolaCtrl.text = turma['escola'] ?? '';
    turnoSelecionado = turma['turno'] ?? 'Vespertino';

    _showAnimatedDialog(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Editar Turma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _styledTextField(controller: nomeCtrl, label: 'Nome da Turma'),
            const SizedBox(height: 10),
            _styledTextField(controller: escolaCtrl, label: 'Escola'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: turnoSelecionado,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Turno'),
              items: const [
                DropdownMenuItem(value: 'Vespertino', child: Text('Vespertino')),
                DropdownMenuItem(value: 'Integral', child: Text('Integral')),
                DropdownMenuItem(value: 'Noturno', child: Text('Noturno')),
              ],
              onChanged: (v) => setState(() => turnoSelecionado = v ?? turnoSelecionado),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
                onPressed: () async {
                  Navigator.pop(context);
                  await Supabase.instance.client
                      .from('turma')
                      .update({
                        'nome': nomeCtrl.text.trim(),
                        'escola': escolaCtrl.text.trim(),
                        'turno': turnoSelecionado,
                      })
                      .eq('id', widget.turmaId);
                  await carregarTudo();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turma atualizada')));
                },
                child: const Text('Salvar'),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ----- ADICIONAR ALUNO POR EMAIL -----
  void adicionarAlunoPopup() {
    alunoEmailCtrl.clear();

    _showAnimatedDialog(
      child: StatefulBuilder(
        builder: (context, setStateDialog) {
          String erroEmail = "";

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Adicionar aluno por email',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _styledTextField(
                    controller: alunoEmailCtrl,
                    label: 'Email do aluno',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  if (erroEmail.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      erroEmail,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () async {
                          final email = alunoEmailCtrl.text.trim();
                          if (email.isEmpty) return;

                          try {
                            // Buscar no AUTH via RPC (retorna JSON ou null)
                            final usuario = await Supabase.instance.client
                                .rpc('buscar_usuario_por_email', params: {
                                  'email_input': email,
                                });

                            // ❌ Email não encontrado
                            if (usuario == null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Nenhum usuário encontrado com este email."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            final userId = usuario['id'];

                            // Verificar se é um aluno
                            final aluno = await Supabase.instance.client
                                .from('aluno')
                                .select()
                                .eq('id', userId)
                                .maybeSingle();

                            // ❌ Existe no auth, mas não existe em aluno
                            if (aluno == null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Este usuário existe, mas não é um aluno."),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                              return;
                            }

                            // 3️⃣ Atualizar turma
                            await Supabase.instance.client
                                .from('aluno')
                                .update({'id_turma': widget.turmaId})
                                .eq('id', userId);

                            if (mounted) {
                              Navigator.pop(context);
                              carregarTudo();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Aluno adicionado à turma!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Erro ao procurar aluno: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Adicionar'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ----- EXCLUIR TURMA -----
  Future<void> excluirTurma() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Turma'),
        content: const Text('Tem certeza que deseja excluir esta turma? Essa ação é irreversível.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => carregando = true);

      // remover relacionamentos professor_turma
      await Supabase.instance.client.from('professor_turma').delete().eq('id_turma', widget.turmaId);

      // remover alunos vinculados? (opcional) aqui apenas remove a turma; se quiser, remova o campo id_turma dos alunos
      await Supabase.instance.client.from('aluno').update({'id_turma': null}).eq('id_turma', widget.turmaId);

      // remover turma
      await Supabase.instance.client.from('turma').delete().eq('id', widget.turmaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turma excluída'), backgroundColor: Colors.green));
        Navigator.pop(context); // volta para AdminTurmas
      }
    }
  }

  // helper: campo estilizado
  Widget _styledTextField({required TextEditingController controller, required String label, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }

  // copiar código da turma
  Future<void> copiarCodigo() async {
    final code = turma['id']?.toString() ?? '';
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado!')));
  }

  // remover aluno
  Future<void> removerAluno(String alunoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Aluno'),
        content: const Text('Tem certeza que deseja remover este aluno da turma?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remover', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.from('aluno').update({'id_turma': null}).eq('id', alunoId);
      await carregarTudo();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aluno removido'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.turmaNome, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: copiarCodigo,
            tooltip: 'Copiar código',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: excluirTurma,
            tooltip: 'Excluir turma',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[300],
        onPressed: adicionarAlunoPopup,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarTudo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Animated Card principal
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
                                child: const Icon(Icons.school, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(turma['nome'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text('${turma['escola'] ?? ''} • ${turma['turno'] ?? ''}', style: const TextStyle(color: Colors.black54)),
                                ]),
                              ),
                              // action icons: edit
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: editarTurmaPopup,
                                tooltip: 'Editar turma',
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(children: [
                            const Icon(Icons.vpn_key, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Código: ${turma['id']}', style: const TextStyle(fontWeight: FontWeight.w600))),
                            TextButton.icon(
                              onPressed: copiarCodigo,
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copiar'),
                            )
                          ]),
                        ]),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text('Alunos (${alunos.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // lista animada simples: fade-in cada card com delay
                  Column(
                    children: List.generate(alunos.length, (i) {
                      final aluno = alunos[i];
                      // simple staggered animation using TweenAnimationBuilder
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + i * 60),
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: Transform.translate(offset: Offset(0, (1 - value) * 8), child: child));
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(aluno['nome'] ?? ''),
                            subtitle: Text(aluno['email'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removerAluno(aluno['id'].toString()),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 60),
                ]),
              ),
            ),
    );
  }
}
