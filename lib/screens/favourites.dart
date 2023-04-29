import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalmicrophone/screens/songsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  void _openResultsPage(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> songData ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongPage(
          name: songData['name'].toString(),
          url:  songData['url'].toString(),
          image_url:  songData['imageUrl'].toString(),
          album_name:  songData['album_name'].toString(),
          artists: songData['artists'].join(', '),
          genres: songData['genres'].join(', '),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid!;
    String imagetileBG = 'https://images.unsplash.com/photo-1565386239166-a1233b30138d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80';
    String imageUrlBG =
        'https://images.unsplash.com/photo-1550895030-823330fc2551?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80';
    return Scaffold(
        body: Stack(
      children: [
        Image.network(
          imageUrlBG, // replace with your image URL
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('favorites')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Text('No favorites yet.', style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final songName = doc['songName'];
                      final isFavorite = doc['isFavorite'];

                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(imagetileBG)),
                          color: Colors.lightBlueAccent.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          onTap: () async {
                            print(doc['songName']);
                            var requiredSong = await FirebaseFirestore.instance.collection('users').doc(uid)
                                .collection('songs')
                                .where('name', isEqualTo: songName)
                                .limit(1).get();
                            var songData = requiredSong.docs.first;
                            print(songData['name']);
                            print(songData['artists']);
                            _openResultsPage(context, songData);
                          } ,
                          title: Text(songName, style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),),
                          trailing: IconButton(
                            icon: Icon(Icons.icecream_rounded,  color: Colors.green,),
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                  );
                },
              )),
            ],
          ),
        ),
      ],
    ));
  }
}
