import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  NoteModel({this.title, required this.note}) : createdAt = Timestamp.now();

  final String? title;
  final String note;
  final Timestamp createdAt;
}
