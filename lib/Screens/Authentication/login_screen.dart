import 'package:flutter/material.dart';
import 'package:medicinereminder/Constants/routes.dart';
import 'package:medicinereminder/Screens/Authentication/reset_password_screen.dart';
import 'package:medicinereminder/Services/Authentication/authentication_exceptions.dart';
import 'package:medicinereminder/Services/Authentication/authentication_service.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/error_dialogue.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //late final String? userID = Database.userID;
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _password = TextEditingController();

  @override
  void initState() {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _email,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // you can adjust this value as per your requirement
                    borderSide: BorderSide.none, // hides the default border
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 20.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // you can adjust this value as per your requirement
                    borderSide: BorderSide.none, // hides the default border
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 20.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    //method in firebase_auth dependency to sign in a user with email and password
                    await AuthService.firebase().logIn(
                      email: email,
                      password: password,
                    );
                    final user = AuthService.firebase().currentUser;

                    if (user?.isEmailVerified ?? false) {
                      //email is verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        medicineHomeRoute,
                        (route) => false,
                      );
                    } else {
                      //email is not verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute,
                        (route) => false,
                      );
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(
                      context,
                      'User not found!',
                    );
                  } on WrongPasswordAuthException {
                    await showErrorDialog(
                      context,
                      'Wrong Password!',
                    );
                  } on GenericAuthException {
                    await showErrorDialog(
                      context,
                      'Authentication Error!',
                    );
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text('Not registered yet? Register here!'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResetPasswordScreen()),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
