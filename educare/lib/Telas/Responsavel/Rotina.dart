import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Rotina extends StatefulWidget {
  const Rotina({super.key});

  @override
  State<Rotina> createState() => _RotinaState();
}

class _RotinaState extends State<Rotina> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> alunos = [];
  String? alunoSelecionadoId;

  List<Map<String, dynamic>> tarefas = [];

  final horarioController = TextEditingController();
  final tituloController = TextEditingController();
  final tarefaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarAlunosDoResponsavel();
  }

    
  Future<void> carregarAlunosDoResponsavel() async {
    final userId = supabase.auth.currentUser?.id;

    try {
      final response = await supabase
          .from('responsavel_aluno')
          .select('id_aluno')
          .eq('id_responsavel', userId!);

      // Lista final que vai armazenar os dados de id e nome
      List<Map<String, dynamic>> listaAlunos = [];

      for (var obj in response) {
        final idAluno = obj['id_aluno'];

        // Buscar o nome na tabela usuario usando o id do aluno
        final usuarioData = await supabase
            .from('usuario')
            .select('nome')
            .eq('id', idAluno)
            .single();

        final nomeAluno = usuarioData['nome'];

        listaAlunos.add({
          'id': idAluno,
          'nome': nomeAluno,
        });
      }

      setState(() {
        alunos = listaAlunos;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar alunos: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar alunos')),
      );
    }
  }



  Future<void> carregarTarefas(String alunoId) async {
    final response = await supabase
        .from('rotina')
        .select()
        .eq('id_aluno', alunoId)
        .order('data_hora', ascending: true);

    setState(() {
      tarefas = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> adicionarTarefa() async {
    if (alunoSelecionadoId == null) return;
    final userId = supabase.auth.currentUser?.id;

    if (tituloController.text.isEmpty || horarioController.text.isEmpty || tarefaController.text.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Preencha todos os campos para adicionar a tarefa!')),
       );
       return;
    }

    await supabase.from('rotina').insert({
      'id_aluno': alunoSelecionadoId,
      'titulo': tituloController.text,
      'data_hora': horarioController.text,
      'descricao': tarefaController.text,
      'id_criador': userId,
    });

    tituloController.clear();
    horarioController.clear();
    tarefaController.clear();

    // ignore: use_build_context_synchronously
    FocusScope.of(context).unfocus(); // Fecha o teclado
    
    await carregarTarefas(alunoSelecionadoId!);
  }
  
  // ATUALIZAR TAREFA
  // O ID agora é tratado como String, consistente com UUID
  Future<void> atualizarTarefa(String id, String novoTitulo, String novaDataHora, String novaDescricao) async {
    try {
      await supabase.from('rotina').update({
        'titulo': novoTitulo,
        'data_hora': novaDataHora,
        'descricao': novaDescricao,
      }).eq('id', id);

      if (alunoSelecionadoId != null) {
        await carregarTarefas(alunoSelecionadoId!);
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao atualizar tarefa: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar a tarefa')),
      );
    }
  }

  // REMOVER TAREFA 
  // O ID agora é tratado como String, consistente com UUID
  Future<void> removerTarefa(String id) async {
    try {
      await supabase.from('rotina').delete().eq('id', id);     

      if (alunoSelecionadoId != null) {
        await carregarTarefas(alunoSelecionadoId!);
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa removida com sucesso!')),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao remover tarefa: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover a tarefa')),
      );
    }
  }


  //  MOSTRAR DIALOG DE EDIÇÃO
  void mostrarDialogEditarTarefa(Map<String, dynamic> tarefa) {
    final tituloEditController = TextEditingController(text: tarefa['titulo']);
    final horarioEditController = TextEditingController(text: tarefa['data_hora']);
    final descricaoEditController = TextEditingController(text: tarefa['descricao']);
    
    // CORRIGIDO: O ID da tarefa é extraído e convertido para String (UUID)
    final tarefaId = tarefa['id'].toString(); 

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Tarefa"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStyledTextField(tituloEditController, 'Título:'),
                const SizedBox(height: 10),
                _buildStyledTextField(horarioEditController, 'Horário: (Ex: 10:00)'),
                const SizedBox(height: 10),
                _buildStyledTextField(descricaoEditController, 'Descrição da Tarefa:', maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tituloEditController.text.isNotEmpty && 
                    horarioEditController.text.isNotEmpty && 
                    descricaoEditController.text.isNotEmpty) {
                  
                  await atualizarTarefa(
                    tarefaId,
                    tituloEditController.text,
                    horarioEditController.text,
                    descricaoEditController.text,
                  );
                  Navigator.of(context).pop(); // Fecha o dialog
                } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Preencha todos os campos para salvar!')),
                   );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400], // Botão de confirmar verde
              ),
              child: const Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100], // Fundo padrão do app
      appBar: AppBar(
        // Refinamento: Título e ícone de voltar em branco
        title: const Center( 
          child: Text(
            'ROTINA DO ALUNO', 
            style: TextStyle(color: Colors.white)
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown de alunos (Estilizado)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lightBlue, width: 2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: alunoSelecionadoId,
                  hint: const Text(
                    "Selecione um aluno",
                    style: TextStyle(color: Colors.grey),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_downward, color: Colors.lightBlue),
                  items: alunos.map<DropdownMenuItem<String>>((aluno) {
                    return DropdownMenuItem<String>(
                      value: aluno['id'] as String,
                      child: Text(
                        aluno['nome'],
                        style: const TextStyle(color: Colors.black87),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      alunoSelecionadoId = value;
                    });
                    if (value != null) carregarTarefas(value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lista de tarefas
            Expanded(
              child: tarefas.isEmpty
                  ? Center(
                       child: Text(
                         alunoSelecionadoId == null 
                           ? "Selecione um aluno para ver as tarefas."
                           : "Nenhuma tarefa encontrada para este aluno.",
                         style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                       ),
                     )
                    : ListView.builder(
                        itemCount: tarefas.length,
                        itemBuilder: (context, index) {
                          final tarefa = tarefas[index];
                          final Color cardColor = index % 2 == 0 
                            ? Colors.white // Branco
                            : const Color.fromARGB(255, 230, 245, 255); // Azul claro
                            
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: cardColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: Icon(Icons.check_circle_outline, color: Colors.green[400]),
                              title: Text(
                                tarefa['titulo'] ?? 'Sem Título', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
                              ),
                              subtitle: Text(
                                "${tarefa['data_hora']} - ${tarefa['descricao'] ?? 'Sem descrição'}",
                                style: const TextStyle(color: Colors.black54),
                              ),
                              // ALTERAÇÃO: Ícones de Editar e Deletar
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                      IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                          onPressed: () => mostrarDialogEditarTarefa(tarefa), // Chama a função de edição
                                      ),
                                      IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                          // CORRIGIDO: Converte o ID para String para corresponder à assinatura da função removerTarefa (UUID)
                                          onPressed: () => removerTarefa(tarefa['id'].toString()), 
                                      ),
                                  ],
                              ),
                              onTap: () {
                                // A ação principal pode ser removida ou mantida
                              },
                            ),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 10),

            // Campos para adicionar tarefa (Com estilo Input padronizado)
            _buildStyledTextField(tituloController, 'Título:'),
            const SizedBox(height: 10),
            _buildStyledTextField(horarioController, 'Horário: (Ex: 10:00)'),
            const SizedBox(height: 10),
            _buildStyledTextField(tarefaController, 'Descrição da Tarefa:', maxLines: 2),
            const SizedBox(height: 20),
            
            // Botão Adicionar Tarefa (Estilizado)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: adicionarTarefa,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text(
                  'ADICIONAR TAREFA',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 61, 178, 217), // Cor padrão do app
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ),
             const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  
  Widget _buildStyledTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87), // Cor do texto digitado
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.lightBlue[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
        ),
      ),
    );
  }
}