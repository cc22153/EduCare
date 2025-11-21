import 'package:educare/Services/supabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'Telas/Login.dart';
import 'Telas/Aluno/InicioAluno.dart';
import 'Telas/Professor/InicioProfessor.dart';
import 'Telas/Responsavel/InicioResponsavel.dart';
import 'package:app_links/app_links.dart'; 
import 'dart:async'; 
import 'Telas/RedefinirSenha.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MainApp());
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  final _appLinks = AppLinks();
  StreamSubscription? _sub;
  Widget? _initialScreen;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initAppLinks(); 
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final supabase = Supabase.instance.client;
    Widget initialScreen;

    try {
        final session = supabase.auth.currentSession;
        if (session == null) {
            initialScreen = const Login();
        } else {
            
            final userId = session.user.id;
            final response = await supabase
                .from('usuario')
                .select()
                .eq('id', userId)
                .single();
            final usuario = response;
            switch (usuario['tipo_usuario']) {
                case 'aluno':
                    final aluno = await supabase
                        .from('aluno')
                        .select()
                        .eq('id', usuario['id'])
                        .single();
                    initialScreen = InicioAluno(usuario: usuario, aluno: aluno);
                    break;
                case 'professor':
                    initialScreen = const InicioProfessor();
                    break;
                case 'responsavel':
                    initialScreen = const InicioResponsavel();
                    break;
                default:
                    initialScreen = const Login();
                    break;
            }
        }
    } catch (e) {
        await supabase.auth.signOut(); 
        initialScreen = const Login();
        // ignore: avoid_print
        print('Erro ao carregar sessão inicial: $e');
    }

    setState(() {
        _initialScreen = initialScreen;
        _isLoading = false;
    });
  }

  // CAPTURA DO APP LINK
  void _handleDeepLink(Uri uri) {
    // ignore: avoid_print
    print('Deep Link Capturado: $uri');

    // Verifica se a rota é a de redefinição de senha
    if (uri.path.contains('/reset-password') && uri.queryParameters.containsKey('access_token')) {
        // Navega para a tela de formulário
        if (mounted) {
             Navigator.of(context).push(
                 MaterialPageRoute(builder: (context) => const RedefinirSenha()),
             );
        }
    }
  }

  Future<void> _initAppLinks() async {
    //  Escuta links de inicialização (app fechado)
    try {
      final initialUri = await _appLinks.getInitialLink(); 
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Erro ao obter Initial URI (App Links): $e');
    }
    
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      // ignore: avoid_print
      print('Erro ao capturar Deep Link (Stream): $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduCare',
      theme: ThemeData(fontFamily: 'Poppins'),
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _initialScreen,
    );
  }
}