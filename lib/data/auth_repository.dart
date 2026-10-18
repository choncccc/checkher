import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import 'app_database.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Offline account management backed by SQLite. Passwords are stored as
/// salted PBKDF2-HMAC-SHA256 hashes, never in plain text.
class AuthRepository {
  AuthRepository(this._database);

  final AppDatabase _database;
  Database get _db => _database.db;

  static const _iterations = 10000;

  Future<AppUser> signUp({
    required String username,
    required String displayName,
    required String password,
    required String address,
    DateTime? lastPeriodStart,
  }) async {
    username = username.trim();
    validateUsername(username);
    validatePassword(password);
    if (displayName.trim().isEmpty) {
      throw AuthException('Please enter your name.');
    }
    if (address.trim().isEmpty) {
      throw AuthException('Please enter your address.');
    }

    final salt = _newSalt();
    try {
      final id = await _db.transaction((txn) async {
        final id = await txn.insert('users', {
          'username': username,
          'display_name': displayName.trim(),
          'password_hash': _hash(password, salt),
          'salt': salt,
          'address': address.trim(),
          'last_period_start': lastPeriodStart?.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });
        for (var i = 0; i < AppDatabase.defaultReminders.length; i++) {
          await txn.insert('reminders', {
            'user_id': id,
            'title': AppDatabase.defaultReminders[i],
            'sort_order': i,
          });
        }
        return id;
      });
      await _setSession(id);
      return (await _findById(id))!;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw AuthException('That username is already taken.');
      }
      rethrow;
    }
  }

  Future<AppUser> login(String username, String password) async {
    final row = await _findRowByUsername(username.trim());
    if (row == null ||
        _hash(password, row['salt'] as String) != row['password_hash']) {
      throw AuthException('Incorrect username or password.');
    }
    final id = row['id'] as int;
    await _setSession(id);
    return AppUser.fromRow(row);
  }

  Future<void> logout() => _db.delete('session');

  /// The user who was logged in last time the app ran, if any.
  Future<AppUser?> currentUser() async {
    final rows = await _db.query('session', limit: 1);
    if (rows.isEmpty) return null;
    return _findById(rows.first['user_id'] as int);
  }

  /// Offline reset: the user proves who they are with the address they
  /// registered with.
  Future<void> resetPassword({
    required String username,
    required String address,
    required String newPassword,
  }) async {
    final row = await _findRowByUsername(username.trim());
    if (row == null ||
        _normalize(address) != _normalize(row['address'] as String)) {
      throw AuthException('Username and address don\'t match our records.');
    }
    final salt = row['salt'] as String;
    validatePassword(newPassword);
    await _db.update(
      'users',
      {'password_hash': _hash(newPassword, salt)},
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<AppUser> updateCycle(
    AppUser user, {
    required DateTime lastPeriodStart,
    int? cycleLength,
    int? periodLength,
  }) async {
    await _db.update(
      'users',
      {
        'last_period_start': lastPeriodStart.toIso8601String(),
        'cycle_length': ?cycleLength,
        'period_length': ?periodLength,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return (await _findById(user.id))!;
  }

  static void validateUsername(String username) {
    if (!RegExp(r'^[A-Za-z0-9_.]{3,20}$').hasMatch(username)) {
      throw AuthException(
        'Username must be 3–20 letters, numbers, dots or underscores.',
      );
    }
  }

  static void validatePassword(String password) {
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }
  }

  Future<void> _setSession(int userId) => _db.insert('session', {
    'id': 1,
    'user_id': userId,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<Map<String, Object?>?> _findRowByUsername(String username) async {
    final rows = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<AppUser?> _findById(int id) async {
    final rows = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : AppUser.fromRow(rows.first);
  }

  static String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'[\s,.]+'), ' ');

  static String _newSalt() {
    final r = Random.secure();
    return base64Url.encode(List.generate(16, (_) => r.nextInt(256)));
  }

  /// PBKDF2-HMAC-SHA256, single 32-byte block.
  static String _hash(String secret, String salt) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    var u = hmac.convert([...utf8.encode(salt), 0, 0, 0, 1]).bytes;
    final out = List<int>.from(u);
    for (var i = 1; i < _iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < out.length; j++) {
        out[j] ^= u[j];
      }
    }
    return base64Url.encode(out);
  }
}
