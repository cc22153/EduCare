import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificacoes extends StatefulWidget {
  const Notificacoes({super.key});

  @override
  State<Notificacoes> createState() => _NotificacoesState();
}

class _NotificacoesState extends State<Notificacoes> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notificacoes = [];

  bool mostrarHumor = true;
  bool estaBem = true;
  bool mostrarAtividade = true;
  bool mostrarRelatorio = true;

  RealtimeChannel? canalNotificacoes;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _iniciarNotificacoesLocais();
    carregarNotificacoes();
    initRealtime();
  }

  void _iniciarNotificacoesLocais() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void mostrarNotificacao(String titulo, String mensagem) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'canal_notificacoes',
      'Notificações do app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      titulo,
      mensagem,
      platformDetails,
    );
  }

  @override
  void dispose() {
    canalNotificacoes?.unsubscribe();
    super.dispose();
  }

  Future<void> carregarNotificacoes() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final dados = await supabase
        .from('notificacoes')
        .select()
        .eq('id_usuario', userId)
        .order('created_at', ascending: false);

    setState(() {
      notificacoes = List<Map<String, dynamic>>.from(dados);
    });
  }

  void initRealtime() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final canal = supabase.channel('notificacoes:$userId');

    // Escutar INSERT na tabela notificacoes do usuário
    canal.onPostgresChanges(
      schema: 'public',
      table: 'notificacoes',
      event: PostgresChangeEvent.insert,
      filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id_usuario',
          value: userId),
      callback: (payload) {
        final novaNotificacao = payload.newRecord;

        setState(() {
          notificacoes.insert(0, novaNotificacao);
          if (novaNotificacao['tipo'] == 'humor') mostrarHumor = true;
          if (novaNotificacao['tipo'] == 'atividade') mostrarAtividade = true;
          if (novaNotificacao['tipo'] == 'relatorio') mostrarRelatorio = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nova notificação: ${novaNotificacao['titulo']}'),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );

    // Ativar o canal
    canal.subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Humor
              if (mostrarHumor) ...[
                const Text(
                  'Como seu filho(a) está se sentindo:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: estaBem ? Colors.green[300] : Colors.red[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    estaBem ? 'Estou bem!' : 'Não estou bem.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      mostrarHumor = false;
                    });
                  },
                  child: const Text('Visto'),
                ),
                const SizedBox(height: 20),
              ],

              // Atividades
              if (mostrarAtividade) ...[
                const Text(
                  'Atividades a serem realizadas:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: const Text('Há uma atividade a ser realizada.'),
                    trailing: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        setState(() {
                          mostrarAtividade = false;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Relatórios
              if (mostrarRelatorio) ...[
                const Text(
                  'Relatório da Professora:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: const Text(
                        'Hoje o aluno participou muito bem das atividades e se comportou de forma exemplar.'),
                    trailing: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        setState(() {
                          mostrarRelatorio = false;
                        });
                      },
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Lista de notificações gerais
              if (notificacoes.isNotEmpty) ...[
                const Text(
                  'Notificações gerais:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...notificacoes.map((n) {
                  bool lida = n['lida'] ?? false;
                  return Card(
                    color: lida ? Colors.grey[200] : Colors.white,
                    child: ListTile(
                      title: Text(n['titulo'] ?? ''),
                      subtitle: Text(n['mensagem'] ?? ''),
                      trailing: IconButton(
                        icon:
                            Icon(lida ? Icons.check : Icons.mark_email_unread),
                        onPressed: () async {
                          await supabase
                              .from('notificacoes')
                              .update({'lida': true}).eq('id', n['id']);
                          setState(() {
                            n['lida'] = true;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
