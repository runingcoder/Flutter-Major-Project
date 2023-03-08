import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../provider/record_audio_provider.dart';
import 'package:provider/provider.dart';


class ShazamResultPage extends StatefulWidget {
  final String name_and_artist;
  final String url;
  final String channel_url;
  final String image_url;

  const ShazamResultPage({
    Key? key,
    required this.name_and_artist,
    required this.url,
    required this.channel_url,
    required this.image_url,
  }) : super(key: key);

  @override
  _ShazamResultPageState createState() => _ShazamResultPageState();
}

class _ShazamResultPageState extends State<ShazamResultPage>
   {

  late YoutubePlayerController  _ycontroller;

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
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image
              // Song Name and Artist
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name_and_artist,
                      style: TextStyle(
                        fontFamily: 'MycustomFont',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    YoutubePlayer(controller: _ycontroller,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.amber,
                        bottomActions:[
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
                        ]


                    ),
                    SizedBox(height: 900),
                    Text('sdfasdf'),

                  ],
                ),
              ),
            ],
          ),
        ),),
      ),
    );
  }
}
