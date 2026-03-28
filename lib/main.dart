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
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
  final FlutterP2pConnection _p2p = FlutterP2pConnection();
  List<DiscoveredDevice> devices = [];
  String status = "Ready to connect with the church family";

  @override
  void initState() {
    super.initState();
    _p2p.initialize();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.nearbyWifiDevices,
      Permission.storage,
    ].request();
  }

  Future<void> startDiscovery() async {
    setState(() => status = "Looking for nearby phones...");
    bool success = await _p2p.discover();
    if (success) {
      _p2p.streamDiscoveredDevices().listen((found) {
        setState(() {
          devices = found;
          status = found.isEmpty 
              ? "No devices found yet" 
              : "Found ${found.length} device(s) nearby";
        });
      });
    } else {
      setState(() => status = "Discovery failed. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("The Invisible Cable"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.connect_without_contact, size: 60, color: Colors.indigo),
                    const SizedBox(height: 16),
                    Text(
                      status,
                      style: const TextStyle(fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text("Choose an action", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () async {
                await requestPermissions();
                await startDiscovery();
              },
              icon: const Icon(Icons.search),
              label: const Text("🔍 Start Discovery", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.indigo,
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Host / Relay mode coming soon")),
                );
              },
              icon: const Icon(Icons.wifi_tethering),
              label: const Text("📡 Host Network (Become Relay)", style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),

            const SizedBox(height: 32),

            const Text("Nearby Devices", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),

            const SizedBox(height: 8),

            Expanded(
              child: devices.isEmpty
                  ? Center(
                      child: Text(
                        "No devices found yet.\n\nAsk others at the conference to open the app\nand tap 'Start Discovery'",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], height: 1.5),
                      ),
                    )
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.phone_android, color: Colors.indigo),
                            title: Text(device.deviceName ?? "Unknown Phone"),
                            subtitle: Text(device.deviceAddress ?? ""),
                            trailing: const Chip(label: Text("Connect")),
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
