import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            controller: _email,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            controller: _password,
            decoration: const InputDecoration(
              hintText: 'Enter password',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final userCredentials = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password);

                print(userCredentials);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'User-not-found') {
                  print('User not found');
                } else if (e.code == 'wrong password') {
                  print('wrong password');
                } else {
                  print(e.code);
                }
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/register', (route) => false);
            },
            child: const Text('Not registered yet? register here'),
          ),
        ],
      ),
    );
  }
}
