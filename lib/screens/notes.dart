import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:notes/screens/note.dart';
import 'package:notes/widgets/note.dart';

final kUserId = FirebaseAuth.instance.currentUser!.uid;

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary.withAlpha(120),
      appBar: AppBar(
        foregroundColor: theme.colorScheme.background.withAlpha(180),
        title: const Text('Notes'),
        backgroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
                _isGridView ? Icons.view_agenda_outlined : Icons.grid_view),
          ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(kUserId)
                .orderBy('createdAt')
                .snapshots(),
            builder: (context, notesSnapshot) {
              if (notesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!notesSnapshot.hasData || notesSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No notes added',
                    style: TextStyle(
                        color: theme.colorScheme.background.withAlpha(180)),
                  ),
                );
              }

              if (notesSnapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              final loadedNotes = notesSnapshot.data!.docs
                  .map((e) => {
                        'id': e.id,
                        'title': e['title'],
                        'note': e['note'],
                        'createdAt': e['createdAt'],
                      })
                  .toList();

              return _isGridView
                  // Staggered grid view Builder not available not optimal lor large number of items
                  ? SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          children: [
                            for (final note in loadedNotes)
                              NoteWidget(
                                note: note,
                              )
                          ],
                        ),
                      ),
                    )

                  // GridView.builder(
                  //     padding: const EdgeInsets.symmetric(horizontal: 8),
                  //     shrinkWrap: true,
                  //     itemCount: loadedNotes.length,
                  //     gridDelegate:
                  //         const SliverGridDelegateWithFixedCrossAxisCount(
                  //             crossAxisCount: 2,
                  //             crossAxisSpacing: 8,
                  //             childAspectRatio: 8 / 7),
                  //     itemBuilder: (context, index) {
                  //       return NoteWidget(
                  //         note: loadedNotes[index],
                  //       );
                  //     },
                  //   )

                  : ListView.builder(
                      padding:
                          const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                      itemCount: loadedNotes.length,
                      itemBuilder: (context, index) {
                        return NoteWidget(
                          note: loadedNotes[index],
                        );
                      },
                    );
            },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Card(
              color: theme.colorScheme.primary,
              margin: const EdgeInsets.all(16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(30, 25),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NoteScreen(),
                    ),
                  );
                },
                color: theme.colorScheme.inversePrimary,
                icon: const Icon(Icons.add),
                iconSize: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
