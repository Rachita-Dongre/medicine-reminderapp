import 'package:flutter/material.dart';
import 'package:medicinereminder/Constants/routes.dart';
import 'package:medicinereminder/Services/Authentication/authentication_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 7,
                color: Colors.deepPurple[50],
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "We've sent you a verification email. Please open the email to verify your account.",
                        style:
                            TextStyle(color: Colors.deepPurple, fontSize: 20),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "If you haven't received verification email, please click the link below.",
                        style:
                            TextStyle(color: Colors.deepPurple, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerification();
                },
                child: const Text('Send email verification link'),
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton(
                onPressed: () async {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Restart',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
