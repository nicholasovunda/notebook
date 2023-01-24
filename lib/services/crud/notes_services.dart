import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

import 'crud_exception.dart';

class NotesService {
  Database? _db;

  Future<DataBaseNotes> updateNote({
    required DataBaseNotes note,
    required String text,
  }) async {
    final db = _getDataBaseOrThrow();
    await getNote(id: note.id);
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncWithCloudColumn: 0,
    });
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DataBaseNotes>> getAllNotes() async {
    final db = _getDataBaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DataBaseNotes.fromRow(noteRow));
  }

  Future<DataBaseNotes> getNote({required int id}) async {
    final db = _getDataBaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      return DataBaseNotes.fromRow(notes.first);
    }
  }

  Future<void> deleteNotes({required int id}) async {
    final db = _getDataBaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {}
  }

  Future<int> deleteAll() async {
    final db = _getDataBaseOrThrow();
    return db.delete(noteTable);
  }

  Future<DataBaseNotes> createNotes({required DataBaseUser owner}) async {
    final db = _getDataBaseOrThrow();

    // match sure that owner exist in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const text = '';
    // create the note
    final noteId = await db.insert(noteTable, {
      userIDColumn: owner.id,
      textColumn: text,
      isSyncWithCloudColumn: 1,
    });

    final note = DataBaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<DataBaseUser> getUser({required String email}) async {
    final db = _getDataBaseOrThrow();
    final results = await db.query(
      userTable,
      where: 'email = ? ',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DataBaseUser.fromRow(results.first);
    }
  }

  Future<DataBaseUser> createUser({required String email}) async {
    final db = _getDataBaseOrThrow();
    final results = await db.query(
      userTable,
      where: 'email = ? ',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistException();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DataBaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDataBaseOrThrow();

    final deletedCount = await db.delete(
      userTable,
      where: 'email= ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDataBaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DataBaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);

      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DataBaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class DataBaseUser {
  final int id;
  final String email;

  const DataBaseUser({
    required this.id,
    required this.email,
  });

  DataBaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DataBaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DataBaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DataBaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIDColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Notes, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';
  @override
  bool operator ==(covariant DataBaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIDColumn = 'user_id';
const textColumn = 'text';
const isSyncWithCloudColumn = 'is_synced_With_cloud';

// CREATE USER TABLE
const createUserTable = ''' 
      CREATE TABLE IF NOT EXISTS "user" (
	  "id"	INTEGER NOT NULL,
  	"email"	TEXT NOT NULL UNIQUE,
  	PRIMARY KEY("id" AUTOINCREMENT)
);
      ''';
//CREATE NOTES TABLE
const createNoteTable = ''' 
      CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);
      ''';
