import 'package:flutter/material.dart';

class AtividadesProfessor extends StatefulWidget {
  const AtividadesProfessor({super.key});

  @override
  State<AtividadesProfessor> createState() => _AtividadesProfessorState();
}

class _AtividadesProfessorState extends State<AtividadesProfessor> {

  List<String> atividades = [
    'Ler um livro por 20 minutos',
    'Resolver exercícios de matemática',
    'Desenhar um animal favorito',
  ];

  final TextEditingController atividadeController = TextEditingController();

  void adicionarAtividade() {
    if (atividadeController.text.isNotEmpty) {
      setState(() {
        atividades.add(atividadeController.text);
        atividadeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold( backgroundColor: Colors.lightBlue[100],

      appBar: AppBar(

        backgroundColor: Colors.lightBlue[300],
        title: const Text('Atividades do Professor'),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              'Lista de Atividades:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: atividades.length,
                itemBuilder: (context, index) {

                  return Card( child: ListTile(  title: Text(atividades[index]), ), );
                },
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: atividadeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite uma nova atividade...',
              ),
            ),

            const SizedBox(height: 80),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton(
                  style: ElevatedButton.styleFrom( backgroundColor: Colors.lightBlue[300],),
                  onPressed: adicionarAtividade,
                  child: const Text('ADICIONAR ATIVIDADE'),
                ),
              
                ElevatedButton(
                  style: ElevatedButton.styleFrom( backgroundColor: Colors.lightBlue[300],),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('ENVIAR'),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
