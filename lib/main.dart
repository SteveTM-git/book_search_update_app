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
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _book;
  String _message = "";

  Future<void> _searchBook() async {
  final title = _controller.text.trim();

  if (title.isEmpty) {
    setState(() => _message = "Please enter a book title.");
    return;
  }

  try {
    print("Searching for title: '$title'");

    final snapshot = await FirebaseFirestore.instance
        .collection('Books') // ✅ correct collection name
        .where('title', isEqualTo: title)
        .get();

    print("Documents found: ${snapshot.docs.length}");

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _book = snapshot.docs.first.data();
        _message = "";
      });
    } else {
      setState(() {
        _book = null;
        _message = "No book found with title '$title'.";
      });
    }
  } catch (e) {
    setState(() {
      _message = "Error: $e";
      _book = null;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library Book Search")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter book title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _searchBook, child: const Text("Search")),
            const SizedBox(height: 30),
            if (_book != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Title: ${_book!['title']}"),
                  Text("Author: ${_book!['author']}"),
                  Text("Copies Available: ${_book!['copies']}"),
                  if (_book!['copies'] == 0)
                    const Text(
                      "Not Available – All Copies Issued",
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              )
            else if (_message.isNotEmpty)
              Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
