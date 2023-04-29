import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalmicrophone/components/songCard.dart';
import 'package:flutter/material.dart';

class GenreWidget extends StatefulWidget {
  final List<dynamic> genreSongs;

  const GenreWidget({Key? key, required this.genreSongs}) : super(key: key);

  @override
  _GenreWidgetState createState() => _GenreWidgetState();
}

class _GenreWidgetState extends State<GenreWidget> {


  @override
  Widget build(BuildContext context) {
    print(widget.genreSongs);
    return SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 150.0,

        child: SongCard(
          imageUrl: widget.genreSongs[0].imageUrl,
          name: widget.genreSongs[0].name,
          artistName: widget.genreSongs[0].artistName,
        )

    );
  }
}