import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/SearchResults/search.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

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
        child: Container(
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