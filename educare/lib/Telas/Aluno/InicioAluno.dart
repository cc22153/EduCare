import 'package:educare/Telas/Aluno/PulseiraPage.dart';
import 'package:educare/Telas/Aluno/RotinaAluno.dart';
import 'package:educare/Telas/Login.dart';
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
  
  // Função que mostra o pop-up de sair
  void _mostrarDialogoSair() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Tem certeza de que deseja sair da sua conta e voltar para o login?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); 
                await Supabase.instance.client.auth.signOut();
                
                if (mounted) { 
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Login()),
                      (Route<dynamic> route) => false,
                    );
                }
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
              size: width * 0.45,
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

  
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlue[800]),
      title: Text(title, style: TextStyle(color: Colors.lightBlue[800])),
      onTap: onTap,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 45) / 2;

    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      
    
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(right: 50.0), 
            child: Text(
              'INÍCIO', 
              style: TextStyle(color: Colors.white)
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
       
        leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white), 
            onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      
  
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader( 
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
            
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Editar Dados',
              onTap: () {
                
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Navegar para Editar Dados'))
                 );
                Navigator.pop(context);
              },
            ),
            const Divider(),
            // OPÇÃO SAIR
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              title: 'Sair',
              onTap: () {
                _mostrarDialogoSair(); 
              },
            ),
          ],
        ),
      ),
     
    
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container de Boas-Vindas (MANTIDO)
            Container(
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
                    "Olá, ${widget.usuario['nome']}!", 
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF009ADA),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Container de Recados Importantes 
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color(0xFF009ADA),
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: const Column(
                children: [
                  Text(
                    "Recados Importantes!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Divider(
                    height: 10,
                    color: Colors.white,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Text(
                    "Do dia 18/04 ao 23/04 não teremos aulas!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Botão Rotina (MANTIDO ESTILO ORIGINAL)
            SizedBox(
              width: buttonWidth * 2.5,
              height: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RotinaAluno()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  alignment: const AlignmentDirectional(-0.8, 0),
                  backgroundColor: Colors.blue[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.EEEE('pt_BR').format(DateTime.now()).toUpperCase(),
                          style: const TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 221, 63, 52),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateTime.now().day.toString(),
                          style: const TextStyle(fontSize: 32, color: Colors.white),
                        )
                      ],
                    ),
                    const Text(
                      "Sem eventos hoje",
                      style: TextStyle(fontSize: 16, color: Colors.white54),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            // Botões Diário e Emoções (COM ESTÉTICA PROFESSOR/GRID)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. DIÁRIO (COM CORREÇÃO DE ROTA E NOVA ESTÉTICA)
                _buildGridButton(
                  width: buttonWidth,
                  title: 'DIÁRIO',
                  icon: Icons.menu_book, 
                  color: Colors.blue[300]!, 
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DiarioAluno(idAluno: widget.aluno['id']),
                      ),
                    );
                  },
                ),
                
                // 2. ESTADO EMOCIONAL (COM NOVA ESTÉTICA)
                _buildGridButton(
                  width: buttonWidth,
                  title: 'ESTADO EMOCIONAL',
                  icon: Icons.sentiment_very_satisfied, 
                  color: Colors.blue[300]!, 
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EstadoEmocional(idAluno: widget.aluno['id'])),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Botão Pulseira (MANTIDO ESTILO ORIGINAL)
            SizedBox(
              width: buttonWidth * 2.5,
              height: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PulseiraPage())
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/emoji.png', // Asset original
                      width: 110,
                      height: 110,
                    ),
                    const Text(
                      "PULSEIRA",
                      style: TextStyle(fontSize: 18, color: Colors.white, wordSpacing: -2),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // O IconButton que estava no Positioned foi movido para o AppBar como leading: IconButton(icon: Icon(Icons.menu)...)
    );
  }
}