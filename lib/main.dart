import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Initialized Successfully");
  } catch (e) {
    print("🔥 Firebase Init Error: $e");
  }

  runApp(const BookSearchApp());
}

class BookSearchApp extends StatelessWidget {
  const BookSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookSearchScreen(),
      //home: const UpdateBooksPage(),
    );
  }
}

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _copiesController = TextEditingController();

  Map<String, dynamic>? _book;
  String _docId = ""; // to store document ID for updating
  String _message = "";

  Future<void> _searchBook() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() => _message = "Please enter a book title.");
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Books')
          .where('title', isEqualTo: title)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        setState(() {
          _book = doc.data();
          _docId = doc.id;
          _copiesController.text = _book!['copies'].toString();
          _message = "";
        });
      } else {
        setState(() {
          _book = null;
          _message = "No book found with this title.";
        });
      }
    } catch (e) {
      setState(() => _message = "Error: $e");
    }
  }

  Future<void> _updateCopies() async {
    if (_docId.isEmpty) return;

    final newCopies = int.tryParse(_copiesController.text.trim());
    if (newCopies == null) {
      setState(() => _message = "Enter a valid number.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Books')
          .doc(_docId)
          .update({'copies': newCopies});

      // update displayed info
      setState(() {
        _book!['copies'] = newCopies;
        _message = "✅ Copies Updated Successfully!";
      });
    } catch (e) {
      setState(() => _message = "Error updating copies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Book Copies")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Enter Book Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _copiesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter New Copies",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _searchBook, child: const Text("Search")),
                ElevatedButton(onPressed: _updateCopies, child: const Text("Update")),
              ],
            ),

            const SizedBox(height: 20),

            if (_book != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Title: ${_book!['title']}"),
                  Text("Author: ${_book!['author']}"),
                  Text("Copies Available: ${_book!['copies']}"),
                ],
              ),

            if (_message.isNotEmpty)
              Text(_message, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}