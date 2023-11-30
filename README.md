# Medicine Reminder

This is a simple flutter app which reminds user's to take their medicines on time.

# Here's how the app works :

The user, after logging in, can add 'medicines', the details include : medicine name, dosage amount (1 tablet, 1 spoon etc.), frequency (no of doses in a day, between 1 - 10), time for each dose, instructions (before meals, after meals etc.) and additional information (store in cool and dry place etc.).
The moment user taps the 'add' button, the medicine is added to the database and a notification is scheduled for the scheduled time. For example, if a user has two medicines, medicine1 and medicine2 and they've to take 1 dose of medicine 1 at 10:00am and two doses of medicine2 at 12:00pm and 5:00pm, then the notification will be scheduled and the user will get 3 notifications at 10:00am , 12:00pm and 5:00pm.

The added medicines will be displayed in the home screen of the app. By tapping the medicine, the user will go to a different screen where they can see all the details of the medicine, edit them or delete the medicine. On deleting the medicine all scheduled notifications for that medicine gets cancelled.

The app works offline too. It handles all possible exceptions and displayes relevant messages to the user for better user experience.

# Tech Stack : 
Flutter
Firebase
Cloud Firestore (cloud database)
SQLite (local storage)

# Important Packages :
flutter_local_notifications : for notifications
timezone : to support flutter_local_notifications
sqflite : for SQLite
