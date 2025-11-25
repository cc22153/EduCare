// ignore_for_file: use_build_context_synchronously
import 'package:educare/Telas/Aluno/InicioAluno.dart';
import 'package:educare/Telas/Responsavel/InicioResponsavel.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Professor/InicioProfessor.dart';
import 'package:intl/intl.dart';
import 'Questionario.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => CadastroState();
}

class CadastroState extends State<Cadastro> {
  List<String> list = <String>['Professor', 'Responsável', 'Aluno'];
  String nome = "", senha = "", email = "";
  String dropdownValue = "Professor";
  final telefoneFormatter = MaskTextInputFormatter(
    mask: '+55 (##) #####-####',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  // Campos extras para aluno
  String nomeResponsavel = "";
  String emailResponsavel = ""; 
  String codigoTurma = "";
  String telefone = "";
  DateTime? dataNascimento;
  String? sexoSelecionado;
  String? nivelTEA;

  List<String> sexoOpcoes = ['masculino', 'feminino', 'outro'];
  List<String> niveisTEA = ['leve', 'moderado', 'grave'];

  // --- WIDGETS DE ESTILO (Reutilizados) ---
  Widget _buildStyledTextField(String label, String currentValue, {TextInputType keyboardType = TextInputType.text, List<MaskTextInputFormatter>? formatters, bool obscure = false, required Function(String) onChanged}) {
    return TextField(
      controller: TextEditingController(text: currentValue),
      keyboardType: keyboardType,
      inputFormatters: formatters,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black87),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.lightBlue[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildDateOfBirthField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2015),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.lightBlue[300]!,
                  onPrimary: Colors.white,
                  onSurface: Colors.black87,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.lightBlue[300],
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        setState(() {
          dataNascimento = picked;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.lightBlue[700],
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              dataNascimento != null
                  ? DateFormat('dd/MM/yyyy').format(dataNascimento!)
                  : 'Data de Nascimento',
              style: TextStyle(
                color: dataNascimento != null ? Colors.black87 : Colors.lightBlue[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Center(
          child: Text('CADASTRO', style: TextStyle(color: Colors.white))
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            
            _buildStyledTextField(
              'Nome', 
              nome,
              onChanged: (value) => nome = value,
            ),
            const SizedBox(height: 15),
            
            _buildStyledTextField(
              'Email', 
              email,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value,
            ),
            const SizedBox(height: 15),
            
            _buildStyledTextField(
              'Telefone', 
              telefone,
              keyboardType: TextInputType.phone,
              formatters: [telefoneFormatter],
              onChanged: (value) => telefone = value,
            ),
            const SizedBox(height: 15),
            
            _buildStyledTextField(
              'Senha', 
              senha,
              obscure: true,
              onChanged: (value) => senha = value,
            ),
            const SizedBox(height: 20),

            // Dropdown de tipo de usuário
            Row(
              children: [
                const Text('Você é:', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
                DropdownButton(
                  value: dropdownValue,
                  items: list.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(color: Colors.black87)));
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),

            if (dropdownValue == 'Aluno') ...[
              
              _buildStyledTextField(
                'Nome do Responsável', 
                nomeResponsavel,
                onChanged: (value) => nomeResponsavel = value,
              ),
              const SizedBox(height: 15),

              _buildStyledTextField(
                'Email do Responsável (Obrigatório)', 
                emailResponsavel,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => emailResponsavel = value,
              ),
              const SizedBox(height: 15),

              _buildStyledTextField(
                'Código da Turma', 
                codigoTurma,
                onChanged: (value) => codigoTurma = value,
              ),
              const SizedBox(height: 15),
              
              _buildDateOfBirthField(context),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: sexoSelecionado,
                hint: const Text("Sexo"),
                items: sexoOpcoes.map((sexo) {
                  return DropdownMenuItem(value: sexo, child: Text(sexo));
                }).toList(),
                onChanged: (value) => setState(() => sexoSelecionado = value),
              ),
              const SizedBox(height: 15),
              
              DropdownButtonFormField<String>(
                value: nivelTEA,
                hint: const Text("Nível de TEA"),
                items: niveisTEA.map((nivel) {
                  return DropdownMenuItem(value: nivel, child: Text(nivel));
                }).toList(),
                onChanged: (value) => setState(() => nivelTEA = value),
              ),
              const SizedBox(height: 15),
            ],
            const SizedBox(height: 30),
            
            // Botão CADASTRAR
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await cadastrarUsuario(
                    email: email,
                    senha: senha,
                    nome: nome,
                    tipoUsuario: dropdownValue.toLowerCase(),
                    email_responsavel: emailResponsavel,
                    data_nascimento: dataNascimento,
                    sexo: sexoSelecionado,
                    nivel_tea: nivelTEA,
                    id_turma: codigoTurma,
                    telefone: telefone,
                    context: context,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 61, 178, 217),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'CADASTRAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ])),
      ),
    );
  }

  // Função de cadastro corrigida para pegar UUID pelo email do responsável
  Future<void> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String tipoUsuario,
    String? email_responsavel,
    DateTime? data_nascimento,
    String? sexo,
    String? nivel_tea,
    String? id_turma,
    String? telefone,
    required BuildContext context,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      if(tipoUsuario == "responsável"){tipoUsuario = "responsavel";}
      Map<String, dynamic>? aluno;
      String? idResponsavel;

      // Busca UUID do responsável pelo EMAIL
      if (tipoUsuario == 'aluno' && email_responsavel != null && email_responsavel.isNotEmpty) {
        final respData = await supabase
            .from('contato')
            .select('id_usuario')
            .eq('email', email_responsavel)
            .maybeSingle(); 
        
        if (respData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: Email do Responsável não encontrado no sistema.')),
          );
          return;
        }
        idResponsavel = respData['id_usuario'];
      }

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

      if (telefone!.isNotEmpty) {
        await supabase.from('contato').insert({
          'id_usuario': usuarioId,
          'telefone': telefone,
          'nome': nome,
          'email': email,
        });
      }

      if (tipoUsuario == 'aluno') {
        aluno = await supabase.from('aluno').insert({
          'id': usuarioId,
          'id_responsavel': idResponsavel,
          'data_nascimento': data_nascimento?.toIso8601String(),
          'sexo': sexo,
          'nivel_tea': nivel_tea,
          'id_turma': id_turma != null && id_turma.isNotEmpty ? id_turma : null,
        }).select().single();

        if (idResponsavel != null) {
          await supabase.from('responsavel_aluno').insert({
            'id_responsavel': idResponsavel,
            'id_aluno': usuarioId,
          });
        }
      }

      // --- NAVEGAÇÃO ---
      if (tipoUsuario == 'aluno' && aluno != null) {
        final questionarioExistente = await supabase
            .from('questionario_resp')
            .select('id_aluno')
            .eq('id_aluno', usuarioId)
            .maybeSingle();

        if (questionarioExistente == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const Questionario(usuario: {}, aluno: {},),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => InicioAluno(usuario: userAuthenticated, aluno: aluno!),
            ),
          );
        }
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
