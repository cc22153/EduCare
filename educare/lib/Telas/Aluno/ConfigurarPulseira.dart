import 'package:flutter/material.dart';

class ConfigurarPulseira extends StatefulWidget {
  const ConfigurarPulseira({super.key});

  @override
  State<ConfigurarPulseira> createState() => _ConfigurarPulseiraState();
}

class _ConfigurarPulseiraState extends State<ConfigurarPulseira> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool _conectado = false;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    // Simula conexão inicial com a pulseira
    _simularConexao();
  }

  Future<void> _simularConexao() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _conectado = true);
  }

  Future<void> _enviarConfiguracao() async {
    final ssid = ssidController.text.trim();
    final senha = senhaController.text.trim();

    if (ssid.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha SSID e senha')));
      return;
    }

    setState(() => _enviando = true);

    try {
      final payload = '$ssid;$senha';
      await Future.delayed(const Duration(seconds: 2)); // simula envio
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuração enviada com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao enviar: $e')));
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    ssidController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Pulseira',  style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue[300],
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.watch,
                    size: 80,
                    color: Colors.lightBlue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Configure sua Pulseira',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _conectado
                        ? 'Pulseira conectada com sucesso!'
                        : 'Conectando à pulseira...',
                    style: TextStyle(
                        fontSize: 16,
                        color: _conectado ? Colors.green : Colors.orange),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: ssidController,
                    decoration: InputDecoration(
                      labelText: 'SSID (Wi-Fi)',
                      prefixIcon: const Icon(Icons.wifi),
                      filled: true,
                      fillColor: Colors.blue[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha (Wi-Fi)',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.blue[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _conectado && !_enviando
                          ? _enviarConfiguracao
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[400],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _enviando
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              _conectado
                                  ? 'Enviar Configuração'
                                  : 'Conectando...',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
