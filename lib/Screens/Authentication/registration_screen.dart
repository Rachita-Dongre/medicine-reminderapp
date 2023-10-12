import 'package:flutter/material.dart';
import 'package:medicinereminder/Constants/routes.dart';
import 'package:medicinereminder/Services/Authentication/authentication_exceptions.dart';
import 'package:medicinereminder/Services/Authentication/authentication_service.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/error_dialogue.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                  hintText:
                      'Enter password (Password should be atleast 6 characters)',
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
                    await AuthService.firebase().createUser(
                      email: email,
                      password: password,
                    );
                    await AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  } on WeakPasswordAuthException {
                    await showErrorDialog(
                      context,
                      'Weak Password!',
                    );
                  } on EmailAlreadyInUseAuthException {
                    await showErrorDialog(
                      context,
                      'Email already in use!',
                    );
                  } on InvalidEmailAuthException {
                    await showErrorDialog(
                      context,
                      'Invalid email!',
                    );
                  } on GenericAuthException {
                    await showErrorDialog(
                      context,
                      'Error : Failed to register!',
                    );
                  }
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login/',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Already registered? Login here!',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
