import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'Authentication/login.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wikitude_flutter_app/Wikitude/customUrl.dart';

import 'DataSource/editorial.dart';
import 'Wikitude/arview.dart';
import 'Wikitude/category.dart';
import 'Wikitude/custom_expansion_tile.dart';
import 'Wikitude/sample.dart';

import 'package:augmented_reality_plugin_wikitude/wikitude_plugin.dart';
import 'package:augmented_reality_plugin_wikitude/wikitude_sdk_build_information.dart';
import 'package:augmented_reality_plugin_wikitude/wikitude_response.dart';
import 'Wikitude/armain.dart';
import 'UI/discover.dart';
import 'UI/search.dart';
import 'Authentication/accountScreen.dart';
import 'UI/webview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

//Main App Runner
class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Show circular progress indicator if loading
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          //Material App
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            //Theme Data
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Color.fromRGBO(255, 0, 117, 1),
              textTheme: const TextTheme(
                button: TextStyle(fontSize: 15.0, color: Colors.white),
                headline1:
                    TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
              ),
            ),
            home: Home(),//Home Page of the App
          );
        });
  }
}

/// This is the stateful widget that the main application instantiates.
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

/// This is the private State class that goes with Home.
class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    discoverContent(),
    searchPage(),
    MainMenu(),
    //Text("AR place holder"),
    MyWebView(
        title: "StreetView", selectedUrl: "https://www.360cities.net/image/monastiri-agiou-dionisiou-olympus-trapeza-dinning-room-greece/vr"),
    loginPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      // title: const Text('HiSG !', style: TextStyle(fontFamily: 'Jomhuria', fontSize: 80, color: pinkRedColor)),
      // backgroundColor: Colors.white,
      // ),
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.saved_search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar_rounded),
            label: 'AR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[800],
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
