import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'InicioResponsavel.dart';

class Questionario extends StatefulWidget {
  final String idAluno; // O ID do aluno que o responsável irá descrever
  final String nomeAluno; // Para melhor UX
  
  const Questionario({super.key, required this.idAluno, required this.nomeAluno});

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
  final List<String> nivelSuporteOpcoes = ['Nível 1 (Leve)', 'Nível 2 (Moderado)', 'Nível 3 (Severo)', 'Não sei informar'];
  final List<String> comunicacaoOpcoes = ['Com facilidade', 'Com alguma dificuldade', 'Não verbaliza'];
  final List<String> rotinaOpcoes = ['Sim', 'Não', 'Parcialmente'];
  final List<String> frequenciaOpcoes = ['Raramente', 'Algumas vezes por semana', 'Diariamente'];


  // ⬅️ LÓGICA DE ENVIO AGORA FAZ UPDATE NA TABELA ALUNO E INSERT NA questionario_resp
  Future<void> _enviarDados() async {
    // ignore: use_build_context_synchronously
    final BuildContext context = this.context;
    
    // Validação mínima
    if (idadeController.text.isEmpty || sexoAluno == null || nivelSuporte == null || interacaoSocialEscala == null) {
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
      // 1. UPDATE na tabela ALUNO (campos de preenchimento único)
      await supabase.from('aluno').update({
        'sexo': sexoAluno, 
        'nivel_tea': nivelSuporte, // Usa este campo como flag de preenchimento
      }).eq('id', widget.idAluno);
      
      // 2. UPSERT na nova tabela de 'questionario_resp' (dados do questionário)
      await supabase.from('questionario_resp').upsert({
        'id_aluno': widget.idAluno, // Chave de unicidade para o UPSERT
        'idade_aluno': int.tryParse(idadeController.text),
        'comunicacao_verbal_resp': comunicacaoVerbalResp,
        'interacao_social_escala': interacaoSocialEscala,
        'rotina_estruturada': rotinaEstruturada,
        'frequencia_crises': frequenciaCrises,
        'sensibilidades_json': sensibilidadesSelecionadas,
      }, onConflict: 'id_aluno'); // Usa id_aluno como chave de conflito para atualizar

      // Feedback e navegação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questionário enviado com sucesso!')),
      );

      // Navegação para a tela inicial
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioResponsavel()),
        );
      }
      
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao enviar questionário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar questionário: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100], 
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: Center(
          child: Text('Questionário - ${widget.nomeAluno}', style: const TextStyle(color: Colors.white)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Idade
            _cardSecao([
              _tituloSecao('Idade do aluno:'),
              const SizedBox(height: 10),
              _campoIdade(idadeController),
            ]),
            const SizedBox(height: 15),

            // Sexo
            _cardSecao([
              _tituloSecao('Sexo:'),
              _buildDropdown(
                ['masculino', 'feminino', 'outro'], // Strings do seu schema
                sexoAluno, 
                (val) => setState(() => sexoAluno = val)
              ),
            ]),
            const SizedBox(height: 15),

            // Nível de Suporte (TEA)
            _cardSecao([
              _tituloSecao('Nível de Suporte (TEA):'),
              _buildDropdown(
                nivelSuporteOpcoes, 
                nivelSuporte, 
                (val) => setState(() => nivelSuporte = val)
              ),
            ]),
            const SizedBox(height: 15),

            // Comunicação Verbal
            _cardSecao([
              _tituloSecao('A criança se comunica verbalmente?'),
              _buildDropdown(
                comunicacaoOpcoes, 
                comunicacaoVerbalResp, 
                (val) => setState(() => comunicacaoVerbalResp = val)
              ),
            ]),
            const SizedBox(height: 15),

            // Interação Social (Escala de 1 a 5)
            _cardSecao([
              _tituloSecao('Como a criança lida com interações sociais?\n(1 = Evita completamente / 5 = Busca constantemente)'),
              _buildDropdown(
                ['1', '2', '3', '4', '5'],
                interacaoSocialEscala?.toString(),
                (val) => setState(() => interacaoSocialEscala = int.tryParse(val!)),
              ),
            ]),
            const SizedBox(height: 15),

            // Rotina Estruturada
            _cardSecao([
              _tituloSecao('A criança segue uma rotina diária estruturada?'),
              _buildDropdown(
                rotinaOpcoes, 
                rotinaEstruturada, 
                (val) => setState(() => rotinaEstruturada = val)
              ),
            ]),
            const SizedBox(height: 15),

            // Sensibilidades (Checkbox)
            _cardSecao([
              _tituloSecao('Indique quais sensibilidades sensoriais a criança apresenta:'),
              const SizedBox(height: 5),
              ...sensibilidades.keys.map((item) {
                return CheckboxListTile(
                  title: Text(item, style: const TextStyle(color: Colors.black87)),
                  value: sensibilidades[item],
                  activeColor: const Color.fromARGB(255, 61, 178, 217), 
                  checkColor: Colors.white,
                  onChanged: (bool? value) {
                    setState(() {
                      sensibilidades[item] = value ?? false;
                    });
                  },
                );
              }).toList(),
            ]),
            const SizedBox(height: 15),

            // Frequência de Crises
            _cardSecao([
              _tituloSecao('Com que frequência ocorrem crises?'),
              _buildDropdown(
                frequenciaOpcoes, 
                frequenciaCrises, 
                (val) => setState(() => frequenciaCrises = val)
              ),
            ]),

            const SizedBox(height: 40),
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

  // --- WIDGETS DE ESTILO ---
  Widget _tituloSecao(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF009ADA)), 
    );
  }

  Widget _campoIdade(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
      style: const TextStyle(color: Colors.black87),
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
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
}