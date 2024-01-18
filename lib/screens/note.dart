// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/notes.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key, this.note});

  final note;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.note != null) {
      _titleController.text = widget.note['title'];
      _noteController.text = widget.note['note'];
      _isEditing = true;
    }
    super.initState();
  }

  void _onSubmit() {
    final enteredTitle = _titleController.text;
    final enteredNote = _noteController.text;

    if (enteredNote.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note is empty')),
      );
      return;
    }

    _titleController.clear();
    _noteController.clear();
    Navigator.pop(context);

    if (_isEditing) {
      FirebaseFirestore.instance
          .collection(kUserId)
          .doc(widget.note['id'])
          .update({
        ...widget.note,
        'title': enteredTitle,
        'note': enteredNote,
      });
    } else {
      final note = NoteModel(title: enteredTitle, note: enteredNote);

      FirebaseFirestore.instance.collection(kUserId).add({
        'title': note.title,
        'note': note.note,
        'createdAt': note.createdAt,
      });
    }
  }

  void _onDelete() async {
    await FirebaseFirestore.instance
        .collection(kUserId)
        .doc(widget.note['id'])
        .delete();
    _titleController.clear();
    _noteController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary.withAlpha(120),
      appBar: AppBar(
        foregroundColor: theme.colorScheme.background.withAlpha(180),
        title: Text(_isEditing ? 'Note' : 'Add Note'),
        backgroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          IconButton(
            onPressed: _onSubmit,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                maxLines: null,
                textInputAction: TextInputAction.go,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                    color: theme.colorScheme.background, fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    color: theme.colorScheme.background.withAlpha(100),
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
              TextField(
                controller: _noteController,
                minLines: 30,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: theme.colorScheme.background),
                decoration: InputDecoration(
                  hintText: 'Note',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.background.withAlpha(100),
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
