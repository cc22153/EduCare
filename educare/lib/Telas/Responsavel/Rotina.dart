import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'InicioResponsavel.dart';

class Rotina extends StatefulWidget {
  const Rotina({super.key});

  @override
  State<Rotina> createState() => RotinaState();
}

class RotinaState extends State<Rotina> {

   List<Map<String, TextEditingController>> campos = [];

   @override
  void initState() {
    super.initState();
    adicionarCampo(); // cria o primeiro campo automático
  }

  void adicionarCampo() {
    setState(() {
      campos.add({
        'horario': TextEditingController(),
        'tarefa': TextEditingController(),
      });
    });
  }

  void removerCampo(int index) {
    setState(() {
      campos.removeAt(index);
    });
  }

  void concluirRotina() {
    // depois precisa implementar para os dados serem salvos
    Navigator.pop(context); // Volta pra tela inicial
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar( title: const Text('Rotina'), backgroundColor: Colors.blue,),

      body: Padding(

        padding: const EdgeInsets.all(16.0),

        child: Column(

          children: [

            Expanded(

              child: ListView.builder(

                itemCount: campos.length,
                itemBuilder: (context, index) {
                  return Row(

                    children: [

                      Expanded(
                        
                        child: TextField(

                          controller: campos[index]['horario'],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Horário',
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      Expanded(

                        child: TextField(
                          controller: campos[index]['tarefa'],
                          decoration: const InputDecoration(
                            labelText: 'Tarefa',
                          ),
                        ),
                      ),

                      IconButton( icon: const Icon(Icons.delete), onPressed: () => removerCampo(index),),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: adicionarCampo,
              child: const Text('Adicionar +'),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: concluirRotina,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('CONCLUIR'),
            ),

          ],
        ),
      ),
    );
  }
}