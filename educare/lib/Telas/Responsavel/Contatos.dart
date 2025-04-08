import 'package:flutter/material.dart';


class Contatos extends StatelessWidget {
  const Contatos({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar( title: const Text('Contatos'),  backgroundColor: Colors.lightBlue[300],
      ),

      body: const Padding(padding: EdgeInsets.all(20),

        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Professor Responsável:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),

            Text(
              'Nome: João da Silva',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),

            Text(
              'Telefone: (11) 99999-9999',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue, 
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 10),

            Text(
              'Email: joao.silva@email.com',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue, 
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
