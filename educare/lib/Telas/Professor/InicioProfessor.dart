import 'package:educare/Telas/Professor/AdminTurmas.dart';
// import 'package:educare/Telas/Professor/TurmaDetalhe.dart'; // Não usado no código, mantido o import
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/Telas/Login.dart';
import 'Alunos.dart';
import 'NotificacoesProfessor.dart';
import 'ContatosProfessor.dart';
import 'EditarDadosProfessor.dart';

class InicioProfessor extends StatefulWidget {
  const InicioProfessor({super.key});

  @override
  State<InicioProfessor> createState() => InicioProfessorState();
}

class InicioProfessorState extends State<InicioProfessor> {
  
  // Função que mostra o pop-up de sair
  void _mostrarDialogoSair() {
    final parentContext = context; // <- Contexto da tela, que nunca desmonta dentro do diálogo

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
                Navigator.of(dialogContext).pop(); // fecha somente o diálogo

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
              size: width * 0.4, // Tamanho do ícone responsivo
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

  
  Widget _buildWelcomeCard() {
   
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Olá Professor(a)!",  
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF009ADA),
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Gerencie suas turmas e alunos que precisam de apoio.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 45) / 2; 

    return Scaffold(
      backgroundColor: Colors.lightBlue[100],

      appBar: AppBar(
        // Título e ícone de voltar em branco e centralizado
        title: const Center(
          child: Text(
            'INÍCIO', 
            style: TextStyle(color: Colors.white)
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white), // Ícone do menu branco
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader( // Header ajustado para o alinhamento da esquerda
              margin: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                color: Colors.lightBlue,
              ),
              padding: const EdgeInsets.only(top: 10, left: 15),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(
                    'Menu',
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
                  MaterialPageRoute(builder: (context) => const EditarDadosProfessor()),
                ); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: _mostrarDialogoSair, // Chama o pop-up
            ),
          ],
        ),
      ),
     body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cartão de Boas-Vindas
            _buildWelcomeCard(),
            const SizedBox(height: 25),       

            
            Wrap(
              spacing: 15, 
              runSpacing: 15, 
              children: [
                // 1. ALUNOS
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Alunos',
                  icon: Icons.group_outlined, // Ícone de grupo/alunos
                  color: const Color.fromARGB(255, 61, 178, 217), // Cor Padrão 1
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Alunos()),
                    );
                  },
                ),
                
                // 2. NOTIFICAÇÕES (ALERTAS DE CRISE)
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Alertas',
                  icon: Icons.notifications_active_outlined, // Ícone de alerta
                  color: const Color.fromARGB(255, 245, 66, 66), // Cor Vermelha para Alerta
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificacoesProfessor()),
                    );
                  },
                ),
                
                // 3. CONTATOS
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Contatos',
                  icon: Icons.people_alt_outlined, // Ícone de contato
                  color: const Color.fromARGB(255, 255, 226, 61), // Cor Padrão 2
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContatosProfessor()),
                    );
                  },
                ),
                
                // 4. TURMAS
                _buildGridButton(
                  width: buttonWidth,
                  title: 'Turmas',
                  icon: Icons.class_outlined, // Ícone de turma/escola
                  color: const Color.fromARGB(255, 85, 158, 88), // Cor Padrão 3
                  onTap: () {
                    final id = Supabase.instance.client.auth.currentUser?.id;
                    if (id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminTurmas(idProfessor: id)),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20), // Espaço no final
          ],
        ),
      ),
    );
  } 
  // O widget botaoPadrao foi removido, pois foi substituído pelo _buildGridButton
}