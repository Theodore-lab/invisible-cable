import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const InvisibleCableApp());
}

class InvisibleCableApp extends StatelessWidget {
  const InvisibleCableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Invisible Cable',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MeshHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MeshHomePage extends StatefulWidget {
  const MeshHomePage({super.key});

  @override
  State<MeshHomePage> createState() => _MeshHomePageState();
}

class _MeshHomePageState extends State<MeshHomePage> {
  final FlutterP2pConnection _flutterP2pConnection = FlutterP2pConnection();
  List<DiscoveredDevice> devices = [];
  bool isDiscovering = false;
  String status = "Ready - Tap Start Discovery";

  @override
  void initState() {
    super.initState();
    _flutterP2pConnection.initialize();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.nearbyWifiDevices,
      Permission.storage,
    ].request();
  }

  Future<void> startDiscovery() async {
    setState(() {
      isDiscovering = true;
      status = "Discovering nearby devices...";
    });

    bool success = await _flutterP2pConnection.discover();
    if (success) {
      _flutterP2pConnection.streamDiscoveredDevices().listen((List<DiscoveredDevice> foundDevices) {
        setState(() {
          devices = foundDevices;
          status = "Found ${devices.length} device(s)";
        });
      });
    } else {
      setState(() => status = "Discovery failed. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("The Invisible Cable"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status, style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await requestPermissions();
                await startDiscovery();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("🔍 Start Discovery", style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 30),
            const Text("Nearby Devices:", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),

            Expanded(
              child: devices.isEmpty
                  ? const Center(
                      child: Text(
                        "No devices found yet.\n\n"
                        "Make sure:\n"
                        "• Wi-Fi is turned ON on both phones\n"
                        "• Another phone is also running the app and discovering",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60),
                      ),
                    )
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return Card(
                          color: Colors.blueGrey[800],
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(device.deviceName ?? "Unknown Device",
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text("Address: ${device.deviceAddress}",
                                style: const TextStyle(color: Colors.white70)),
                            trailing: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Connecting to ${device.deviceName ?? 'device'}... (coming soon)")),
                                );
                              },
                              child: const Text("Connect"),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
