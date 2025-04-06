import 'package:flutter/material.dart';

class Alunos extends StatefulWidget {
  const Alunos({super.key});

  @override
  State<Alunos> createState() => _AlunosState();
}

class _AlunosState extends State<Alunos> {
  List<Map<String, String>> listaAlunos = [
    {'nome': 'Aluno 1', 'turma': '3º Ano A'},
    {'nome': 'Aluno 2', 'turma': '2º Ano B'},
    {'nome': 'Aluno 3', 'turma': '1º Ano C'},
  ];

  void removerAluno(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover Aluno'),
          content: const Text('Deseja realmente remover este aluno?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  listaAlunos.removeAt(index); // Remover
                });
                Navigator.pop(context);
              },
              child: const Text('REMOVER'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: const Text('Alunos'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: listaAlunos.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(listaAlunos[index]['nome']!),
                subtitle: Text('Turma: ${listaAlunos[index]['turma']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    removerAluno(index);
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
        onPressed: () {
         
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tela de adicionar aluno ainda não implementada')),
          );
        },
      ),
    );
  }
}
