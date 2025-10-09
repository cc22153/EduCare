import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarDadosResponsavel extends StatefulWidget {
  const EditarDadosResponsavel({super.key});

  @override
  State<EditarDadosResponsavel> createState() => EditarDadosResponsavelState();
}

class EditarDadosResponsavelState extends State<EditarDadosResponsavel> {
  final supabase = Supabase.instance.client;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  Future<void> carregarDadosUsuario() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final nome = await supabase
          .from('usuario')
          .select('nome')
          .eq('id', userId)
          .maybeSingle();

      final dados = await supabase
          .from('contato')
          .select('email, telefone')
          .eq('id_usuario', userId)
          .maybeSingle();

      if (nome != null && dados != null) {
        nomeController.text = nome['nome'] ?? '';
        emailController.text = dados['email'] ?? '';
        telefoneController.text = dados['telefone'] ?? '';
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }

    setState(() {
      carregando = false;
    });
  }

  Future<void> atualizarDados() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('usuario').update({
        'nome': nomeController.text,
        'email': emailController.text,
        'telefone': telefoneController.text,
      }).eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
    } catch (e) {
      print('Erro ao atualizar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar os dados')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Editar Dados'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: telefoneController,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: atualizarDados,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[300],
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 40),
                      ),
                      child: const Text('ATUALIZAR'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
