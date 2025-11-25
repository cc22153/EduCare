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

      // Se não existir questionário, redireciona
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
      // opcional: mostrar SnackBar ou alerta
    }
  }

 
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
  
  // Widget para item do Drawer 
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
        
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white), 
              onPressed: () {
                Scaffold.of(innerContext).openDrawer(); 
              },
            );
          },
        ),
      ),
      
     
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader( 
              margin:  EdgeInsets.all(0),
              decoration:  BoxDecoration(
                color: Colors.lightBlue,
              ),
              padding:  EdgeInsets.only(top: 10, left: 15),
              child:  Align(
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
                   const SnackBar(content: Text('Navegar para Editar Dados do Responsável'))
                 );
                Navigator.pop(context);
              },
            ),
            const Divider(),
            
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
            const SizedBox(height: 10),
            // Container
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
            
            const SizedBox(height: 30),
            
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
            const SizedBox(height: 35),
            
            // Botões Diário e Emoções 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1
                _buildGridButton(
                  width: buttonWidth,
                  title: 'DIÁRIO',
                  icon: Icons.menu_book, // Ícone novo
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
                
                // 2
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
            
            
          ],
        ),
      ),
    );
  }
}