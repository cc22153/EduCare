import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstadoEmocional extends StatefulWidget {
  final String idAluno;
  const EstadoEmocional({super.key, required this.idAluno});

  @override
  State<EstadoEmocional> createState() => _EstadoEmocionalState();
}

class _EstadoEmocionalState extends State<EstadoEmocional> {
  String? emocaoSelecionada;
  String? motivoSelecionado;
  final TextEditingController necessidadeController = TextEditingController();

  final supabase = Supabase.instance.client;

  Future<void> enviarEstadoEmocional() async {
    if (emocaoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma emoção")),
      );
      return;
    }

    try {
      await supabase.from('estado_emocional').insert({
        'id_aluno': widget.idAluno,
        'sentimento': emocaoSelecionada!.toLowerCase(),
        'motivo': motivoSelecionado,
        'texto': necessidadeController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enviado com sucesso!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar: $e")),
      );
    }
  }

  Widget emocaoButton(String emoji, String titulo) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              emocaoSelecionada = titulo.toLowerCase();
            });
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            backgroundColor: emocaoSelecionada == titulo.toLowerCase()
                ? Colors.lightBlue[300]
                : Colors.white,
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget motivoButton(String motivo) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: motivoSelecionado == motivo
            ? Colors.lightBlue[300]
            : Colors.white,
        foregroundColor: motivoSelecionado == motivo
            ? Colors.white
            : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.lightBlue, width: 1),
        ),
      ),
      onPressed: () {
        setState(() {
          motivoSelecionado = motivo;
        });
      },
      child: Text(motivo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlue[300],
        title: const Text(
          'ESTADO EMOCIONAL',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'Como você está se sentindo agora?',
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
                'O que está te deixando assim?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  motivoButton('Aula'),
                  motivoButton('Pessoas'),
                  motivoButton('Barulho'),
                ],
              ),
              const Text(
                'O que você precisa agora?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: necessidadeController,
                cursorColor: Colors.lightBlue[300],
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
                onPressed: enviarEstadoEmocional,
                child: const Text(
                  'ENVIAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
