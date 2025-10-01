import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _fileContent = "No content yet";
  final String _fileName = "my_data.txt";

  @override
  void initState() {
    super.initState();
    _readFile();
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, _fileName));
  }

  Future<void> _writeFile() async {
    final file = await _getLocalFile();
    await file.writeAsString("Hello from Flutter! ${DateTime.now().toString()}");
    _readFile(); // Refresh content after writing
  }

  Future<void> _readFile() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        setState(() {
          _fileContent = "Content: ${file.readAsStringSync()}";
        });
      } else {
        setState(() {
          _fileContent = "File does not exist.";
        });
      }
    } catch (e) {
      setState(() {
        _fileContent = "Error reading file: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('File Persistence Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_fileContent),
              ElevatedButton(
                onPressed: _writeFile,
                child: Text('Write to File'),
              ),
              ElevatedButton(
                onPressed: _readFile,
                child: Text('Read from File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}