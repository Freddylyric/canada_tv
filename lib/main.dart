import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:canada_iptv/categories.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'adapters/channels_model.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(ChannelModelAdapter());
  await Hive.openBox<ChannelModel>('channels'); // Open the Hive channel box
  await Hive.openBox<String>('timestamps'); // Open the Hive timestamps box

  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    checkAndClearHiveData(); // Check and clear Hive data on app launch

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("You have error ${snapshot.error.toString()}");
          return Text("something went wrong");
        } else if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              fontFamily: GoogleFonts.montserrat(

                fontWeight: FontWeight.w500,
                fontSize: 14,
              ).fontFamily,
            ),
            home: CategoryScreen(),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void checkAndClearHiveData() async {
    // Open the Hive timestamps box
    Box<String> timestampsBox = await Hive.openBox<String>('timestamps');

    // Check if the last update timestamp is available
    String lastUpdateKey = 'last_update_timestamp';
    String? lastUpdate = timestampsBox.get(lastUpdateKey);

    // If the timestamp is not available or 7 days have passed, clear the data
    if (lastUpdate == null || isSevenDaysAgo(lastUpdate)) {
      // Open the Hive channel box
      Box<ChannelModel> channelsBox = Hive.box<ChannelModel>('channels');

      // Clear all data from the Hive box
      await channelsBox.clear();

      // Save the current timestamp as the last update timestamp
      timestampsBox.put(lastUpdateKey, getCurrentTimestamp());
    }
  }

  bool isSevenDaysAgo(String timestamp) {
    DateTime lastUpdate = DateTime.parse(timestamp);
    DateTime now = DateTime.now();
    Duration difference = now.difference(lastUpdate);
    return difference.inDays >= 7;
  }

  String getCurrentTimestamp() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }
}