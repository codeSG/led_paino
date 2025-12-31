import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

import 'color_picker_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  List<BluetoothDevice> _devices = [];
  bool _isLoading = true;
  String _status = "Initializing Bluetooth...";

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  /* -------------------------------------------------------------------------- */
  /*                          BLUETOOTH INITIALIZATION                           */
  /* -------------------------------------------------------------------------- */

  Future<void> _initBluetooth() async {
    try {
      // 🔑 Android 12+ runtime permissions (MANDATORY)
      final connectStatus = await Permission.bluetoothConnect.request();
      final scanStatus = await Permission.bluetoothScan.request();

      if (!connectStatus.isGranted || !scanStatus.isGranted) {
        setState(() {
          _status = "Bluetooth permission denied";
          _isLoading = false;
        });
        return;
      }

      // Enable Bluetooth if disabled
      await _bluetooth.requestEnable();

      // Fetch bonded (paired) devices
      final bondedDevices = await _bluetooth.getBondedDevices();

      setState(() {
        _devices = bondedDevices;
        _status = bondedDevices.isEmpty
            ? "No paired devices found"
            : "Select ESP32 device";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = "Bluetooth error: $e";
        _isLoading = false;
      });
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                   UI                                       */
  /* -------------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bluetooth Device"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _status = "Refreshing...";
              });
              _initBluetooth();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(_status, style: const TextStyle(fontSize: 16)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.bluetooth,
                          color: Colors.blue,
                        ),
                        title: Text(
                          device.name ?? "Unknown device",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(device.address),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ColorPickerScreen(device: device),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
