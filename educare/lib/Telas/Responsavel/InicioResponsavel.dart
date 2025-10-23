import 'package:educare/Services/supabase.dart'; 
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Mantenha todos os seus imports originais
import 'Questionario.dart'; 
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
  
  // Variável de estado para guardar o nome do usuário
  String _nomeResponsavel = 'Responsável'; 

  @override
  void initState() {
    super.initState();
    _fetchResponsavelName(); // Chama a busca do nome ao iniciar a tela
  }

  // Função para buscar o nome do responsável logado no Supabase
  void _fetchResponsavelName() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Assumindo que a tabela de usuário/responsável se chama 'responsavel'
      // E que ela tem uma coluna 'id' e 'nome'
      final response = await supabase
          .from('responsavel') 
          .select('nome')
          .eq('id', userId)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          _nomeResponsavel = response['nome'] ?? 'Responsável';
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao buscar nome do responsável: $e');
      setState(() {
        _nomeResponsavel = 'Responsável';
      });
    }
  }

  void buscarDiariosDeHoje() async {
    // ... (Seu código de buscarDiariosDeHoje permanece inalterado)
    final userId = supabase.auth.currentUser!.id;
    final responseResponsavelAlunos = await supabase
        .from('responsavel_aluno')
        .select('id_aluno')
        .eq('id_responsavel', userId);

    final List<dynamic> alunos = responseResponsavelAlunos;
    if (alunos.isEmpty) {
      // ignore: avoid_print
      print('Nenhum aluno vinculado ao responsável');
      // Lembrete: Adicionar uma mensagem visual para o usuário aqui.
      return;
    }

    final List<String> alunoIds =
        alunos.map((e) => e['id_aluno'].toString()).toList();

    final hoje = DateTime.now();
    final hojeFormatado = DateTime(hoje.year, hoje.month, hoje.day).toIso8601String();

    final responseDiarios = await supabase
        .from('diario')
        .select()
        .inFilter('id_aluno', alunoIds)
        .gte('criado_em', hojeFormatado) 
        .lt('criado_em', hoje.add(const Duration(days: 1)).toIso8601String()); 

    final diarios = responseDiarios;
    // ignore: avoid_print
    print(diarios);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResumoDiario(diarios: diarios)),
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
        title: const Align(
            alignment: Alignment.centerLeft, 
            child: Text(
              'Início', 
              style: TextStyle(color: Colors.white) // Refinamento: Cor do título em branco
            )
        ),
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white), // Refinamento: Cor do ícone do Drawer em branco
      ),
      
      // Drawer com refinamento de alinhamento
      drawer: Drawer(
        child: ListView(
            padding: EdgeInsets.zero, // Remove padding superior para alinhar o Header
            children: [
              DrawerHeader(
                margin: const EdgeInsets.all(0),
                decoration: const BoxDecoration(
                  color: Colors.lightBlue,
                ),
                padding: const EdgeInsets.only(top: 10, left: 15), // Ajuste de padding
                child: const Align(
                  alignment: Alignment.bottomLeft, // Alinha o texto na esquerda e em baixo
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Menu', // Refinamento: Agora alinhado à esquerda
                      style: TextStyle(color: Colors.white, fontSize: 24),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar Dados'),
                onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditarDadosResponsavel()),
                ); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Sair'),
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
      ),
      
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
                // RESUMO DIÁRIO
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Resumo Diário',
                  icon: Icons.assignment_outlined, 
                  color: const Color.fromARGB(255, 61, 178, 217), 
                  onTap: buscarDiariosDeHoje,
                ),
                
                // ROTINA
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Rotina',
                  icon: Icons.schedule_outlined, 
                  color: const Color.fromARGB(255, 85, 158, 88),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Rotina()),
                    );
                  },
                ),
                
                //  NOTIFICAÇÕES
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Notificações',
                  icon: Icons.notifications_none, 
                  color: const Color.fromARGB(255, 245, 66, 66),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Notificacoes()),
                    );
                  },
                ),
                
              // CONTATOS
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Contatos',
                  icon: Icons.people_alt_outlined, 
                  color: const Color.fromARGB(255, 255, 226, 61),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Contatos()),
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


  Widget _buildWelcomeCard(String nome) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seja Bem-Vindo!", // Alterado para exibir o nome
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF009ADA),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Tudo pronto para acompanhar o dia do seu filho",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Botão em Formato de Grade Quadrado (Inalterado)
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
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              size: width * 0.4, 
              color: Colors.white,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // O _buildInfoCard foi removido, seguindo a sua modificação.
}