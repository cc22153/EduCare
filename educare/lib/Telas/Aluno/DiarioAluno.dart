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
  String? gostouDia; 
  String? comunicacao; 
  String? fezOQueQueria; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlue[300],
        title: const Text(
          'DIÁRIO DO ALUNO',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Como você se sentiu hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[900]), // AZUL ESCURO
              textAlign: TextAlign.center, 
            ),
            const SizedBox(height: 20),
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
                    emocaoButton('😠', 'Irritado'),
                    emocaoButton('😰', 'Ansioso'),
                    emocaoButton('😴', 'Cansado')
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

         
            buildChoiceQuestion(
              'Você gostou do seu dia hoje?',
              gostouDia,
              ['Sim', 'Não'],
              (value) => setState(() => gostouDia = value),
            ),
            const SizedBox(height: 40),

         
            buildChoiceQuestion(
              'Você conseguiu se comunicar e interagir?',
              comunicacao,
              ['Sim', 'Não'],
              (value) => setState(() => comunicacao = value),
            ),
            const SizedBox(height: 40),

       
            buildChoiceQuestion(
              'Você conseguiu fazer o que queria hoje?',
              fezOQueQueria,
              ['Sim', 'Não', 'Um pouco'],
              (value) => setState(() => fezOQueQueria = value),
            ),
            const SizedBox(height: 60),


            // BOTÃO ENVIAR
            ElevatedButton(
              style: ElevatedButton.styleFrom(
           
                fixedSize: const Size(300, 50), 
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.lightBlue[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (emocaoSelecionada != null &&
                    gostouDia != null &&
                    comunicacao != null &&
                    fezOQueQueria != null) {
                  enviarDiario();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todas as perguntas obrigatórias!'),
                    ),
                  );
                }
              },
              child: const Text('ENVIAR RESPOSTAS', style: TextStyle(
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

  // FUNÇÃO AUXILIAR PARA PERGUNTAS DE MÚLTIPLA ESCOLHA
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[900]), 
          textAlign: TextAlign.center, 
        ),
        const SizedBox(height: 20), 
        Wrap(
          spacing: 10,
          alignment: WrapAlignment.center, 
          children: options.map((option) {
            return ChoiceChip(
              label: Text(
                option,
                style: TextStyle(
                  // Mantém o rótulo do chip com a cor padrão (ou branco se selecionado)
                  color: groupValue == option ? Colors.white : Colors.black87
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

  // FUNÇÃO DE ENVIO DE DADOS (MANTIDA)
  Future<void> enviarDiario() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('diario').insert({
        'id_aluno': widget.idAluno,
        'humor_geral': emocaoSelecionada, 

        'gostou_dia': gostouDia,
        'comunicou_aluno': comunicacao,
        'fez_o_que_queria': fezOQueQueria,       
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