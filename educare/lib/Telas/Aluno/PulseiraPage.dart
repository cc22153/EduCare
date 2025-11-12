import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class PulseiraPage extends StatefulWidget {
  const PulseiraPage({super.key});

  @override
  State<PulseiraPage> createState() => _PulseiraPageState();
}

class _PulseiraPageState extends State<PulseiraPage> {
  final flutterBle = FlutterReactiveBle();
  final deviceName = "PulseiraTCC";

  String status = "Escaneando...";
  String bpm = "--";
  String accel = "--";

  DiscoveredDevice? device;

  final serviceUUID =
      Uuid.parse("12345678-1234-1234-1234-1234567890ab");
  final bpmUUID =
      Uuid.parse("12345678-1234-1234-1234-1234567890ac");
  final accelUUID =
      Uuid.parse("12345678-1234-1234-1234-1234567890ad");

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    scanPulseira();
  }

  void scanPulseira() {
    status = "Procurando Pulseira...";
    setState(() {});

    flutterBle
        .scanForDevices(withServices: [])
        .listen((scan) async {
      print("Scan: ${scan.name}");

      if (scan.name == deviceName) {
        device = scan;
        flutterBle.deinitialize(); // PARA O SCAN
        connectToDevice();
      }
    });
  }

  void connectToDevice() async {
    if (device == null) return;

    status = "Conectando...";
    setState(() {});

    flutterBle
        .connectToDevice(id: device!.id)
        .listen((event) {
      print(event.connectionState);

      if (event.connectionState ==
          DeviceConnectionState.connected) {
        status = "Conectado ✅";
        setState(() {});
        listenData();
      }
    });
  }

  void listenData() {
    // BPM
    flutterBle
        .subscribeToCharacteristic(QualifiedCharacteristic(
          serviceId: serviceUUID,
          characteristicId: bpmUUID,
          deviceId: device!.id,
        ))
        .listen((d) {
      bpm = d.isNotEmpty ? d[0].toString() : "--";
      print("BPM $bpm");
      setState(() {});
    });

    // Acelerômetro
    flutterBle
        .subscribeToCharacteristic(QualifiedCharacteristic(
          serviceId: serviceUUID,
          characteristicId: accelUUID,
          deviceId: device!.id,
        ))
        .listen((d) {
      accel = String.fromCharCodes(d);
      print("ACC $accel");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pulseira em tempo real")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Status: $status",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 25),
            Text("BPM: $bpm",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text("Aceleração: $accel",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
