import 'package:flutter/material.dart';
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
    return Container(
      child: Column(
        children: List.generate(_user.favoriteItems.length, (index) => 
        ListTile(
          title: Text(_user.favoriteItems[index].resultId.toString())
        )),
      ),
    );
  }
}