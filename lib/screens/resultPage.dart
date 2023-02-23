import 'package:flutter/material.dart';

class ShazamResultPage extends StatefulWidget {
  final String songName;
  final String artistName;
  final String coverImageUrl;

  const ShazamResultPage({
    Key? key,
    required this.songName,
    required this.artistName,
    required this.coverImageUrl,
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
    return Scaffold(
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
                              widget.coverImageUrl,
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
                        widget.songName,
                        style: TextStyle(
                          fontFamily: 'MycustomFont',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.artistName,
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
    );
  }
}
