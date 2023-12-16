import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ConfirmationScreen extends StatelessWidget {

  final String name;
  final String phoneNumber;
  final DateTime selectedDate;
  final List<String> selectedTimeSlots;

  const ConfirmationScreen({super.key,
    required this.name,
    required this.phoneNumber,
    required this.selectedDate,
    required this.selectedTimeSlots,});

  String formattedDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.8)),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.symmetric(vertical: 35)),
              Center(
                child: Image.asset("images/kit5.png",
                  width: 80,
                  height: 80,
                ),
              ),
              Text("Scissor's",
                style: GoogleFonts.openSans(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50),

              Container(
                width: 350,
                height:290,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                    bottom: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white54.withOpacity(0.5),
                      spreadRadius: 8,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 2)),
                        Image.asset('images/tick.png',
                          width: 50,
                          height: 50,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Booking is Confirmed ",
                                style: GoogleFonts.openSans(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                            SizedBox(height: 5),
                            Text("Name : $name",
                              style: GoogleFonts.openSans(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Mobile Number : $phoneNumber",
                              style: GoogleFonts.openSans(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.black54,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Column(
                          children: [
                            Text("Scissor's",
                              style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
                            ),
                            Icon(
                              Icons.calendar_month_sharp,
                              size: 30,
                              color: Colors.blueGrey,
                            ),
                            Text('Selected Time Slots: ${selectedTimeSlots.join(",")}',
                              style: GoogleFonts.openSans(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Selected Date: ${formattedDate(selectedDate)}',
                              style: GoogleFonts.openSans(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5,),
                          ]
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    // ... Existing code ...

    // Add a button to trigger saving data to Firestore
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        saveDataToFirestore();
      },
      child: Icon(Icons.save),
    ),
  );
}

Future<void> saveDataToFirestore() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Access Firestore instance
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Access the current user
    User? user = FirebaseAuth.instance.currentUser;
    String? userID = user?.uid; // Get the user ID

    // Collection reference (Change 'appointments' to your desired collection name)
    CollectionReference appointments = firestore.collection('appointments');

    // Add data to Firestore one by one
    var name;
    await appointments.add({
      'userID': userID,
      'name': name,
    });

    var phoneNumber;
    await appointments.add({
      'userID': userID,
      'phoneNumber': phoneNumber,
    });

    var selectedDate;
    await appointments.add({
      'userID': userID,
      'selectedDate': selectedDate,
    });

    // Assuming selectedTimeSlots is a List<String>
    var selectedTimeSlots;
    for (String timeSlot in selectedTimeSlots) {
      await appointments.add({
        'userID': userID,
        'selectedTimeSlot': timeSlot,
      });
    }

    // Data added successfully
    print('Data added to Firestore');
  } catch (e) {
    // Error occurred while adding data
    print('Error adding data to Firestore: $e');
  }
}
void sendConfirmationSMS() async {
  // Twilio credentials
  const accountSid = 'YOUR_TWILIO_ACCOUNT_SID';
  const authToken = 'YOUR_TWILIO_AUTH_TOKEN';
  const twilioNumber = 'YOUR_TWILIO_PHONE_NUMBER';

  // Destination number to send the SMS
  const toNumber = 'RECIPIENT_PHONE_NUMBER';

  // Twilio API endpoint
  final Uri uri = Uri.parse(
      'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

  // Message body
  const body = {'Body': 'Your confirmation message', 'To': toNumber, 'From': twilioNumber};

  // Send the POST request to Twilio
  var http;
  final response = await http.post(
    uri,
    body: body,
    headers: {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
    },
  );

  // Check the response
  if (response.statusCode == 201) {
    print('SMS sent successfully');
  } else {
    print('Failed to send SMS: ${response.body}');
  }}