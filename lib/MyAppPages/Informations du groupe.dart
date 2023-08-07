import 'package:app_test/MyAppPages/Consulter%20le%20deplacement%20sur%20la%20carte.dart';
import 'package:app_test/MyAppPages/Les%20membre.dart';
import 'package:app_test/Services/CloudFirestoreMethodes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:places_service/places_service.dart';

import 'Choix du lieu darrivee.dart';

class InfoGroupe extends StatefulWidget {
  String idGroupe;
  bool estProprietaire;
  String idGroupeOwner ;
  String idOwner ;

  InfoGroupe(this.idGroupe, this.estProprietaire,this.idGroupeOwner,this.idOwner);

  @override
  State<InfoGroupe> createState() => _InfoGroupeState();
}

enum MenuValues { ModifierDestination, ModifierDateDepart }

class _InfoGroupeState extends State<InfoGroupe> {
  final CollectionReference utilisateurCollection =
  FirebaseFirestore.instance.collection('Utilisateur');
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<String> listIdUsers = [];
  DateTime dateDepart = DateTime.now();
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateDepart = DateTime(picked.year, picked.month, picked.day,
            DateTime.now().hour, DateTime.now().minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery
        .of(context)
        .size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final padding = MediaQuery
        .of(context)
        .padding;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Groupe',
            style: TextStyle(
                fontSize: 26,
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
          (widget.estProprietaire) ? IconTheme(
            data: const IconThemeData(color: Colors.black),
            child: PopupMenuButton<MenuValues>(
              itemBuilder: (BuildContext context) =>
              [
                const PopupMenuItem(
                  value: MenuValues.ModifierDestination,
                  child: Text('Modifier la déstination'),
                ),
                const PopupMenuItem(
                  value: MenuValues.ModifierDateDepart,
                  child: Text('Modifier la date de départ'),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case MenuValues.ModifierDestination:
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return ChoixLieuArrivee(modifier_ou_creer: true,idGroupe: widget.idGroupe);
                      },
                    );
                    break;
                  case MenuValues.ModifierDateDepart:
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Modifier la date de départ'),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: _selectDate,
                                icon: const Icon(Icons.calendar_today),
                              ),
                              GestureDetector(
                                onTap: _selectDate,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black54,
                                      ),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: (_selectedDate != null)
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _selectedDate!.toString().split(" ")[0],
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.black54),
                                    ),
                                  )
                                      : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async{
                                await CloudFirestoreMethodes().modifierDateDepart(auth.currentUser!.uid,widget.idGroupe,dateDepart);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(
                                    context)
                                    .showSnackBar(
                                  const SnackBar(
                                      duration: Duration(
                                          seconds:
                                          2),
                                      content:
                                      Text('Modification avec succées')),
                                );
                              },
                              child: const Text('Modifier'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Annuler'),
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
                    .doc(widget.idOwner)
                    .collection('Groupes')
                    .doc(widget.idGroupeOwner)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text('Il n\'existe aucun groupe');
                  } else {
                    if (snapshot.data!.exists) {
                      DateTime dateDepart = snapshot.data!['dateDepart']
                          .toDate();
                      PlacesAutoCompleteResult lieuArrivee = PlacesAutoCompleteResult(
                        placeId: snapshot.data!['lieuArrivee']['placeId'],
                        description: snapshot
                            .data!['lieuArrivee']['description'],
                        mainText: snapshot.data!['lieuArrivee']['mainText'],
                        secondaryText: snapshot
                            .data!['lieuArrivee']['secondaryText'],
                      );
                      return Column(
                        children: [
                          SizedBox(
                            width: screenWidth,
                            child: Row(
                              children: [
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Déstination',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        color: Colors.black
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    textAlign: TextAlign.right,
                                    '${lieuArrivee.description}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigoAccent[400],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20,),
                          SizedBox(
                            width: screenWidth,
                            child: Row(
                              children: [
                                const Align(
                                  child: Text(
                                    'Date de départ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        color: Colors.black
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    textAlign: TextAlign.right,
                                    '${dateDepart.day}/${dateDepart
                                        .month}/${dateDepart.year}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigoAccent[400],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight / 10,),
                          SizedBox(
                            width: screenWidth,
                            height: screenHeight / 6,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      ConsulterLesMembres(widget.idGroupe,
                                          widget.estProprietaire,widget.idGroupeOwner,widget.idOwner),));
                              },
                              child: const Text(
                                textAlign: TextAlign.center,
                                'Consulter les membres du groupe',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight / 10,),
                          SizedBox(
                            width: screenWidth,
                            height: screenHeight / 6,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                if (dateDepart.isBefore(DateTime.now()) || (dateDepart.year == DateTime.now().year && dateDepart.month == DateTime.now().month && dateDepart.day == DateTime.now().day) ) {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          DeplacementSurLaCarte(widget.idGroupe,widget.idGroupeOwner,widget.idOwner)));
                                }else {
                                  Duration duration = dateDepart.difference(DateTime.now());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(seconds: 8),content:
                                      (duration.inHours >= 1) ? Text('Ce n\'est pas encore la date du trajet, il reste encore ${duration.inHours} heur avant la date de départ')
                                          : Text('Ce n\'est pas encore la date du trajet, il reste encore ${duration.inMinutes} minutes avant la date de départ'))
                                  );
                                }
                              },
                              child: const Text(
                                textAlign: TextAlign.center,
                                'Consulter le déplacement sur la carte',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }else {
                      return const SizedBox(width:0,height : 0);
                    }
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
