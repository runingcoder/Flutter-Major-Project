import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Create fade-in animation
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        _recordProvider. onWillPop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.purple[800],
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image
              Expanded(
                flex: 7,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      heightFactor: 0.9,
                      widthFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple[800]!,
                              Colors.purple[300]!,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            FadeTransition(
                              opacity: _animation,
                              child: Image.network(
                                widget.image_url,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Song Name and Artist
              Flexible(
                flex: 3,
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 500),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name_and_artist,
                          style: TextStyle(
                            fontFamily: 'MycustomFont',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.url,
                          style: TextStyle(
                            fontFamily: 'MycustomFont',
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.channel_url,
                          style: TextStyle(
                            fontFamily: 'MycustomFont',
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
