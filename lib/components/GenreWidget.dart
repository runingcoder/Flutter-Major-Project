import 'package:finalmicrophone/components/songCard.dart';
import 'package:finalmicrophone/components/songClassforGenres.dart';
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
    if (widget.genreSongs.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "You may also like!!",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 300.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.genreSongs.length,
            itemBuilder: (BuildContext context, int index) {
              Song song = widget.genreSongs[index];
              return SongCard(
                imageUrl: song.imageUrl,
                name: song.name,
                artistName: song.artistName,
              );
            },
          ),
        ),
      ],
    );

  }
}