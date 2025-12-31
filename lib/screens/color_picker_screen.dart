import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:typed_data';
class ColorPickerScreen extends StatefulWidget {
  final BluetoothDevice device;
  final Function(BluetoothDevice)? onConnected;
  final Function()? onDisconnected;

  ColorPickerScreen({
    required this.device,
    this.onConnected,
    this.onDisconnected,
  });

  @override
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  BluetoothConnection? connection;
  Color selectedColor = Colors.red;
  String receivedData = '';
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    connectToDevice(widget.device);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        this.connection = connection;
        isConnected = true;
      });
      widget.onConnected?.call(device);
      
      connection.input!.listen(
        (data) {
          setState(() {
            receivedData += String.fromCharCodes(data);
          });
        },
        onDone: () {
          setState(() {
            isConnected = false;
          });
          widget.onDisconnected?.call();
        },
      );
    } catch (error) {
      setState(() {
        isConnected = false;
      });
      print('Cannot connect, exception occurred: $error');
    }
  }

  void sendColor(Color color) {
    if (connection != null && connection!.isConnected) {
      String command = "COLOR: ${color.red}, ${color.green}, ${color.blue}";
      connection!.output.add(Uint8List.fromList(command.codeUnits));
      print("Sent: $command");
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    widget.onDisconnected?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Color Picker - ${widget.device.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: isConnected ? Colors.green : Colors.red,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: HueRingPicker(
              //hueRingStrokeWidth: 50,
              pickerColor: selectedColor,
              enableAlpha: true,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
                sendColor(color);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selected Color: R=${selectedColor.red}, G=${selectedColor.green}, B=${selectedColor.blue}',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Received Data:\n$receivedData',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
