import 'package:app_test/MyAppPages/Les%20membre.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:places_service/places_service.dart';

class InfoGroupe extends StatefulWidget {
  String idGroupe;
  bool estProprietaire ;
  InfoGroupe(this.idGroupe,this.estProprietaire);

  @override
  State<InfoGroupe> createState() => _InfoGroupeState();
}

enum MenuValues { ModifierDestination, ModifierDateDepart }

class _InfoGroupeState extends State<InfoGroupe> {
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('Utilisateur');
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Groupe',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins'),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: screenWidth / 10,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          (widget.estProprietaire) ?IconTheme(
            data: IconThemeData(color: Colors.black),
            child: PopupMenuButton<MenuValues>(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: Text('Modifier la déstination'),
                  value: MenuValues.ModifierDestination,
                ),
                PopupMenuItem(
                  child: Text('Modifier la date de départ'),
                  value: MenuValues.ModifierDateDepart,
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case MenuValues.ModifierDestination:
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Modifier la déstination'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Modifier'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Annuler'),
                            ),
                          ],
                        );
                      },
                    );
                    break;
                  case MenuValues.ModifierDateDepart:
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Modifier la date de départ'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Modifier'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Annuler'),
                            ),
                          ],
                        );
                      },
                    );
                    break;
                }
              },
            ),
          ) : Icon(
            Icons.arrow_back,
            color: Colors.transparent,
            size: screenWidth / 10,
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: padding,
              child: StreamBuilder<DocumentSnapshot>(
                stream: utilisateurCollection
                    .doc(auth.currentUser!.uid)
                    .collection('Groupes')
                    .doc(widget.idGroupe)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Text('No user data found');
                  } else {
                    DateTime dateDepart = snapshot.data!['dateDepart'].toDate();
                    PlacesAutoCompleteResult lieuArrivee = PlacesAutoCompleteResult(
                      placeId: snapshot.data!['lieuArrivee']['placeId'],
                      description: snapshot.data!['lieuArrivee']['description'],
                      mainText: snapshot.data!['lieuArrivee']['mainText'],
                      secondaryText: snapshot.data!['lieuArrivee']['secondaryText'],
                    );
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Destination',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Colors.black
                              ),
                            ),
                            Text(
                              '${lieuArrivee.description}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.indigoAccent[400],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Date de départ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Colors.black
                              ),
                            ),
                            Text(
                              '${dateDepart.day}/${dateDepart.month}/${dateDepart.year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.indigoAccent[400],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight/10,),
                        Container(
                          width: screenWidth,
                          height: screenHeight/6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ConsulterLesMembres(widget.idGroupe, widget.estProprietaire),));
                            },
                            child: Text(
                              'Consulter les membres du groupe',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight/10,),
                        Container(
                          width: screenWidth,
                          height: screenHeight/6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: (){},
                            child: Text(
                              'Consulter le déplacement sur la carte',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
