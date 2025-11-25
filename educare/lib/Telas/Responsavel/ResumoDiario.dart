import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResumoDiario extends StatefulWidget {
  const ResumoDiario({super.key});

  @override
  State<ResumoDiario> createState() => _ResumoDiarioState();
}

class _ResumoDiarioState extends State<ResumoDiario> {
  final supabase = Supabase.instance.client;
  bool carregando = true;

  List<Map<String, dynamic>> itens = [];
  Map<String, String> nomesAlunos = {};

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => carregando = true);

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1) IDs dos alunos do responsável
      final resp = await supabase
          .from('responsavel_aluno')
          .select('id_aluno')
          .eq('id_responsavel', userId);
      final alunoIds = (resp as List).map((a) => a['id_aluno']).toList();
      if (alunoIds.isEmpty) {
        setState(() {
          itens = [];
          carregando = false;
        });
        return;
      }

      // 2) Nomes dos alunos
      final usuariosResp = await supabase
          .from('usuario')
          .select('id, nome')
          .inFilter('id', alunoIds);
      nomesAlunos = {
        for (var u in (usuariosResp as List))
          u['id'].toString(): u['nome'] ?? 'Aluno'
      };

      final hoje = DateTime.now();
      final hojeInicio = DateTime(hoje.year, hoje.month, hoje.day);
      final hojeFim = hojeInicio.add(const Duration(days: 1));

      // 3) Buscar diários
      final diariosResp = await supabase
          .from('diario')
          .select()
          .inFilter('id_aluno', alunoIds)
          .gte('criado_em', hojeInicio.toIso8601String())
          .lt('criado_em', hojeFim.toIso8601String());

      final diarios = (diariosResp as List).map((d) {
        return {
          'tipo': 'diario',
          'id': d['id'],
          'id_aluno': d['id_aluno'],
          'humor_geral': d['humor_geral'],
          'fez_o_que_queria': d['fez_o_que_queria'],
          'criado_em': d['criado_em'],
        };
      }).toList();

      // 4) Buscar relatórios
      final relatoriosResp = await supabase
          .from('relatorios_professor')
          .select()
          .inFilter('id_aluno', alunoIds)
          .order('criado_em', ascending: false);

      final relatorios = (relatoriosResp as List).map((r) {
        return {
          'tipo': 'relatorio',
          'id': r['id'],
          'id_aluno': r['id_aluno'],
          'texto': r['texto'],
          'lido_resp': r['lido_resp'] ?? false,
          'criado_em': r['criado_em'],
        };
      }).toList();

      // Combinar e ordenar
      itens = [...diarios, ...relatorios];
      itens.sort((a, b) => b['criado_em'].compareTo(a['criado_em']));
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      itens = [];
    }

    if (mounted) setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Center(
            child: Text('RESUMO', style: TextStyle(color: Colors.white))),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : itens.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum registro disponível.",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: carregarDados,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      final item = itens[index];
                      final nomeAluno =
                          nomesAlunos[item['id_aluno']] ?? 'Aluno';
                      return item['tipo'] == 'diario'
                          ? _buildCardDiario(item, nomeAluno)
                          : _buildCardRelatorio(item, nomeAluno);
                    },
                  ),
                ),
    );
  }

  Widget _buildCardDiario(Map<String, dynamic> diario, String nomeAluno) {
    final dataFormatada =
        DateFormat('dd/MM/yyyy').format(DateTime.parse(diario['criado_em']));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diário - $nomeAluno',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 61, 178, 217)),
            ),
            const SizedBox(height: 8),
            _linhaResposta('Como se sentiu:', diario['humor_geral']),
            const SizedBox(height: 6),
            _linhaResposta(
                'Conseguiu fazer o que queria:', diario['fez_o_que_queria']),
            const SizedBox(height: 6),
            Text(
              'Data: $dataFormatada',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRelatorio(Map<String, dynamic> relatorio, String nomeAluno) {
    final dataFormatada =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(relatorio['criado_em']));

    return GestureDetector(
      onTap: () => _mostrarRelatorioDetalhes(relatorio, nomeAluno),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.orange.shade300, Colors.orange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Relatório - $nomeAluno',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                relatorio['texto'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  dataFormatada,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      fontStyle: FontStyle.italic),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _linhaResposta(String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$titulo ',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Expanded(
          child: Text(
            valor ?? '-',
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
        )
      ],
    );
  }

  void _mostrarRelatorioDetalhes(
      Map<String, dynamic> relatorio, String nomeAluno) async {
    // Atualizar como lido
    if (relatorio['lido_resp'] != true) {
      await supabase
          .from('relatorios_professor')
          .update({'lido_resp': true})
          .eq('id', relatorio['id']);
      relatorio['lido_resp'] = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.report, color: Colors.orange, size: 30),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Detalhes do Relatório",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Aluno: $nomeAluno",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  relatorio['texto'] ?? '',
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 15),
                Text(
                  "Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(relatorio['criado_em']))}",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[300],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
