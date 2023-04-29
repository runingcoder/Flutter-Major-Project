import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/record_audio_provider.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({Key? key}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {


    Future<void>  _showDeleteConfirmation(BuildContext context, DocumentReference docRef) async {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.grey.shade100,
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                Text(
                  'Are you sure you want to delete this item?',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: Text('Delete'),
                      onPressed: () {
                        docRef.delete();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    final String uid = FirebaseAuth.instance.currentUser!.uid!;
    String imagetileBG = 'https://images.unsplash.com/photo-1565386239166-a1233b30138d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80';
    String imageUrlBG =
        'https://images.unsplash.com/photo-1550895030-823330fc2551?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80';
    return Scaffold(

        body: Stack (
          children: [

            Image.network(
              imageUrlBG,
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
                          .collection('history')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
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
                            child: Text('No History yet.', style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),),
                          );
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final doc = snapshot.data!.docs[index];
                            final songName = doc['songName'];
                            final isFavorite = doc['isFavorite'];
                            final songArtist = doc['artists'];
                            final songImageUrl = doc['ImageUrl'];
                            final createdAt = doc['createdAt'];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display the date above the container
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      DateFormat('EEEE, MMM d').format(createdAt.toDate()),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Display the song image on the left of the tile
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                          songImageUrl,
                                          fit: BoxFit.cover,
                                          height: MediaQuery.of(context).size.height * 0.2,
                                          width: MediaQuery.of(context).size.width * 0.3,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ListTile(
                                          selectedTileColor: Colors.cyanAccent[100],
                                          title: Text(
                                            songName,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 4),
                                              Text(
                                                songArtist,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Wrap(
                                            spacing: -10,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                                  color: isFavorite ? Colors.red : Colors.grey,
                                                ),
                                                onPressed: ()  {
                                                  doc.reference.update({'isFavorite': !isFavorite});
                                                  Provider.of<RecordAudioProvider>(context).addSongToFavorites(songName, !isFavorite, songArtist, songImageUrl);
                                                },
                                              ),
                                              Theme(
                                                data: Theme.of(context).copyWith(
                                                  cardColor: Colors.green.shade300, // Set the background color of the popup menu
                                                ),
                                                child: PopupMenuButton<String>(
                                                  icon: Icon(Icons.more_vert),
                                                  onSelected: (String choice) {
                                                    if (choice == 'delete') {
                                                      doc.reference.delete();
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext context) {
                                                    return ['delete'].map((String choice) {
                                                      return PopupMenuItem<String>(
                                                        value: choice,
                                                        child: Text(
                                                          choice,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );


                          },
                        );

                      },
                  ),

                  ),
                ],
              ),
            ),

          ],
        )

    );
  }

}
