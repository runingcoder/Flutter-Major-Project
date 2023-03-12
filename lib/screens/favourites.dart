import 'package:flutter/material.dart';


class FavouritesPage extends StatelessWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
              child: Text('Favourites Page', textScaleFactor: 3,)
          ),
        )
    );
  }
}
