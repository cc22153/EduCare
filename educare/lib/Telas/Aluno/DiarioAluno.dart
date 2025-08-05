import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiarioAluno extends StatefulWidget {
  final String idAluno;
  const DiarioAluno({super.key, required this.idAluno});

  @override
  State<DiarioAluno> createState() => _DiarioAlunoState();
}

class _DiarioAlunoState extends State<DiarioAluno> {
  String? emocaoSelecionada;
  final TextEditingController descricaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlue[300],
        title: const Text(
          'DIÁRIO',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Como você se sentiu hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 20,
              children: [
                emocaoButton('😊', 'Feliz'),
                emocaoButton('😐', 'Neutro'),
                emocaoButton('😢', 'Triste'),
                emocaoButton('😠', 'Irritado'),
                emocaoButton('😰', 'Ansioso'),
                emocaoButton('😴', 'Cansado'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Conte um pouco de como foi seu dia, você conseguiu prestar atenção na aula hoje? O que achou das atividades que o professor(a) passou?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: descricaoController,
              minLines: 15,
              maxLines: 20,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
              ),
              onPressed: () {
                if (emocaoSelecionada != null &&
                    descricaoController.text.isNotEmpty) {
                  enviarDiario();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos!'),
                    ),
                  );
                }
              },
              child: const Text('ENVIAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget emocaoButton(String emoji, String emocao) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              emocaoSelecionada = emocao.toLowerCase();
            });
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(15),
            backgroundColor: emocaoSelecionada == emocao
                ? Colors.lightBlue[300]
                : Colors.white,
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
        ),
        Text(
          emocao,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Future<void> enviarDiario() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('diario').insert({
        'id_aluno': widget.idAluno,
        'humor_geral': emocaoSelecionada,
        'texto': descricaoController.text,
        'criado_em': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resposta enviada!')),
      );
      Navigator.pop(context);
    } catch (error) {
      print('Erro ao enviar diário: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar resposta. Tente novamente.')),
      );
    }
  }
}
