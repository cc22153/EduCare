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
          .from('usuario') // Assumindo que a tabela é 'usuario'
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
    // Ordenação mais robusta, garantindo que a coluna 'criado_em' existe
    diarios.sort((a, b) => b['criado_em'].compareTo(a['criado_em'])); 

    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        // Refinamento: Alinhar o título e deixar o texto em branco
        title: const Center( 
          child: Text(
            'RESUMO DIÁRIO',
            style: TextStyle(color: Colors.white), 
          ),
        ),
        // Refinamento: Centraliza o título, mas a AppBar tem que ser flexível para o botão de voltar
        centerTitle: true, 
        // Refinamento: Define a cor do ícone de voltar para branco
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white)) // Cor do progresso
          : diarios.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum registro encontrado para hoje.',
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.white, // Refinamento: Texto em branco
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: diarios.length,
                  itemBuilder: (context, index) {
                    final diario = diarios[index];
                    // Formato de data mais seguro, verificando o tipo
                    final dataString = diario['criado_em'] is String ? diario['criado_em'] : DateTime.now().toIso8601String();
                    final dataFormatada = DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(dataString));
                    final nomeAluno =
                        nomesAlunos[diario['id_aluno']] ?? 'Aluno não listado';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      color: const Color.fromARGB(255, 255, 255, 255), // Cartão Branco
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
                                color: Color.fromARGB(255, 61, 178, 217), // Cor de destaque no card
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Refinamento: Chama a nova _linhaResposta
                            _linhaResposta('Aluno:', nomeAluno),
                            const SizedBox(height: 10),
                            _linhaResposta(
                                'Como se sentiu:', diario['humor_geral']),
                            const SizedBox(height: 10),
                            _linhaResposta('Conseguiu fazer o que queria:', diario['fez_o_que_queria']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Refinamento: Função de Linha de Resposta com Texto Preto
  Widget _linhaResposta(String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$titulo ',
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: Colors.black, // Cor do título no card (Preto)
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54, // Cor do valor no card (Cinza/Preto)
            ),
          ),
        ),
      ],
    );
  }
}