import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and time

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

  @override
  void dispose() {
    _discomfortController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  // Method to show the dialog for editing or adding ToDo items
  void _showEditDialog({Map<String, dynamic>? currentTodo, int? index}) {
    _discomfortController.text = currentTodo?['discomfort'] ??
        ''; // Set the current discomfort text for editing
    _questionController.text =
        currentTodo?['question'] ?? ''; // Set the current question for editing

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
                    // Add new item with creation timestamp
                    _todoList.add({
                      'discomfort': _discomfortController.text,
                      'question': _questionController.text,
                      'createdAt': DateTime.now(), // Add creation timestamp
                      'lastEditedAt': null, // Initially, no edits
                    });
                  } else {
                    // Update existing item with edit timestamp
                    _todoList[index]['discomfort'] = _discomfortController.text;
                    _todoList[index]['question'] = _questionController.text;
                    _todoList[index]['lastEditedAt'] =
                        DateTime.now(); // Update the edit timestamp
                  }
                });
                _discomfortController.clear();
                _questionController.clear();
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
                  padding:
                      const EdgeInsets.all(8.0), // Add padding around each card
                  child: GestureDetector(
                    onTap: () {
                      // When the item is tapped, show the edit dialog with current data
                      _showEditDialog(currentTodo: todo, index: index);
                    },
                    child: Card(
                      elevation: 5, // Add a shadow for depth
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                      ),
                      color:
                          Colors.pink[50], // Soft background color for the card
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16.0), // Increase padding inside the card
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo['discomfort'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                            if (lastEditedAt != null)
                              Text(
                                '最終編集日時: $lastEditedAt',
                                style: const TextStyle(
                                    fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            const SizedBox(height: 10),
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
          // Open the dialog to add a new ToDo item
          _showEditDialog();
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
