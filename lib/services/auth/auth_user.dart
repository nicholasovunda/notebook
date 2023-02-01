import 'package:firebase_auth/firebase_auth.dart' show User;

class AuthUser {
  final String id;
  final bool isEmailVerified;
  final String email;
  const AuthUser(
      {required this.id, required this.email, required this.isEmailVerified});
  factory AuthUser.fromFirebase(User user) => AuthUser(
      isEmailVerified: user.emailVerified, email: user.email!, id: user.uid);
}
