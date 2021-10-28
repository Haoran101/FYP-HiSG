import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wikitude_flutter_app/Wikitude/customUrl.dart';

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
import 'UI/signin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
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
    Text(
      'Index 3: Plan',
      style: optionStyle,
    ),
    SignInScreen(),
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
      //   title: const Text('HiSG !', style: TextStyle(fontFamily: 'Jomhuria', fontSize: 80, color: pinkRedColor)),
      //   backgroundColor: Colors.white,
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
        selectedItemColor:  pinkRedColor,
        unselectedItemColor: Colors.grey[800],
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}