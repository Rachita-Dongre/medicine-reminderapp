import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medicinereminder/Constants/routes.dart';
import 'package:medicinereminder/Screens/AppScreens/add_medicine_screen.dart';
import 'package:medicinereminder/Screens/AppScreens/medicine_home_screen.dart';
import 'package:medicinereminder/Screens/Authentication/login_screen.dart';
import 'package:medicinereminder/Screens/Authentication/registration_screen.dart';
import 'package:medicinereminder/Screens/Authentication/verify_email_screen.dart';
import 'package:medicinereminder/Services/Authentication/authentication_service.dart';
import 'package:medicinereminder/firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Enabling offline persistence for Firestore
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  tz.initializeTimeZones();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),
      routes: {
        loginRoute: (context) => const LoginScreen(),
        registerRoute: (context) => const RegisterScreen(),
        verifyEmailRoute: (context) => const VerifyEmailScreen(),
        medicineHomeRoute: (context) => const MedicineHomeScreen(),
        //medicineDetailRoute: (context) => MedicineDetailEditScreen(medicineDocument: ,),
        addMedicineRoute: (context) => const AddMedicine(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      //using future builder 'coz the app needs to be initialized first then only we can render widgets
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;

            if (user != null) {
              if (user.isEmailVerified) {
                return const MedicineHomeScreen();
              } else {
                return const VerifyEmailScreen();
              }
            } else {
              return const LoginScreen();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
