import 'package:flutter/material.dart';
import 'DetalhesAluno.dart'; 
import 'AdicionarAluno.dart'; 

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
                  listaAlunos.removeAt(index);
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
      body: ListView.builder(

        itemCount: listaAlunos.length,

        itemBuilder: (context, index) {

          return Card(
              
            child: ListTile(

              title: Text(listaAlunos[index]['nome']!),

              subtitle: Text(listaAlunos[index]['turma']!),

              trailing: IconButton(

                icon: const Icon(Icons.delete),
                onPressed: () {
                  removerAluno(index);
                },
              ),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                 builder: (context) => DetalhesAluno(
                 nomeAluno: listaAlunos[index]['nome']!,
                 turmaAluno: listaAlunos[index]['turma']!,
               ),
               ),
               );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[300],
        onPressed: () {Navigator.push(
                context,
                MaterialPageRoute(
                 builder: (context) => AdicionarAluno(),
               ),
               );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
