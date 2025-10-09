import 'package:flutter/material.dart';
import 'InicioResponsavel.dart';

class PosCadastro extends StatelessWidget {
  const PosCadastro({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(

        title: const Text('Pós Cadastro'),
        backgroundColor: Colors.blueAccent,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Sua conta foi criada! Preencha os campos para criar a conta do seu filho(a)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const TextField(decoration: InputDecoration(labelText: 'Nome do filho(a)'), ),

            const TextField(decoration: InputDecoration(labelText: 'Usuário'), ),

            const TextField(decoration: InputDecoration(labelText: 'Senha'), obscureText: true, ),

            const TextField( decoration: InputDecoration(labelText: 'Idade'), keyboardType: TextInputType.number,),

            const TextField(decoration: InputDecoration(labelText: 'Turma'), ),

            const SizedBox(height: 50),

            ElevatedButton(   onPressed: () {  Navigator.pushReplacement(  context,
            
             MaterialPageRoute(builder: (context) => const InicioResponsavel()));},
             
              style: ElevatedButton.styleFrom(

                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),),
                child: const Text(  'CONFIRMAR CONTA',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
