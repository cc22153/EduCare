import 'package:educare/Services/supabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'Telas/Login.dart';
import 'Telas/Aluno/InicioAluno.dart';
import 'Telas/Professor/InicioProfessor.dart';
import 'Telas/Responsavel/InicioResponsavel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final supabase = Supabase.instance.client;

    final session = supabase.auth.currentSession;
    if (session == null) return const Login();

    final userId = session.user.id;

    // Busca o usuário pelo ID
    final response = await supabase
        .from('usuario')
        .select()
        .eq('id', userId)
        .single();

    final usuario = response;

    if (usuario['tipo_usuario'] == "aluno") {
      final aluno = await supabase
          .from('aluno')
          .select()
          .eq('id', usuario['id'])
          .single();

      return InicioAluno(usuario: usuario, aluno: aluno);
    }

    // Verifica tipo e redireciona
    switch (usuario['tipo_usuario']) {
      case 'professor':
        return InicioProfessor();
      case 'responsavel':
        return InicioResponsavel();
      default:
        return const Login(); // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduCare',
      theme: ThemeData(fontFamily: 'Poppins'),
      home: FutureBuilder(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Erro: ${snapshot.error}')),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
