// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart'
//     show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
// import 'package:path/path.dart' show join;
// import 'package:todo_app/extension/list/filter.dart';

// import 'crud_exception.dart';

// class NotesService {
//   Database? _db;
//   DataBaseUser? _user;

//   List<DataBaseNotes> _notes = [];
//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController =
//         StreamController<List<DataBaseNotes>>.broadcast(onListen: () {
//       _notesStreamController.sink.add(_notes);
//     });
//   }
//   factory NotesService() => _shared;

//   late final StreamController<List<DataBaseNotes>> _notesStreamController;
//   Stream<List<DataBaseNotes>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       });
//   Future<DataBaseUser> getOrCreateUser(
//       {required String email, bool setAsCurrentUser = true}) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUserException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (_) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<DataBaseNotes> updateNote({
//     required DataBaseNotes note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDataBaseOrThrow();

//     //make sure notes exist
//     await getNote(id: note.id);

//     // update DB
//     final updatesCount = await db.update(
//         noteTable,
//         {
//           textColumn: text,
//           isSyncWithCloudColumn: 0,
//         },
//         where: 'id = ?',
//         whereArgs: [note.id]);
//     if (updatesCount == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNotes = await getNote(id: note.id);
//       _notes.removeWhere((notes) => notes.id == updatedNotes.id);
//       _notes.add(updatedNotes);
//       _notesStreamController.add(_notes);
//       return updatedNotes;
//     }
//   }

//   Future<Iterable<DataBaseNotes>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDataBaseOrThrow();
//     final notes = await db.query(noteTable);
//     return notes.map((noteRow) => DataBaseNotes.fromRow(noteRow));
//   }

//   Future<DataBaseNotes> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDataBaseOrThrow();
//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (notes.isEmpty) {
//       throw CouldNotFindNotes();
//     } else {
//       final note = DataBaseNotes.fromRow(notes.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<void> deleteNotes({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDataBaseOrThrow();
//     final deletedCount = await db.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteAll() async {
//     await _ensureDbIsOpen();
//     final db = _getDataBaseOrThrow();
//     final numberOfDeletions = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }

//   Future<DataBaseNotes> createNotes({required DataBaseUser owner}) async {
//     final db = _getDataBaseOrThrow();

//     // match sure that owner exist in the database with the correct id
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUserException();
//     }

//     const text = '';
//     // create the note
//     final noteId = await db.insert(noteTable, {
//       userIDColumn: owner.id,
//       textColumn: text,
//       isSyncWithCloudColumn: 1,
//     });

//     final note = DataBaseNotes(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }

//   Future<DataBaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDataBaseOrThrow();
//     final results = await db.query(
//       userTable,
//       where: 'email = ? ',
//       whereArgs: [email.toLowerCase()],
//       limit: 1,
//     );
//     if (results.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       return DataBaseUser.fromRow(results.first);
//     }
//   }

//   Future<DataBaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDataBaseOrThrow();
//     final results = await db.query(
//       userTable,
//       where: 'email = ? ',
//       whereArgs: [email.toLowerCase()],
//       limit: 1,
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExistException();
//     }
//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });
//     return DataBaseUser(
//       id: userId,
//       email: email,
//     );
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDataBaseOrThrow();

//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email= ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Database _getDataBaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DataBaseNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DataBaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       //create user table
//       await db.execute(createUserTable);

//       //create notes table
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentDirectoryException();
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DataBaseNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DataBaseAlreadyOpenException {}
//   }
// }

// @immutable
// class DataBaseUser {
//   final int id;
//   final String email;

//   const DataBaseUser({
//     required this.id,
//     required this.email,
//   });

//   DataBaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, ID = $id, email = $email';

//   @override
//   bool operator ==(covariant DataBaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DataBaseNotes {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DataBaseNotes({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });
//   DataBaseNotes.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIDColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Notes, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';
//   @override
//   bool operator ==(covariant DataBaseNotes other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = 'notes.db';
// const noteTable = 'notes';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIDColumn = 'user_id';
// const textColumn = 'text';
// const isSyncWithCloudColumn = 'is_synced_With_cloud';

// // CREATE USER TABLE
// const createUserTable = ''' 
//       CREATE TABLE IF NOT EXISTS "user" (
// 	  "id"	INTEGER NOT NULL,
//   	"email"	TEXT NOT NULL UNIQUE,
//   	PRIMARY KEY("id" AUTOINCREMENT)
// );
//       ''';
// //CREATE NOTES TABLE
// const createNoteTable = ''' 
//       CREATE TABLE IF NOT EXISTS "notes" (
// 	"id"	INTEGER NOT NULL,
// 	"user_id"	INTEGER NOT NULL,
// 	"text"	TEXT,
// 	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
// 	FOREIGN KEY("user_id") REFERENCES "user"("id"),
// 	PRIMARY KEY("id" AUTOINCREMENT)
// );
//       ''';
