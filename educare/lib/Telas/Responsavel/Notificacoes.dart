import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 

class Notificacoes extends StatefulWidget {
  const Notificacoes({super.key});

  @override
  State<Notificacoes> createState() => _NotificacoesState();
}

class _NotificacoesState extends State<Notificacoes> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notificacoesGerais = [];

  Map<String, dynamic>? relatorioProfessorNaoLido;
  bool carregando = true;
  bool mostrarHumor = true; 

  @override
  void initState() {
    super.initState();
    carregarTudo();
  }
  
  Future<void> carregarTudo() async {
    setState(() {
      carregando = true; 
    });
    await carregarRelatorioProfessor();
    await carregarNotificacoesGerais();
    
    setState(() {
      carregando = false;
    });
  }

  Future<void> carregarRelatorioProfessor() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    // 1. Pegar alunos do responsável
    final alunosResp = await supabase
        .from('responsavel_aluno')
        .select('id_aluno')
        .eq('id_responsavel', userId);
    final idsAlunos = alunosResp.map((e) => e['id_aluno']).toList();

    if (idsAlunos.isEmpty) {
        setState(() { relatorioProfessorNaoLido = null; });
        return;
    }

    try {
      // Buscar o relatório mais recente e NÃO LIDO
      final response = await supabase
          .from('relatorios_professor')
          .select('*, aluno:id_aluno!inner(nome)') // Puxa o nome do aluno da tabela 'usuario'
          .inFilter('id_aluno', idsAlunos)
          .eq('lido_resp', false) 
          .order('criado_em', ascending: false)
          .limit(1) 
          .maybeSingle(); 

      setState(() {
        relatorioProfessorNaoLido = response;
      });
      
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar Relatório Professor: $e');
    }
  }
  
  Future<void> carregarNotificacoesGerais() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final alunosResp = await supabase
        .from('responsavel_aluno')
        .select('id_aluno')
        .eq('id_responsavel', userId);
    final idsAlunos = alunosResp.map((e) => e['id_aluno']).toList();
    
    try {
        final dados = await supabase
            .from('notificacoes') // CORRETO: Plural
            .select('id, titulo, tipo, id_aluno, visualizada, enviado_em') 
            .inFilter('id_aluno', idsAlunos) 
            .order('enviado_em', ascending: false); 

        notificacoesGerais = List<Map<String, dynamic>>.from(dados);

    } catch (e) {
        // ignore: avoid_print
        print('Erro ao carregar Notificações Gerais: $e');
    }
  }


  Future<void> marcarRelatorioComoVisto() async {
    if (relatorioProfessorNaoLido == null) return;
    
    try {
      await supabase
          .from('relatorios_professor')
          .update({'lido_resp': true})
          .eq('id', relatorioProfessorNaoLido!['id']);

      await carregarRelatorioProfessor(); // Carrega o próximo
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relatório marcado como lido!')),
      );

    } catch (e) {
      // ignore: avoid_print
      print('Erro ao marcar relatório como visto: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao marcar relatório como lido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool estaBem = true; // Variável simulada de humor
    
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Center(
          child: Text(
            'NOTIFICAÇÕES',
            style: TextStyle(color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
            
              if (mostrarHumor) ...[
                _buildSectionHeader('Como seu filho(a) está se sentindo:'),
                const SizedBox(height: 10),
                _buildHumorCard(estaBem),
                const SizedBox(height: 10),
                _buildVistoButton(() {
                    setState(() {
                      mostrarHumor = false;
                    });
                  }),
                const SizedBox(height: 20),
              ],

              // 2. NOVO RELATÓRIO DO PROFESSOR
              if (relatorioProfessorNaoLido != null) ...[
                _buildSectionHeader('⚠️ NOVO RELATÓRIO DO(A) PROFESSOR(A)'),
                const SizedBox(height: 10),
                _buildRelatorioProfessorCard(relatorioProfessorNaoLido!),
                const SizedBox(height: 10),
                _buildVistoButton(marcarRelatorioComoVisto),
                const SizedBox(height: 20),
              ],
              
              // 3. Seção Notificações Gerais
              if (notificacoesGerais.isNotEmpty) ...[
                _buildSectionHeader('Notificações gerais:'),
                const SizedBox(height: 10),
                ...notificacoesGerais.map((n) {
                  bool lida = n['visualizada'] ?? false; // Usando 'visualizada' do seu schema
                  final String titulo = n['titulo'] ?? 'Sem Título';
                  final String mensagem = n['tipo'] ?? 'Sem mensagem'; // Usando tipo como mensagem
                  final String dataString = n['enviado_em'] ?? '';
                  final String dataHoraFormatada = dataString.isNotEmpty
                      ? DateFormat('dd/MM HH:mm').format(DateTime.parse(dataString))
                      : 'Sem data';
                      
                  return _buildGeneralNotificationCard(
                    titulo: titulo,
                    mensagem: mensagem,
                    lida: lida,
                    data: dataHoraFormatada,
                    onMarkAsRead: () async {
                      await supabase
                          .from('notificacoes')
                          .update({'visualizada': true}).eq('id', n['id']);
                      setState(() {
                        n['visualizada'] = true;
                      });
                    },
                  );
                }).toList(),
              ],
              
              if (relatorioProfessorNaoLido == null && notificacoesGerais.isEmpty && !mostrarHumor)
                const Center(
                  child: Text(
                    "Você não tem notificações ou relatórios pendentes.",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // WIDGETS DE ESTILO

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHumorCard(bool estaBem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: estaBem ? Colors.green.shade400 : Colors.red.shade400,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            estaBem ? Icons.sentiment_satisfied_alt : Icons.sentiment_dissatisfied,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              estaBem ? 'Estou bem!' : 'Não estou bem.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVistoButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade400, // Cor de visto/confirmação
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 3,
        ),
        child: const Text(
          'MARCAR COMO VISTO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  Widget _buildRelatorioProfessorCard(Map<String, dynamic> relatorio) {
    final alunoNome = relatorio['aluno'] != null ? relatorio['aluno']['nome'] ?? 'Aluno' : 'Aluno';
    final textoRelatorio = relatorio['texto'] ?? 'Relatório sem conteúdo.';
    final criadoEm = relatorio['criado_em'] != null 
        ? DateFormat('dd/MM HH:mm').format(DateTime.parse(relatorio['criado_em']))
        : 'Sem data';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade700, width: 2), // Borda de destaque
      ),
      child: ListTile(
        leading: Icon(Icons.menu_book, color: Colors.blue.shade700, size: 30),
        title: Text(
          'Relatório de $alunoNome ($criadoEm)', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        subtitle: Text(
          textoRelatorio,
          style: const TextStyle(color: Colors.black54),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: () {
          // Lógica para ir para a tela de relatório completo
        },
      ),
    );
  }
  
  Widget _buildGeneralNotificationCard({
    required String titulo,
    required String mensagem,
    required bool lida,
    required String data,
    required VoidCallback onMarkAsRead,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: lida ? Colors.grey[100] : Colors.white, 
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          Icons.message_outlined, 
          color: lida ? Colors.grey : Colors.blue.shade400,
          size: 30
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: lida ? Colors.grey : Colors.black87,
            decoration: lida ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              mensagem,
              style: TextStyle(color: lida ? Colors.grey : Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Enviado em $data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            lida ? Icons.done_all : Icons.mark_email_unread, 
            color: lida ? Colors.green : Colors.orange
          ),
          onPressed: onMarkAsRead,
        ),
      ),
    );
  }
}