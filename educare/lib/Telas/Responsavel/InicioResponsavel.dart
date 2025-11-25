import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importa as telas
import '../Questionario.dart';
import 'Rotina.dart';
import 'Contatos.dart';
import 'ResumoDiario.dart';
import 'Notificacoes.dart';
import '/Telas/login.dart';
import 'EditarDadosResponsavel.dart';

class InicioResponsavel extends StatefulWidget {
  const InicioResponsavel({super.key});

  @override
  State<InicioResponsavel> createState() => InicioResponsavelState();
}

class InicioResponsavelState extends State<InicioResponsavel> {
  final supabase = Supabase.instance.client;

  String _nomeResponsavel = 'Responsável';
  Map<String, dynamic>? _alunoPendente;

  @override
  void initState() {
    super.initState();
    _fetchResponsavelName();
    _checkQuestionarioStatus();
  }

  void _mostrarDialogoSair() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: const Text('Tem certeza de que deseja sair da sua conta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const Login()),
                    (route) => false);
              }
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchResponsavelName() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('usuario')
          .select('nome')
          .eq('id', userId)
          .single();
      if (response.isNotEmpty && mounted) {
        setState(() {
          _nomeResponsavel = response['nome'] ?? 'Responsável';
        });
      }
    } catch (e) {
      print('Erro ao buscar nome do responsável: $e');
      setState(() => _nomeResponsavel = 'Responsável');
    }
  }

  Future<void> _checkQuestionarioStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final alunosResp = await supabase
          .from('responsavel_aluno')
          .select('id_aluno')
          .eq('id_responsavel', userId);
      final idsAlunos = alunosResp.map((e) => e['id_aluno']).toList();
      if (idsAlunos.isEmpty) return;

      final alunoPendenteResp = await supabase
          .from('aluno')
          .select('id, usuario:id!inner(nome), questionario_resp(id_aluno)')
          .inFilter('id', idsAlunos)
          .filter('questionario_resp.id_aluno', 'is', null)
          .limit(1)
          .maybeSingle();

      if (alunoPendenteResp != null && mounted) {
        setState(() {
          _alunoPendente = {
            'id': alunoPendenteResp['id'],
            'nome': alunoPendenteResp['usuario']['nome'] ?? 'Seu Aluno',
          };
        });
      }
    } catch (e) {
      print('Erro ao checar status do questionário: $e');
    }
  }

  void buscarDiariosDiariosDeHoje() async {
    final userId = supabase.auth.currentUser!.id;
    final responseResponsavelAlunos = await supabase
        .from('responsavel_aluno')
        .select('id_aluno')
        .eq('id_responsavel', userId);
    final List<dynamic> alunos = responseResponsavelAlunos;
    if (alunos.isEmpty) return;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResumoDiario()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 45) / 2;

    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 0),
          child: Text('Início', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(_nomeResponsavel),
            const SizedBox(height: 40),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Resumo Diário',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF3DB2D9),
                  onTap: buscarDiariosDiariosDeHoje,
                ),
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Rotina',
                  icon: Icons.schedule_outlined,
                  color: const Color(0xFF559E58),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Rotina()));
                  },
                ),
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Notificações',
                  icon: Icons.notifications_none,
                  color: const Color(0xFFF54242),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Notificacoes()));
                  },
                ),
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Contatos',
                  icon: Icons.people_alt_outlined,
                  color: const Color(0xFFFFE23D),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Contatos()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              color: Color(0xFF3DB2D9),
            ),
            padding: const EdgeInsets.only(top: 10, left: 15),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  _nomeResponsavel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF3DB2D9)),
            title: const Text('Editar Dados',
                style: TextStyle(color: Color(0xFF3DB2D9))),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditarDadosResponsavel()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: _mostrarDialogoSair,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String nome) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seja Bem-Vindo, $nome!",
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF009ADA)),
          ),
          const SizedBox(height: 5),
          const Text(
            "Tudo pronto para acompanhar o dia do seu filho",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGridButton({
    required double width,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      height: width,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: width * 0.4, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
