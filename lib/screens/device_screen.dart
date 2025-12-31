import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
class CommandScreen extends StatefulWidget {
  final BluetoothDevice device;

  CommandScreen({required this.device});

  @override
  _CommandScreenState createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  BluetoothConnection? connection;
  TextEditingController commandController = TextEditingController();
  String receivedData = '';

  @override
  void initState() {
    super.initState();
    connectToDevice(widget.device);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await BluetoothConnection.toAddress(device.address).then((_connection) {
      setState(() {
        connection = _connection;
      });
      connection!.input!.listen((data) {
        setState(() {
          receivedData += String.fromCharCodes(data);
        });
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });
  }

  void sendCommand(String command) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(command.codeUnits));
      print("Sent: $command");
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Command Terminal'),
      ),
      body: Column(
        children: [
          Text('Connected to ${widget.device.name}'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: commandController,
              decoration: InputDecoration(
                labelText: 'Enter command',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              sendCommand(commandController.text);
            },
            child: Text('Send Command'),
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
