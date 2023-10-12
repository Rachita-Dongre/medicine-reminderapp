import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/confirmation_dialogue.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/error_dialogue.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showConfirmationDialog(context, 'Email sent with Password reset link');
    } catch (error) {
      showErrorDialog(context,
          'Could not send email. Try again!'); // Handle and show error messages accordingly
    }
  }

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
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
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  await sendPasswordResetEmail(emailController.text);
                } else {
                  showErrorDialog(context, 'Please enter your email!');
                }
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}
