import 'package:educare/Telas/Aluno/ConfigurarPulseira.dart';
import 'package:educare/Telas/Aluno/EditarDadosAluno.dart';
import 'package:educare/Telas/Aluno/RotinaAluno.dart';
import 'package:educare/Telas/Login.dart';
import 'package:educare/Telas/Questionario.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'DiarioAluno.dart';
import 'EstadoEmocional.dart';

class InicioAluno extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final Map<String, dynamic> aluno;
  const InicioAluno({super.key, required this.usuario, required this.aluno});

  @override
  State<InicioAluno> createState() => InicioAlunoState();
}

class InicioAlunoState extends State<InicioAluno> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _verificarQuestionario();
  }

  Future<void> _verificarQuestionario() async {
    try {
      final questionario = await supabase
          .from('questionario_resp')
          .select('id_aluno')
          .eq('id_aluno', widget.aluno['id'])
          .maybeSingle();

      if (questionario == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Questionario(usuario: widget.usuario, aluno: widget.aluno),
          ),
        );
      }
    } catch (e) {
      print('Erro ao verificar questionário: $e');
    }
  }

  void _mostrarDialogoSair() {
    final parentContext = context;

    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Tem certeza de que deseja sair da sua conta?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Supabase.instance.client.auth.signOut();
                if (!mounted) return;

                Navigator.of(parentContext).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Login()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 50),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.lightBlue[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.lightBlue[300]!, Colors.blue[400]!]),
              ),
              accountName: Text(widget.usuario['nome'] ?? 'Aluno'),
              accountEmail: Text(widget.usuario['email'] ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.lightBlue, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.lightBlue),
              title: const Text('Editar Dados'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditarDadosAluno(alunoId: widget.aluno['id'])),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.watch, color: Colors.lightBlue),
              title: const Text('Configurar Pulseira'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConfigurarPulseira()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: _mostrarDialogoSair,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text('Início', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${widget.usuario['nome']}!',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Bem-vindo de volta!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                _buildCardButton(
                  icon: Icons.menu_book,
                  title: 'Diário',
                  color: Colors.blue[400]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiarioAluno(idAluno: widget.aluno['id']),
                      ),
                    );
                  },
                ),
                _buildCardButton(
                  icon: Icons.sentiment_very_satisfied,
                  title: 'Estado Emocional',
                  color: Colors.purple[400]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EstadoEmocional(idAluno: widget.aluno['id']),
                      ),
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                _buildCardButton(
                  icon: Icons.schedule,
                  title: 'Rotina',
                  color: Colors.orange[400]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RotinaAluno()),
                    );
                  },
                ),
                _buildCardButton(
                  icon: Icons.watch,
                  title: 'Configurar Pulseira',
                  color: Colors.green[400]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConfigurarPulseira()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
