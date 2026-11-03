import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const VlektraApp());
}

class VlektraApp extends StatelessWidget {
  const VlektraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vlektra Velocity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.cyanAccent,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BluetoothDevice? connectedDevice;
  bool isConnecting = false;
  int batteryLevel = 82;
  int speed = 0;
  int mode = 3;
  double trip = 11.9;
  int odo = 1077;

  void startScanAndConnect() async {
    setState(() => isConnecting = true);
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.platformName.contains('DL-D21A') || r.device.remoteId.str.contains('D2:1A')) {
          await FlutterBluePlus.stopScan();
          try {
            await r.device.connect();
            setState(() {
              connectedDevice = r.device;
              isConnecting = false;
            });
            break;
          } catch (e) {
            setState(() => isConnecting = false);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VLEKTRA VELOCITY', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    connectedDevice != null ? 'CONNECTED: DL-D21A05120867' : 'DISCONNECTED',
                    style: TextStyle(
                      color: connectedDevice != null ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isConnecting ? null : startScanAndConnect,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                    child: Text(isConnecting ? 'Scanning...' : 'CONNECT'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Digital Meter Widget
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent, width: 2),
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text('MODE', style: TextStyle(color: Colors.grey)),
                          Text('$mode', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('BATTERY', style: TextStyle(color: Colors.grey)),
                          Text('$batteryLevel%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('$speed', style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('km/h', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const Divider(color: Colors.grey, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('TRIP: ${trip}km', style: const TextStyle(color: Colors.white70)),
                      Text('ODO: ${odo}km', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
