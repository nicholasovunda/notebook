import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNotes {
  final String documentId;
  final String ownerId;
  final String text;

  const CloudNotes({
    required this.documentId,
    required this.ownerId,
    required this.text,
  });

  CloudNotes.fromSnapShot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
