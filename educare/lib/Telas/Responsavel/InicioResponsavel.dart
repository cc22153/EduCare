import 'dart:ffi';

import 'package:educare/Services/supabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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


  @override
  void initState() {
    super.initState();
  }
  void buscarDiariosDeHoje() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;
    // 1. Pegar IDs dos alunos do responsável
    final responseResponsavelAlunos = await supabase
        .from('responsavel_aluno')
        .select('id_aluno')
        .eq('id_responsavel', userId);

    final List<dynamic> alunos = responseResponsavelAlunos;
    if (alunos.isEmpty) {
      print('Nenhum aluno vinculado ao responsável');
      return;
    }

    // Extrair os IDs dos alunos
    final List<String> alunoIds =
        alunos.map((e) => e['id_aluno'].toString()).toList();

    // 2. Buscar entradas do diário de HOJE desses alunos
    final hoje = DateTime.now();
    final hojeFormatado = DateTime(hoje.year, hoje.month, hoje.day).toIso8601String();

    final responseDiarios = await supabase
        .from('diario')
        .select()
        .inFilter('id_aluno', alunoIds)
        .gte('criado_em', hojeFormatado) // data >= hoje 00:00
        .lt('criado_em', hoje.add(const Duration(days: 1)).toIso8601String()); // data < amanhã 00:00

    final diarios = responseDiarios;
    print(diarios);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResumoDiario(diarios: diarios)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar( 
        title: const Align(alignment: Alignment.centerLeft, child: Text('Início')),
        backgroundColor: Colors.lightBlue[300],
      ),
        drawer: Drawer(
          child: ListView(
            
            children: [
              const DrawerHeader(
                margin: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                ),
                padding: EdgeInsets.only(top: 110, right: 15),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.right
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
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (Route<dynamic> route) => false, // remove todas as rotas anteriores
                  );
                },
              ),
              /*ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Excluir Conta'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Excluir Conta'),
                        content: const Text(
                          'Tem certeza que deseja excluir sua conta? Esta ação não poderá ser desfeita.'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); 
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                );
                              },            
                              child: const Text('Excluir'),
                            ),
                          ],
                      );
                    },
                  );
                },
              ),*/
            ],
          ),
        ),
        body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              const SizedBox(height: 30),
              botaoPadrao('RESUMO DIÁRIO', () {
              buscarDiariosDeHoje();
            }),
            const SizedBox(height: 50),
              botaoPadrao('ROTINA', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Rotina()),
              );
            }),
            const SizedBox(height: 50),
            botaoPadrao('NOTIFICAÇÕES', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notificacoes()),
              );
            }),
            const SizedBox(height: 50),
            botaoPadrao('CONTATOS', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Contatos()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget botaoPadrao(String texto, VoidCallback onPressed) {
    
    return SizedBox(

      width: double.infinity, 
      height: 60, 
      
      child: ElevatedButton(  onPressed: onPressed,
 
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),

          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
