import 'package:flutter/material.dart';
import 'InicioResponsavel.dart';

class Questionario extends StatefulWidget {
  const Questionario({super.key});

  @override
  State<Questionario> createState() => _QuestionarioState();
}

class _QuestionarioState extends State<Questionario> {
  
  final TextEditingController idadeController = TextEditingController();
  String? sexoAluno; // Corresponde a 'sexo_aluno'
  String? nivelTea; // Corresponde a 'nivel_tea'
  String? comunicacaoVerbalResp; // Corresponde a 'comunicacao_verbal_resp'
  int? interacaoSocialEscala; // Corresponde a 'interacao_social_escala'
  String? rotinaEstruturada; // Corresponde a 'rotina_estruturada'
  String? frequenciaCrises; // Corresponde a 'frequencia_crises'

  // 2. SENSIBILIDADES CORRIGIDAS (Strings padronizadas para o Python)
  Map<String, bool> sensibilidades = {
    'Sons altos': false,
    'Luzes fortes': false,
    'Certas texturas': false, // Corrigido para "Certas texturas" (removido "(roupas, alimentos)")
    'Cheiros fortes': false,
  };

  // Função fictícia para simular o envio de dados
  // Você deve substituir este corpo com a lógica real de Supabase/API
  void _enviarDados() {
    // 3. Monta o mapa de dados com as chaves exatas que o preprocessaDados.py espera
    final List<String> sensibilidadesSelecionadas = sensibilidades.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final Map<String, dynamic> dadosResponsavel = {
      // Campos numéricos e strings simples
      'idade_aluno': int.tryParse(idadeController.text) ?? 0,
      'sexo_aluno': sexoAluno,
      'nivel_tea': nivelTea,
      'comunicacao_verbal_resp': comunicacaoVerbalResp,
      'interacao_social_escala': interacaoSocialEscala,
      'rotina_estruturada': rotinaEstruturada,
      'frequencia_crises': frequenciaCrises,
      
      // Lista de sensibilidades (para processamento como one-hot encoding no Python)
      'sensibilidades': sensibilidadesSelecionadas,
      
      // Campos fictícios que são preenchidos por outros questionários,
      // mas que são necessários para a IA (caso este seja o único dado enviado)
      // *Remova estas chaves se você for juntar os dados de todos os questionários antes de enviar*
      //'frequencia_cardiaca_media': 0, // Exemplo
      //'nivel_agitacao_media': 0.0,    // Exemplo
    };

    // Aqui você faria o POST para a API ou INSERT no Supabase
    print("Dados do Responsável prontos para envio (JSON): $dadosResponsavel");

    // Navegação após "envio"
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InicioResponsavel()),
    );
  }

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
              _radioGroup('Sexo:', ['Masculino', 'Feminino', 'Prefere não informar'], sexoAluno,
                  (val) => setState(() => sexoAluno = val)),
            ]),
            const Divider(height: 32),

            _cardSecao([
              // Chave: 'nivel_tea'
              _radioGroup('Nível do espectro autista (se souber):', ['Leve', 'Moderado', 'Severo', 'Não sei informar'], nivelTea,
                  (val) => setState(() => nivelTea = val)),
            ]),
            const Divider(height: 32),

            _cardSecao([
              // Chave: 'comunicacao_verbal_resp'
              _radioGroup('A criança se comunica verbalmente?',
                  ['Com facilidade', 'Com alguma dificuldade', 'Não verbalizou'], comunicacaoVerbalResp, // Opções de mapeamento Python
                  (val) => setState(() => comunicacaoVerbalResp = val)),
            ]),
            const Divider(height: 32),

            _cardSecao([
              // Chave: 'interacao_social_escala'
              _radioGroup(
                'Como a criança lida com interações sociais?\n(1 = Evita completamente / 5 = Busca constantemente)',
                ['1', '2', '3', '4', '5'],
                interacaoSocialEscala?.toString(),
                (val) => setState(() => interacaoSocialEscala = int.parse(val)),
              ),
            ]),
            const Divider(height: 32),

            _cardSecao([
              // Chave: 'rotina_estruturada'
              _radioGroup('A criança segue uma rotina diária estruturada?', ['Sim', 'Não', 'Parcialmente'], rotinaEstruturada,
                  (val) => setState(() => rotinaEstruturada = val)),
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
              // Chave: 'frequencia_crises'
              _radioGroup('Com que frequência ocorrem crises?', [
                'Raramente',
                'Algumas vezes por semana',
                'Diariamente'
              ], frequenciaCrises, (val) => setState(() => frequenciaCrises = val)),
            ]),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                // 4. CHAMANDO A FUNÇÃO DE ENVIO
                onPressed: _enviarDados, 
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

