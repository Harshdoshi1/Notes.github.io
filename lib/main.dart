import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
  
void main() {
  runApp(MyApp());
}

class NotesProvider with ChangeNotifier {
  List<String> _notes = [];

  List<String> get notes => _notes;

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    _notes = prefs.getStringList('notes') ?? [];
    notifyListeners();
  }

  Future<void> addNote(String note) async {
    _notes.add(note);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', _notes);
    notifyListeners();
  }

  Future<void> deleteNoteAt(int index) async {
    _notes.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', _notes);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotesProvider()..loadNotes(),
      child: MaterialApp(
        home: NotesPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class NotesPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Notes App')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter note',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      notesProvider.addNote(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notesProvider.notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notesProvider.notes[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => notesProvider.deleteNoteAt(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
