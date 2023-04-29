import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../components/GenreWidget.dart';
import '../components/neubox.dart';
import '../components/songClassforGenres.dart';

class SongPage extends StatefulWidget {
  final List<dynamic> genres;
  final String album_name;
  final String name;
  final String url;
  final String artists;

  final String image_url;

  const SongPage({
    Key? key,
    required this.genres,
    required this.album_name,

    required this.name,
    required this.url,

    required this.image_url,
    required this.artists,
  }) : super(key: key);

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {

  final String uid = FirebaseAuth.instance.currentUser!.uid!;
  late List<dynamic> genreSongs = [];


  late YoutubePlayerController _ycontroller;
  Future<void> _fetchSongs(List<dynamic> genre) async {

    try {
      var  constSong = await FirebaseFirestore.instance
          .collection('songs')
          .where('name', isEqualTo: "Dark Necessities")
          .limit(1)
          .get();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('RecommendGenres')
          .where('name', isEqualTo: genre[0])
          .limit(1)
          .get();

      final docSnapshot = querySnapshot.docs.first;
      final songs = docSnapshot.data()['songs'];
      print(songs);
      List<dynamic> songsList = [];

      for (var songName in songs) {
        //so just, make sure all songs from songsOfGenres is imported in the database, and it will show.
        var requiredSong = await FirebaseFirestore.instance
            .collection('songs')
            .where('name', isEqualTo: songName)
            .limit(1)
            .get();
        var songData;
        if (requiredSong.docs.isNotEmpty) {
          songData = requiredSong.docs.first.data();
        } else {
          songData = constSong.docs.first.data();
        }
        var song = Song.fromJson(songData);
        songsList.add(song);




      }
      print('should print songslist below!');
      print(songsList[0].name);
      print(songsList[1].name);
      setState(() {
        print(songsList);
        genreSongs = songsList;
      });
    } catch (error) {
      print('Error fetching songs: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSongs(widget.genres);
    final videoId = YoutubePlayer.convertUrlToId(widget.url);
    _ycontroller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    var titleGenre = widget.genres;
    var stringGenre = titleGenre.toString();
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // back button and menu button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: NeuBox(
                          child: BackButton(
                              )),
                    ),
                    Text('Y  O U R  S O N G !'),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: NeuBox(child: Icon(Icons.menu)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // cover art, artist name, song name
                NeuBox(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:CachedNetworkImage(
                        height: 280,
                          fit: BoxFit.fill,
                          progressIndicatorBuilder: (context, url, progress) => Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                            ),
                          ),
                          imageUrl: widget.image_url,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,

                                ),
                              ),
                            ),
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.album_name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,

                        ),
                      ),
                      Text(
                        stringGenre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,

                        ),
                      ),
                      Text(
                        widget.artists,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,

                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // start time, shuffle button, repeat button, end time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text('0:00'),
                    Icon(Icons.shuffle),
                    Icon(Icons.repeat),
                    Text('4:22')
                  ],
                ),

                const SizedBox(height: 30),

                // linear bar
                NeuBox(
                  child: LinearPercentIndicator(
                    lineHeight: 10,
                    percent: 0.4,
                    progressColor: Colors.green,
                    backgroundColor: Colors.transparent,
                  ),
                ),

                const SizedBox(height: 30),

                // previous song, pause play, skip next song
                SizedBox(
                  height: 80,
                  child: Row(
                    children: const [
                      Expanded(
                        child: NeuBox(
                            child: Icon(
                          Icons.skip_previous,
                          size: 32,
                        )),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: NeuBox(
                              child: Icon(
                            Icons.play_arrow,
                            size: 32,
                          )),
                        ),
                      ),
                      Expanded(
                        child: NeuBox(
                            child: Icon(
                          Icons.skip_next,
                          size: 32,
                        )),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                NeuBox(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Youtube Player',
                          style: TextStyle(
                            // fontFamily: 'MycustomFont',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      YoutubePlayer(
                          controller: _ycontroller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.amber,
                          bottomActions: [
                            CurrentPosition(),
                            ProgressBar(
                              isExpanded: true,
                              colors: const ProgressBarColors(
                                playedColor: Colors.amber,
                                handleColor: Colors.amberAccent,
                              ),
                            ),
                            const PlaybackSpeedButton(),
                            FullScreenButton(),
                          ]),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                SizedBox(height: 100),
            Text('You might also like'),
            // GenreWidget(genreSongs:genreSongs ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
