import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacoesProfessor extends StatefulWidget {
  const NotificacoesProfessor({super.key});

  @override
  State<NotificacoesProfessor> createState() => _NotificacoesProfessorState();
}

class _NotificacoesProfessorState extends State<NotificacoesProfessor> {
  bool carregando = true;

  List<Map<String, dynamic>> notificacoes = [];

  @override
  void initState() {
    super.initState();
    carregarNotificacoes();
  }

  Future<void> carregarNotificacoes() async {
    setState(() => carregando = true);

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => carregando = false);
      return;
    }
    final userId = user.id;

    try {
      // 1) pegar as turmas que o professor está associado (tabela professor_turma)
      final turmasResp = await supabase
          .from('professor_turma')
          .select('id_turma')
          .eq('id_professor', userId);

      final turmaIds = (turmasResp as List).map((t) => t['id_turma']).toList();
      if (turmaIds.isEmpty) {
        setState(() {
          notificacoes = [];
          carregando = false;
        });
        return;
      }

      // 2) pegar alunos dessas turmas (tabela aluno)
      final alunosResp = await supabase
          .from('aluno')
          .select('id, id_turma')
          .inFilter('id_turma', turmaIds);

      final alunoIds = (alunosResp as List).map((a) => a['id']).toList();
      if (alunoIds.isEmpty) {
        setState(() {
          notificacoes = [];
          carregando = false;
        });
        return;
      }

      // 3) pegar nomes dos alunos (tabela usuario)
      final usuariosResp = await supabase
          .from('usuario')
          .select('id, nome')
          .inFilter('id', alunoIds);

      final Map<String, String> alunosMap = {
        for (var u in (usuariosResp as List)) u['id'].toString(): (u['nome'] ?? 'Aluno') as String
      };

      // 4) buscar notificações relacionadas a esses alunos
      final notis = await supabase
          .from('notificacoes')
          .select()
          .inFilter('id_aluno', alunoIds)
          .order('enviado_em', ascending: false);

      notificacoes = (notis as List).map<Map<String, dynamic>>((n) {
        final dataRaw = n['enviado_em']?.toString() ?? DateTime.now().toIso8601String();
        return {
          'id': n['id'],
          'titulo': n['titulo'] ?? 'Notificação',
          'mensagem': n['mensagem'] ?? (n['tipo'] ?? ''),
          'tipo': n['tipo'] ?? 'geral',
          'data': dataRaw,
          'aluno_nome': alunosMap[n['id_aluno'].toString()] ?? 'Aluno',
          'visualizada': n['visualizada'] ?? false,
        };
      }).toList();
    } catch (e, st) {
      debugPrint('Erro buscando notificações: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao carregar notificações"),
            backgroundColor: Colors.red,
          ),
        );
      }
      notificacoes = [];
    }

    if (mounted) setState(() => carregando = false);
  }

  Future<void> marcarComoLida(String idNotificacao) async {
    final supabase = Supabase.instance.client;

    try {
      // Atualiza a notificação diretamente na tabela notificacoes
      await supabase
          .from('notificacoes')
          .update({'visualizada': true})
          .eq('id', idNotificacao);

      // Atualiza localmente
      final idx = notificacoes.indexWhere((n) => n['id'] == idNotificacao);
      if (idx != -1) {
        setState(() => notificacoes[idx]['visualizada'] = true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação marcada como lida'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro marcar como lida: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao marcar como lida'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Center(
          child: Text(
            'NOTIFICAÇÕES',
            style: TextStyle(color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: carregarNotificacoes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notificacoes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          "Você não tem novas notificações.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ...notificacoes.map((n) {
                      return _buildNotificationCard(
                        id: n['id'],
                        aluno: n['aluno_nome'],
                        titulo: n['titulo'],
                        mensagem: n['mensagem'],
                        tipo: n['tipo'],
                        data: DateFormat('dd/MM HH:mm').format(DateTime.parse(n['data'])),
                        visualizada: n['visualizada'] ?? false,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNotificationCard({
    required String id,
    required String aluno,
    required String titulo,
    required String mensagem,
    required String tipo,
    required String data,
    required bool visualizada,
  }) {
    final colorLeading = tipo == 'crise' ? Colors.red : Colors.blue.shade400;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: visualizada ? 1 : 4,
      color: visualizada ? Colors.grey[200] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: colorLeading,
          size: 32,
        ),
        title: Text(
          "$titulo – $aluno",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: visualizada ? Colors.grey : Colors.black87,
            decoration: visualizada ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              mensagem,
              style: TextStyle(
                color: visualizada ? Colors.grey : Colors.black54,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enviado em $data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            visualizada ? Icons.done_all : Icons.mark_email_unread,
            color: visualizada ? Colors.green : Colors.orange,
          ),
          onPressed: () => marcarComoLida(id),
        ),
      ),
    );
  }
}
