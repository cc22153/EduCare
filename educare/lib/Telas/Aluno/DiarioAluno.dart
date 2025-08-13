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
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Como você se sentiu hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                Wrap(
                  spacing: 15,
                  children: [
                    emocaoButton('😊', 'Feliz'),
                    emocaoButton('😐', 'Neutro'),
                    emocaoButton('😢', 'Triste'),
                  ],
                ),
                Wrap(
                  spacing: 15,
                  children: [
                    emocaoButton('😠', 'Irritado'),
                    emocaoButton('😰', 'Ansioso'),
                    emocaoButton('😴', 'Cansado'),
                  ],
                ),
              ],
            ),
            const Text(
              'Conte um pouco de como foi seu dia, você conseguiu prestar atenção na aula hoje? O que achou das atividades que o professor(a) passou?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, wordSpacing: -1),
              textAlign: TextAlign.center,
            ),
            TextField(
              controller: descricaoController,
              cursorColor: Colors.lightBlue[300], // cor do cursor
              cursorWidth: 2,
              minLines: 5,
              maxLines: 20,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(79, 0, 0, 0), width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue[300]!, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(500, 25),
                backgroundColor: Colors.lightBlue[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              child: const Text('ENVIAR', style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),),
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
            padding: const EdgeInsets.all(5),
            backgroundColor: emocaoSelecionada == emocao.toLowerCase()
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
