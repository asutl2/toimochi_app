import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data'; // For web compatibility
import 'dart:io'; // For mobile compatibility
import 'package:flutter/foundation.dart'; // For kIsWeb

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'といもちアプリ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> _todoList =
      []; // Storing both fields and timestamps in a map
  final _discomfortController = TextEditingController();
  final _questionController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  Uint8List? _selectedImageBytes; // For web image handling
  File? _selectedImageFile; // For mobile image handling
  String _imageStatus = ''; // To track the status of the image

  @override
  void dispose() {
    _discomfortController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  // Method to open the file picker (works for web and mobile)
  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        setState(() {
          _selectedImageBytes = fileBytes; // Store image as bytes for web
          _imageStatus = '写真が追加されました'; // Image added status
        });
      }
    } else {
      // Mobile file picker (Android/iOS)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        File file = File(result.files.single.path!);
        setState(() {
          _selectedImageFile = file; // Store image as File for mobile
          _imageStatus = '写真が追加されました'; // Image added status
        });
      }
    }
  }

  // Method to remove the selected image
  void _removeImage() {
    setState(() {
      _selectedImageBytes = null; // Clear the web image bytes
      _selectedImageFile = null; // Clear the mobile image file
      _imageStatus = '写真が削除されました'; // Image removed status
    });
  }

  // Method to show the dialog for editing or adding ToDo items
  void _showEditDialog({Map<String, dynamic>? currentTodo, int? index}) {
    _discomfortController.text = currentTodo?['discomfort'] ??
        ''; // Set the current discomfort text for editing
    _questionController.text =
        currentTodo?['question'] ?? ''; // Set the current question for editing
    if (kIsWeb) {
      _selectedImageBytes =
          currentTodo?['imageBytes']; // Set the image bytes for web
    } else {
      _selectedImageFile =
          currentTodo?['imageFile']; // Set the image file for mobile
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'どんな違和感？' : '編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _discomfortController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'どんな違和感？'),
              ),
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'どんな問いが生まれそう？'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage, // Trigger image picker
                child: const Text('写真を追加'),
              ),
              if (_selectedImageBytes != null || _selectedImageFile != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      kIsWeb
                          ? Image.memory(
                              _selectedImageBytes!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _selectedImageFile!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _removeImage, // Remove the selected image
                        child: const Text('写真を削除'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                _imageStatus, // Display the image status (added or deleted)
                style: TextStyle(
                    color: _imageStatus.contains('追加')
                        ? Colors.green
                        : Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (index == null) {
                    // Add new item with creation timestamp and image
                    _todoList.add({
                      'discomfort': _discomfortController.text,
                      'question': _questionController.text,
                      'createdAt': DateTime.now(),
                      'lastEditedAt': null,
                      'imageBytes':
                          _selectedImageBytes, // Store image bytes for web
                      'imageFile':
                          _selectedImageFile, // Store image file for mobile
                    });
                  } else {
                    // Update existing item with edit timestamp and image
                    _todoList[index]['discomfort'] = _discomfortController.text;
                    _todoList[index]['question'] = _questionController.text;
                    _todoList[index]['lastEditedAt'] = DateTime.now();
                    _todoList[index]['imageBytes'] =
                        _selectedImageBytes; // Update image bytes for web
                    _todoList[index]['imageFile'] =
                        _selectedImageFile; // Update image file for mobile
                  }
                });
                _discomfortController.clear();
                _questionController.clear();
                _selectedImageBytes = null;
                _selectedImageFile = null;
                _imageStatus = ''; // Clear image status after saving
                Navigator.pop(context);
              },
              child: Text(index == null ? '追加' : '保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Center(
              child: ElevatedButton(
                child: const Text('みんなの問い'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NextPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                final todo = _todoList[index];
                final createdAt = _dateFormat.format(todo['createdAt']);
                final lastEditedAt = todo['lastEditedAt'] != null
                    ? _dateFormat.format(todo['lastEditedAt'])
                    : null;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      // When the item is tapped, show the edit dialog with current data
                      _showEditDialog(currentTodo: todo, index: index);
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.pink[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the image next to the text, if available
                            if (todo['imageBytes'] != null ||
                                todo['imageFile'] != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: kIsWeb
                                    ? Image.memory(
                                        todo['imageBytes'],
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        todo['imageFile'],
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    todo['discomfort'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    todo['question'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '追加日時: $createdAt',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  if (lastEditedAt != null)
                                    Text(
                                      '最終編集日時: $lastEditedAt',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditDialog(); // Open the dialog to add a new ToDo item
        },
        tooltip: 'Add ToDo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('みんなの問い'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
