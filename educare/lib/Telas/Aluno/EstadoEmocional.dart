import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstadoEmocional extends StatefulWidget {
  final String idAluno;
  const EstadoEmocional({super.key, required this.idAluno});

  @override
  State<EstadoEmocional> createState() => _EstadoEmocionalState();
}

class _EstadoEmocionalState extends State<EstadoEmocional> {
  // Variáveis de estado existentes
  String? emocaoSelecionada;
  String? motivoSelecionado;
  final TextEditingController necessidadeController = TextEditingController();

  // NOVAS VARIÁVEIS DE ESTADO (Para as perguntas Sim/Não)
  String? dorFisica;
  String? querFicarSozinho;
  String? precisaAjuda;

  // Mapa para conversão de string para inteiro (usado no envio)
  static const Map<String, int> _yesNoMap = {"Sim": 1, "Não": 0};

  final supabase = Supabase.instance.client;

  // FUNÇÃO AUXILIAR PARA PERGUNTAS DE MÚLTIPLA ESCOLHA (chips)
  Widget buildChoiceQuestion(
    String question,
    String? groupValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return SizedBox(
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[900]), // AZUL ESCURO
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20), // AUMENTO DE ESPAÇAMENTO AQUI
          Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: options.map((option) {
              return ChoiceChip(
                label: Text(
                  option,
                  style: TextStyle(
                    color: groupValue == option ? Colors.white : Colors.black87,
                  ),
                ),
                selected: groupValue == option,
                selectedColor: Colors.lightBlue[300],
                onSelected: (selected) {
                  if (selected) {
                    onChanged(option);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> enviarEstadoEmocional() async {
    // Validação dos campos: Motivo e Necessidade não são obrigatórios
    if (emocaoSelecionada == null || dorFisica == null || querFicarSozinho == null || precisaAjuda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todas as perguntas de emoção e Sim/Não!")),
      );
      return;
    }

    try {
      await supabase.from('estado_emocional').insert({
        'id_aluno': widget.idAluno,
        'sentimento': emocaoSelecionada!.toLowerCase(),
        'motivo': motivoSelecionado, // Mantido (opcional)
        'texto': necessidadeController.text, // Mantido (opcional)
        
        // NOVOS CAMPOS COM CONVERSÃO DE STRING PARA INT (1 ou 0)
        'dor_fisica': _yesNoMap[dorFisica!],
        'quer_ficar_sozinho': _yesNoMap[querFicarSozinho!],
        'precisa_ajuda': _yesNoMap[precisaAjuda!],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enviado com sucesso!")),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Erro ao enviar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar: ${e.toString()}")),
      );
    }
  }

  Widget emocaoButton(String emoji, String titulo) {
    // ... (Mantido o código da função emocaoButton)
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
    // ... (Mantido o código da função motivoButton)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // PERGUNTA 1: EMOÇÃO
            Text(
              'Como está se sentindo agora?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[900]), // AZUL ESCURO
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                emocaoButton('😊', 'Feliz'),
                emocaoButton('😐', 'Neutro'),
                emocaoButton('😢', 'Triste'),
                emocaoButton('😠', 'Irritado'),
                emocaoButton('😰', 'Ansioso'),
                emocaoButton('😴', 'Cansado'),
              ],
            ),
            
            const SizedBox(height: 35), // ESPAÇAMENTO ENTRE SEÇÕES

            // PERGUNTA 2: MOTIVO (REINSERIDA)
            Text(
              'O que está te incomodando?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[900]), // AZUL ESCURO
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                motivoButton('Aula'),
                motivoButton('Pessoas'),
                motivoButton('Barulho'),
              ],
            ),
            
            const SizedBox(height: 30), // ESPAÇAMENTO ENTRE SEÇÕES

            // PERGUNTA 3: DOR FÍSICA
            buildChoiceQuestion(
              'Você está sentindo dor física?',
              dorFisica,
              ['Sim', 'Não'],
              (value) => setState(() => dorFisica = value),
            ),
            
            const SizedBox(height: 20), // ESPAÇAMENTO ENTRE SEÇÕES

            // PERGUNTA 4: QUER FICAR SOZINHO
            buildChoiceQuestion(
              'Você quer ficar sozinho agora?',
              querFicarSozinho,
              ['Sim', 'Não'],
              (value) => setState(() => querFicarSozinho = value),
            ),

            const SizedBox(height: 30), // ESPAÇAMENTO ENTRE SEÇÕES

            // PERGUNTA 5: PRECISA DE AJUDA
            buildChoiceQuestion(
              'Você precisa de ajuda?',
              precisaAjuda,
              ['Sim', 'Não'],
              (value) => setState(() => precisaAjuda = value),
            ),
            
            const SizedBox(height: 30), // ESPAÇAMENTO ENTRE SEÇÕES

            // BOTÃO ENVIAR
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
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
            const SizedBox(height: 20), // Espaçamento final
          ],
        ),
      ),
    );
  }
}