import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:medicinereminder/Constants/routes.dart';
import 'package:medicinereminder/Screens/AppScreens/medicine_detail_edit_screen.dart';
import 'package:medicinereminder/Services/Authentication/authentication_service.dart';
import 'package:medicinereminder/Services/Cloud/crud_cloud_firestore.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/delete_confirmation_dialogue.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/logOut_dialogue.dart';
import 'package:medicinereminder/enums/menu_action.dart';

class MedicineHomeScreen extends StatefulWidget {
  const MedicineHomeScreen({super.key});

  @override
  State<MedicineHomeScreen> createState() => _MedicineHomeScreenState();
}

class _MedicineHomeScreenState extends State<MedicineHomeScreen> {
  final Connectivity connectivity = Connectivity();
  StreamSubscription? connectivitySubscription;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        print("You're offline!");
      } else {
        print("You're online!");
      }
    });

    connectivitySubscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      print("Connectivity Result: $result");
      if (result == ConnectivityResult.none) {
        // The user is offline and the app is in the foreground. Display an alert dialog box.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("You're offline!"),
              content: const Text(
                  "Don't worry! You can still use the app normally. Data will be synced when you get back online."),
              actions: [
                TextButton(
                  onPressed: () {
                    // Close the alert dialog box.
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });

    // Schedule a check of the network connectivity status every 1 second.
    // timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   connectivity.checkConnectivity().then((ConnectivityResult result) {
    //     if (result == ConnectivityResult.none &&
    //         WidgetsBinding.instance.lifecycleState ==
    //             AppLifecycleState.resumed) {
    //       // The user is offline and the app is in the foreground. Display an alert dialog box.
    //       showDialog(
    //         context: context,
    //         builder: (BuildContext context) {
    //           return AlertDialog(
    //             title: const Text("You're offline!"),
    //             content: const Text(
    //                 "Don't worry! You can still use the app normally. Data will be synced when you get back online."),
    //             actions: [
    //               TextButton(
    //                 onPressed: () {
    //                   // Close the alert dialog box.
    //                   Navigator.pop(context);
    //                 },
    //                 child: const Text('OK'),
    //               ),
    //             ],
    //           );
    //         },
    //       );
    //     }
    //   });
    // });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    //timer?.cancel();
    super.dispose();
  }

  late final String? userId = Database.userID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Take your medicines!',
        ),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialogue(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(
                    'Log out',
                  ),
                )
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Database.readMedicine(userID: userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nothing to show. Add some medicines!',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot medicine = snapshot.data!.docs[index];

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  color: Colors.deepPurple[300],
                  elevation: 5.0, // provides a shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50], // background color
                        borderRadius:
                            BorderRadius.circular(15.0), // same as Card shape
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        title: Text(
                          medicine['Medicine Name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        subtitle: Text(
                          medicine['Dosage Amount'],
                          style: TextStyle(
                            color: Colors.deepPurple[300],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          color: Colors.deepPurple,
                          onPressed: () {
                            String docID = medicine.id;
                            deleteConfirmationDialogue(context, docID, userId);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineDetailEditScreen(
                                  medicineDocument: medicine),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        splashColor: Colors.purple,
        onPressed: () {
          //go to addmedicine page
          Navigator.of(context).pushNamed(addMedicineRoute);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
