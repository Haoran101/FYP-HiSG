// ignore_for_file: unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:wikitude_flutter_app/Plan/favorites.dart';
import 'package:wikitude_flutter_app/Plan/plan_main.dart';
import 'package:wikitude_flutter_app/UI/test.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

import 'Wikitude/armain.dart';
import 'SearchResults/search.dart';
import 'Authentication/accountScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

//Main App Runner
// ignore: must_be_immutable
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
            home: Home(), //Home Page of the App
          );
        });
  }
}

/// This is the stateful widget that the main application instantiates.
// ignore: must_be_immutable
class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

/// This is the private State class that goes with Home.
class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
  }

  List<Widget> _widgetOptions = <Widget>[
    SearchPage(),
    MainMenu(),
    //WebScraperApp(),
    ExpansionTileExample(),
    //Favorites(),
    Test()
    //AuthScreenPlaceHolder(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore_rounded),
            label: 'Discover',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.saved_search_rounded),
          //   label: 'Search',
          // ),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
