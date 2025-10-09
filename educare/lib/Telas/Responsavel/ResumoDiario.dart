import 'package:educare/Services/supabase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResumoDiario extends StatefulWidget {
  final List<Map<String, dynamic>> diarios;
  const ResumoDiario({super.key, required this.diarios});

  @override
  State<ResumoDiario> createState() => _ResumoDiarioState();
}

class _ResumoDiarioState extends State<ResumoDiario> {
  final Map<String, String> nomesAlunos = {};
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarNomes();
  }

  Future<void> carregarNomes() async {
    final supabase = Supabase.instance.client;

    final ids = widget.diarios.map((d) => d['id_aluno']).toSet().toList();

    for (final id in ids) {
      final response = await supabase
          .from('usuario')
          .select('nome')
          .eq('id', id)
          .maybeSingle();

      if (response != null && response['nome'] != null) {
        nomesAlunos[id] = response['nome'];
      } else {
        nomesAlunos[id] = 'Aluno desconhecido';
      }
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diarios = widget.diarios;
    diarios.sort((a, b) => b['data'].compareTo(a['data']));

    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Text('RESUMO DIÁRIO'),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : diarios.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum registro encontrado para hoje.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: diarios.length,
                  itemBuilder: (context, index) {
                    final diario = diarios[index];
                    final dataFormatada = DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(diario['criado_em']));
                    final nomeAluno =
                        nomesAlunos[diario['id_aluno']] ?? '...';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data: $dataFormatada',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _linhaResposta('Aluno:', nomeAluno),
                            const SizedBox(height: 10),
                            _linhaResposta(
                                'Como se sentiu:', diario['humor_geral']),
                            const SizedBox(height: 10),
                            _linhaResposta('Como foi:', diario['texto']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _linhaResposta(String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$titulo ',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
