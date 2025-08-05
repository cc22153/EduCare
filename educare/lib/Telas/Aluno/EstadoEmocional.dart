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
        InkWell(
          onTap: () {
            setState(() {
              emocaoSelecionada = titulo.toLowerCase();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: emocaoSelecionada == titulo.toLowerCase()
                  ? Colors.blue[200]
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(titulo),
      ],
    );
  }

  Widget motivoButton(String motivo) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: motivoSelecionado == motivo ? Colors.blue[300] : Colors.lightBlue,
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
        backgroundColor: Colors.lightBlue[300],
        title: const Text('ESTADO EMOCIONAL'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Como você está se sentindo agora?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  emocaoButton('😊', 'Feliz'),
                  emocaoButton('😐', 'Neutro'),
                  emocaoButton('😢', 'Triste'),
                  emocaoButton('😡', 'Irritado'),
                  emocaoButton('😰', 'Ansioso'),
                  emocaoButton('😴', 'Cansado'),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'O que está te deixando assim?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  motivoButton('Aula'),
                  motivoButton('Pessoas'),
                  motivoButton('Barulho'),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'O que você precisa agora?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: necessidadeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Digite aqui...',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: enviarEstadoEmocional,
                child: const Text('ENVIAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
