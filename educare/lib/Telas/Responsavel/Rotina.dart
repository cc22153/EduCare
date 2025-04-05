import 'package:flutter/material.dart';
import 'InicioResponsavel.dart';

class Rotina extends StatelessWidget {
  const Rotina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
          Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const InicioResponsavel(),), // Volta para Tela Inicial
              );
            },
        ),
        title: const Text(
          'ROTINA',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Escreva a rotina de acordo com os horários do seu filho(a)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 6, // Quantidade de horários
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Horário ${index + 1}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const InicioResponsavel(),),
              );
              },
              child: const Text('CONCLUIR'),
            ),
          ],
        ),
      ),
    );
  }
}
