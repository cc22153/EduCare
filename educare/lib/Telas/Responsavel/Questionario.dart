import 'package:flutter/material.dart';
import 'InicioResponsavel.dart';

class Questionario extends StatefulWidget {
  const Questionario({super.key});

  @override
  State<Questionario> createState() => _QuestionarioState();
}

class _QuestionarioState extends State<Questionario> {
  final TextEditingController idadeController = TextEditingController();
  String? sexoSelecionado;
  String? nivelAutismo;
  String? comunicacao;
  int? interacoesSociais;
  String? rotina;
  String? frequenciaCrises;

  // Agora é um Map para permitir múltiplas seleções:
  Map<String, bool> sensibilidades = {
    'Sons altos': false,
    'Luzes fortes': false,
    'Certas texturas (roupas, alimentos)': false,
    'Cheiros fortes': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Text('Questionário'),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _cardSecao([
              _tituloSecao('Idade do aluno:'),
              _campoIdade(),
            ]),
            const Divider(height: 32),

            _cardSecao([
              _radioGroup('Sexo:', ['Masculino', 'Feminino', 'Prefere não informar'], sexoSelecionado,
                  (val) => setState(() => sexoSelecionado = val)),
            ]),
            const Divider(height: 32),

            _cardSecao([
              _radioGroup('Nível do espectro autista (se souber):', ['Leve', 'Moderado', 'Severo'], nivelAutismo,
                  (val) => setState(() => nivelAutismo = val)),
            ]),
            const Divider(height: 32),

            _cardSecao([
              _radioGroup('A criança se comunica verbalmente?',
                  ['Sim, fluentemente', 'Sim, com dificuldades', 'Não verbal'], comunicacao,
                  (val) => setState(() => comunicacao = val)),
            ]),
            const Divider(height: 32),

            _cardSecao([
              _radioGroup(
                'Como a criança lida com interações sociais?\n(1 = Evita completamente / 5 = Busca constantemente)',
                ['1', '2', '3', '4', '5'],
                interacoesSociais?.toString(),
                (val) => setState(() => interacoesSociais = int.parse(val)),
              ),
            ]),
            const Divider(height: 32),

            _cardSecao([
              _radioGroup('A criança segue uma rotina diária estruturada?', ['Sim', 'Não', 'Parcialmente'], rotina,
                  (val) => setState(() => rotina = val)),
            ]),
            const Divider(height: 32),

            _cardSecao([
              _tituloSecao('Indique quais sensibilidades sensoriais a criança apresenta:'),
              ...sensibilidades.keys.map((item) {
                return CheckboxListTile(
                  title: Text(item),
                  value: sensibilidades[item],
                  activeColor: Colors.blueAccent,
                  onChanged: (bool? value) {
                    setState(() {
                      sensibilidades[item] = value ?? false;
                    });
                  },
                );
              }),
            ]),
            const Divider(height: 32),

            _cardSecao([
              _radioGroup('Com que frequência ocorrem crises?', [
                'Raramente',
                'Algumas vezes por semana',
                'Diariamente'
              ], frequenciaCrises, (val) => setState(() => frequenciaCrises = val)),
            ]),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aqui você pode salvar os dados, enviar para backend, etc.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const InicioResponsavel()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 25),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'ENVIAR QUESTIONÁRIO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
    );
  }

  Widget _campoIdade() {
    return TextField(
      controller: idadeController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Digite a idade',
      ),
    );
  }

  Widget _radioGroup(String titulo, List<String> opcoes, String? grupo, Function(String) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSecao(titulo),
        const SizedBox(height: 5),
        ...opcoes.map((opcao) => RadioListTile<String>(
              title: Text(opcao),
              value: opcao,
              groupValue: grupo,
              onChanged: (value) => onChange(value!),
              activeColor: Colors.blueAccent,
            )),
      ],
    );
  }

  Widget _cardSecao(List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
