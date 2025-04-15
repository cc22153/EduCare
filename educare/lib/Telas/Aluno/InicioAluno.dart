import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'DiarioAluno.dart';
import 'EstadoEmocional.dart';
import 'AtividadesAluno.dart';
import 'ContatosAluno.dart';

class InicioAluno extends StatefulWidget {
  const InicioAluno({super.key});

  @override
  State<InicioAluno> createState() => InicioAlunoState();
}

class InicioAlunoState extends State<InicioAluno> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mapa de eventos por dia
  final Map<DateTime, List<Event>> _eventos = {
    DateTime.utc(2025, 4, 11): [
      Event("Reunião com pais", TimeOfDay(hour: 9, minute: 0)),
      Event("Apresentação", TimeOfDay(hour: 14, minute: 0)),
    ],
    DateTime.utc(2025, 4, 12): [
      Event("Oficina de desenho", TimeOfDay(hour: 10, minute: 0)),
    ],
  };

  List<Event> _getEventosDoDia(DateTime dia) {
    return _eventos[dia] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventosSelecionados = _getEventosDoDia(_selectedDay ?? _focusedDay);
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 45) / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        backgroundColor: Colors.lightBlue[300],
        iconTheme: IconThemeData(),
      ),
      backgroundColor: Colors.lightBlue[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Seja Bem-Vindo, \n{Nome Aluno}!",
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF009ADA),
                    ),
                  ),
                  Icon(
                    Icons.account_circle,
                    size: 75,
                    color: Color(0xFF009ADA),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color(0xFF009ADA),
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: const Column(
                children: [
                  Text(
                    "Recados Importantes!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Divider(
                    height: 10,
                    color: Colors.white,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Text(
                    "Do dia 18/04 ao 23/04 não teremos aulas!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  height: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.EEEE('pt_BR')
                                  .format(DateTime.now())
                                  .toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 221, 63, 52),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateTime.now().day.toString(),
                              style: const TextStyle(
                                  fontSize: 32, color: Colors.white),
                            )
                          ],
                        ),
                        const Text(
                          "Sem eventos hoje",
                          style: TextStyle(fontSize: 16, color: Colors.white54),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  height: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EstadoEmocional()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/emoji.png',
                          width: 120,
                          height: 120,
                        ),
                        const Text(
                          "Como você esta se sentindo ?",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  height: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EstadoEmocional()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/diario.png',
                          width: 120,
                          height: 120,
                        ),
                        const Text(
                          "DIÁRIO",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  height: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AtividadesAluno()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/atividades.webp',
                          width: 150,
                          height: 150,
                        ),
                        const Text(
                          "ATIVIDADES",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget botaoPadrao(String texto, VoidCallback onPressed, IconData icone) {
    return SizedBox(
      width: 200,
      height: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 150,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe de evento com horário
class Event {
  final String title;
  final TimeOfDay time;

  Event(this.title, this.time);

  @override
  String toString() => '$title ($time})';
}
