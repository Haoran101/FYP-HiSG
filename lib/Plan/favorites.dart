import 'package:flutter/material.dart';
import 'package:hi_sg/Models/search_result_model.dart';
import 'package:hi_sg/Plan/plan_main.dart';
import 'package:hi_sg/SearchResults/search.dart';
import 'package:hi_sg/User/UserService.dart';

class Favorites extends StatefulWidget {
  const Favorites({ Key? key }) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {

  final UserService _user = UserService();

  @override
  void initState() {
    _user.getFavoriteItems();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Favourites"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: 
        _user.favoriteItems.length == 0?
        NoPlanDisplay(isFavourite: true):
        Container(
          child: Column(
            children: List.generate(_user.favoriteItems.length, (index) {
            SearchResult item = _user.favoriteItems[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchResultCard(item: item),
            );
            }),
          ),
        ),
      ),
    );
  }
}