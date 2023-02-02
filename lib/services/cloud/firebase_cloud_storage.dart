import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/services/cloud/cloud_extensions.dart';
import 'package:todo_app/services/cloud/cloud_note.dart';
import 'package:todo_app/services/cloud/cloud_storage_conStants.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');
  void createNewNotes({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  Future<void> deleteNotes({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNotes({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNotes>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) =>
          event.docs.map((doc) => CloudNotes.fromSnapShot(doc)).where(
                (note) => note.ownerId == ownerUserId,
              ));
  Future<Iterable<CloudNotes>> getNote({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudNotes(
                  documentId: doc.id,
                  ownerId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              }));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
