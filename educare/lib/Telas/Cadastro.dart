// ignore_for_file: use_build_context_synchronously
import 'package:educare/Telas/Aluno/InicioAluno.dart';
import 'package:educare/Telas/Responsavel/InicioResponsavel.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Professor/InicioProfessor.dart';
import 'package:intl/intl.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => CadastroState();
}

class CadastroState extends State<Cadastro> {
  List<String> list = <String>['Professor', 'Responsável', 'Aluno'];
  String nome = "", senha = "", email = "";
  String dropdownValue = "Professor";

  // Campos extras para aluno
  String nomeResponsavel = "";
  String emailResponsavel = "";
  String codigoTurma = "";
  DateTime? dataNascimento;
  String? sexoSelecionado;
  String? nivelTEA;

  List<String> sexoOpcoes = ['masculino', 'feminino', 'outro'];
  List<String> niveisTEA = ['leve', 'moderado', 'grave'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Align(alignment: Alignment.centerLeft, child: Text('Cadastro')),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nome'),
              onChanged: (value) => nome = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => email = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
              onChanged: (value) => senha = value,
            ),
            Row(
              children: [
                const Text('Você é:'),
                const SizedBox(width: 10),
                DropdownButton(
                  value: dropdownValue,
                  items: list.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                ),
              ],
            ),
            if (dropdownValue == 'Aluno') ...[
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Nome do Responsável'),
                onChanged: (value) => nomeResponsavel = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Código da Turma'),
                onChanged: (value) => codigoTurma = value,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2015),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      dataNascimento = picked;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Data de Nascimento',
                      hintText: dataNascimento != null
                          ? DateFormat('dd/MM/yyyy').format(dataNascimento!)
                          : 'Selecione a data',
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: sexoSelecionado,
                hint: const Text("Sexo"),
                items: sexoOpcoes.map((sexo) {
                  return DropdownMenuItem(value: sexo, child: Text(sexo));
                }).toList(),
                onChanged: (value) => setState(() => sexoSelecionado = value),
              ),
              DropdownButtonFormField<String>(
                value: nivelTEA,
                hint: const Text("Nível de TEA"),
                items: niveisTEA.map((nivel) {
                  return DropdownMenuItem(value: nivel, child: Text(nivel));
                }).toList(),
                onChanged: (value) => setState(() => nivelTEA = value),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                cadastrarUsuario(
                  email: email,
                  senha: senha,
                  nome: nome,
                  tipoUsuario: dropdownValue.toLowerCase(),
                  id_responsavel: nomeResponsavel,
                  data_nascimento: dataNascimento,
                  sexo: sexoSelecionado,
                  nivel_tea: nivelTEA,
                  id_turma: codigoTurma,
                  context: context,
                );

              },
              child: const Text('CADASTRAR'),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String tipoUsuario,
    String? id_responsavel,
    DateTime? data_nascimento,
    String? sexo,
    String? nivel_tea,
    String? id_turma,
    required BuildContext context,
  }) async {
    final supabase = Supabase.instance.client;

    showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Resumo do Cadastro'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Nome: $nome'),
              Text('Email: $email'),
              Text('Tipo de Usuário: $tipoUsuario'),
              if (tipoUsuario == 'aluno') ...[
                Text('Email do Responsável: $emailResponsavel'),
                Text('Data de Nascimento: ${DateFormat('dd/MM/yyyy').format(dataNascimento!) }'),
                Text('Sexo: $sexo'),
                Text('Nível TEA: $nivelTEA'),
                Text('Turma: $id_turma'),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          )
        ],
      );
    },
  );


    try {
      if(tipoUsuario == "responsável"){tipoUsuario = "responsavel";}
      Map<String, dynamic>? aluno;

      final authResponse = await supabase.auth.signUp(
        email: email,
        password: senha,
      );

      final user = authResponse.user;
      if (user == null) throw Exception('Erro ao criar conta.');

      final userAuthenticated = await supabase
          .from('usuario')
          .insert({'id': user.id, 'nome': nome, 'tipo_usuario': tipoUsuario})
          .select()
          .single();

      final usuarioId = userAuthenticated['id'];

      if (tipoUsuario == 'aluno') {
        try {
          aluno = await supabase.from('aluno').insert({
            'id': usuarioId,
            'id_responsavel': id_responsavel,
            'data_nascimento': data_nascimento?.toIso8601String(),
            'sexo': sexo,
            'nivel_tea': nivel_tea,
            'id_turma': id_turma,
          });
          // 3. Inserir na tabela `responsavel_aluno`
          await supabase.from('responsavel_aluno').insert({
            'id_responsavel': id_responsavel,
            'id_aluno': usuarioId,
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar aluno: ${e.toString()}')),
          );
          return;
        }
      }


      if (tipoUsuario == 'aluno') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => InicioAluno(usuario: userAuthenticated, aluno: aluno!,)));
      } else if (tipoUsuario == 'professor') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InicioProfessor()));
      } else if (tipoUsuario == 'responsavel') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InicioResponsavel()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }
}
