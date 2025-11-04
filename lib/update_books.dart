import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateBooksPage extends StatefulWidget {
  const UpdateBooksPage({super.key});

  @override
  State<UpdateBooksPage> createState() => _UpdateBooksPageState();
}

class _UpdateBooksPageState extends State<UpdateBooksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _copiesController = TextEditingController();

  DocumentSnapshot? searchedBook;

  // Search Book by Title
  void searchBook() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final query = await _firestore
        .collection('books')
        .where('title', isEqualTo: title)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        searchedBook = query.docs.first;
        _copiesController.text = searchedBook!['copies'].toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book not found')),
      );
      setState(() => searchedBook = null);
    }
  }

  // Update Copies
  void updateCopies() async {
    if (searchedBook == null) return;

    final newCopies = int.tryParse(_copiesController.text.trim());
    if (newCopies == null) return;

    await _firestore
        .collection('books')
        .doc(searchedBook!.id)
        .update({'copies': newCopies});

    searchBook(); // Refresh displayed data

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copies updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Book Copies')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Enter Book Title'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: searchBook, child: const Text('Search')),
            const SizedBox(height: 20),

            if (searchedBook != null) ...[
              Text('Title: ${searchedBook!['title']}',
                  style: const TextStyle(fontSize: 18)),
              Text('Author: ${searchedBook!['author']}',
                  style: const TextStyle(fontSize: 18)),
              Text('Available Copies: ${searchedBook!['copies']}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: _copiesController,
                decoration: const InputDecoration(labelText: 'Update Copies'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: updateCopies, child: const Text('Update')),
            ]
          ],
        ),
      ),
    );
  }
}
