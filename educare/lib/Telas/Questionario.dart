import 'package:educare/Telas/Aluno/InicioAluno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Questionario extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final Map<String, dynamic> aluno;

  const Questionario({super.key, required this.usuario, required this.aluno});

  @override
  State<Questionario> createState() => _QuestionarioState();
}

class _QuestionarioState extends State<Questionario> {
  final supabase = Supabase.instance.client;
  final TextEditingController idadeController = TextEditingController();

  // Variáveis de estado
  String? sexoAluno;
  String? nivelSuporte;
  String? comunicacaoVerbalResp;
  int? interacaoSocialEscala;
  String? rotinaEstruturada;
  String? frequenciaCrises;

  Map<String, bool> sensibilidades = {
    'Sons altos': false,
    'Luzes fortes': false,
    'Certas texturas': false,
    'Cheiros fortes': false,
  };

  // Opções padronizadas
  final List<String> nivelSuporteOpcoes = [
    'Nível 1 (Leve)',
    'Nível 2 (Moderado)',
    'Nível 3 (Severo)',
    'Não sei informar'
  ];
  final List<String> comunicacaoOpcoes = [
    'Com facilidade',
    'Com alguma dificuldade',
    'Não verbaliza'
  ];
  final List<String> rotinaOpcoes = ['Sim', 'Não', 'Parcialmente'];
  final List<String> frequenciaOpcoes = [
    'Raramente',
    'Algumas vezes por semana',
    'Diariamente'
  ];

  // Enviar dados
  Future<void> _enviarDados() async {
    if (idadeController.text.isEmpty ||
        sexoAluno == null ||
        nivelSuporte == null ||
        interacaoSocialEscala == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return;
    }

    final List<String> sensibilidadesSelecionadas = sensibilidades.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    try {
      // Inserir/Atualizar questionário
      await supabase.from('questionario_resp').upsert({
        'id_aluno': widget.aluno['id'],
        'idade_aluno': int.tryParse(idadeController.text),
        'comunicacao_verbal_resp': comunicacaoVerbalResp,
        'interacao_social_escala': interacaoSocialEscala,
        'rotina_estruturada': rotinaEstruturada,
        'frequencia_crises': frequenciaCrises,
        'sensibilidades_json': sensibilidadesSelecionadas,
      }, onConflict: 'id_aluno');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questionário enviado com sucesso!')),
      );

      // Redireciona para a tela de início do aluno
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InicioAluno(
              usuario: widget.usuario, // Preencher com os dados reais do usuário se necessário
              aluno: widget.aluno,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar questionário: ${e.toString()}')),
      );
    }
  }

  // --- WIDGETS DE ESTILO ---
  Widget _tituloSecao(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Color(0xFF009ADA),
      ),
    );
  }

  Widget _campoIdade(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Colors.black87),
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        filled: true,
        fillColor: Colors.white,
        hintText: 'Digite a idade',
        hintStyle: TextStyle(color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF009ADA), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> opcoes, String? valorAtual, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: valorAtual,
        hint: const Text("Selecione uma opção", style: TextStyle(color: Colors.black54)),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        items: opcoes.map((opcao) {
          return DropdownMenuItem<String>(
            value: opcao,
            child: Text(opcao, style: const TextStyle(color: Colors.black87)),
          );
        }).toList(),
        onChanged: onChange,
      ),
    );
  }

  Widget _cardSecao(List<Widget> children) {
    return Card(
      elevation: 5,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: Center(
          child: Text('Questionário - ${widget.usuario['nome']}',
              style: const TextStyle(color: Colors.white)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _cardSecao([
              _tituloSecao('Idade do aluno:'),
              const SizedBox(height: 10),
              _campoIdade(idadeController),
            ]),
            _cardSecao([
              _tituloSecao('Sexo:'),
              _buildDropdown(['masculino', 'feminino', 'outro'], sexoAluno, (val) => setState(() => sexoAluno = val)),
            ]),
            _cardSecao([
              _tituloSecao('Nível de Suporte (TEA):'),
              _buildDropdown(nivelSuporteOpcoes, nivelSuporte, (val) => setState(() => nivelSuporte = val)),
            ]),
            _cardSecao([
              _tituloSecao('Se comunica verbalmente?'),
              _buildDropdown(comunicacaoOpcoes, comunicacaoVerbalResp, (val) => setState(() => comunicacaoVerbalResp = val)),
            ]),
            _cardSecao([
              _tituloSecao('Lida com interações sociais?\n(1 = Evita / 5 = Busca)'),
              _buildDropdown(['1','2','3','4','5'], interacaoSocialEscala?.toString(), (val) => setState(() => interacaoSocialEscala = int.tryParse(val!))),
            ]),
            _cardSecao([
              _tituloSecao('Segue uma rotina diária estruturada?'),
              _buildDropdown(rotinaOpcoes, rotinaEstruturada, (val) => setState(() => rotinaEstruturada = val)),
            ]),
            _cardSecao([
              _tituloSecao('Indique sensibilidades sensoriais:'),
              const SizedBox(height: 5),
              ...sensibilidades.keys.map((item) {
                return CheckboxListTile(
                  title: Text(item, style: const TextStyle(color: Colors.black87)),
                  value: sensibilidades[item],
                  activeColor: const Color.fromARGB(255, 61, 178, 217),
                  checkColor: Colors.white,
                  onChanged: (bool? value) => setState(() => sensibilidades[item] = value ?? false),
                );
              }).toList(),
            ]),
            _cardSecao([
              _tituloSecao('Frequência de crises:'),
              _buildDropdown(frequenciaOpcoes, frequenciaCrises, (val) => setState(() => frequenciaCrises = val)),
            ]),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _enviarDados,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 61, 178, 217),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'ENVIAR QUESTIONÁRIO',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
