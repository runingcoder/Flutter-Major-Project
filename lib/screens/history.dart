import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalmicrophone/screens/resultPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({Key? key}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  Future<void> addSongToFavorites(String songName, bool isFavorite) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid!;
    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');

    final querySnapshot = await favoritesRef
        .where('songName', isEqualTo: songName)
        .limit(1)
        .get();

    if (isFavorite) {
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({'isFavorite': true});
      } else {
        await favoritesRef.add({
          'songName': songName,
          'isFavorite': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } else {
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.delete();
      }
    }
  }
  void _openResultsPage(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> songData ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShazamResultPage(
          name_and_artist: songData['nameAndArtist'].toString(),
          url:  songData['url'].toString(),
          image_url:  songData['imageUrl'].toString(),
          channel_url:  songData['channelUrl'].toString(),
        ),
      ),
    );
  }




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
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover, image: NetworkImage(imagetileBG)),
                                color: Colors.lightBlueAccent.shade100,
                                borderRadius: BorderRadius.circular(8.0),),
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 4.0),

                            child: ListTile(
                              selectedTileColor : Colors.cyanAccent[100],
                              title: Text(songName,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),),
                              trailing: IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.white,
                                ),
                                onPressed: ()  {
                                  doc.reference.update({'isFavorite': !isFavorite});
                                   //worked when doing !isFavorite instead of isFavorite.
                                   addSongToFavorites(doc['songName'],!isFavorite );
                                },
                              ),
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
