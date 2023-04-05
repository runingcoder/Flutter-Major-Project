import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../provider/record_audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/neubox.dart';

class SongPage extends StatefulWidget {
  final String name_and_artist;
  final String url;
  final String channel_url;
  final String image_url;

  const SongPage({
    Key? key,
    required this.name_and_artist,
    required this.url,
    required this.channel_url,
    required this.image_url,
  }) : super(key: key);

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  late YoutubePlayerController _ycontroller;

  @override
  void initState() {
    super.initState();
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

                const SizedBox(height: 25),

                // cover art, artist name, song name
                NeuBox(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:       Image.network(
                          widget.image_url,
                          fit: BoxFit.fill,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.name_and_artist,
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
                    percent: 0.8,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
