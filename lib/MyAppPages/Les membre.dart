import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/Services/CloudFirestoreMethodes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:places_service/places_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../MyAppClasses/Invitation.dart';
import '../MyAppClasses/Utilisateur.dart';

class ConsulterLesMembres extends StatefulWidget {
  String idGroupe;

  bool estProprietaire;

  ConsulterLesMembres(this.idGroupe, this.estProprietaire);

  @override
  State<ConsulterLesMembres> createState() => _ConsulterLesMembresState();
}

enum MenuValuesProprietaire {
  SupprimerGroupe,
  InviterUnMembre,
}

enum MenuValuesMembre { QuitterLeGroupe }

class _ConsulterLesMembresState extends State<ConsulterLesMembres> {
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('Utilisateur');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _cloudFirestore = CloudFirestoreMethodes();
  Groupe groupe = Groupe.creerGroupeVide();
  @override

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Les membres',
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
          IconTheme(
              data: IconThemeData(color: Colors.black),
              child: (widget.estProprietaire)
                  ? PopupMenuButton<MenuValuesProprietaire>(
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<MenuValuesProprietaire>(
                          child: Text('Supprimer le groupe'),
                          value: MenuValuesProprietaire.SupprimerGroupe,
                        ),
                        PopupMenuItem<MenuValuesProprietaire>(
                          child: Text('Inviter un membre'),
                          value: MenuValuesProprietaire.InviterUnMembre,
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case MenuValuesProprietaire.SupprimerGroupe:
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Supprimer le groupe'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop();
                                      },
                                      child: Text('Supprimer'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop();
                                      },
                                      child: Text('Annuler'),
                                    ),
                                  ],
                                );
                              },
                            );
                            break;
                          case MenuValuesProprietaire.InviterUnMembre:
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Inviter un membre'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop();
                                      },
                                      child: Text('Inviter'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop();
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
                    )
                  : PopupMenuButton<MenuValuesMembre>(
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<MenuValuesMembre>(
                          child: Text('Quitter le groupe'),
                          value: MenuValuesMembre.QuitterLeGroupe,
                        ),
                      ],
                      onSelected: (value) {
                        if (value == MenuValuesMembre.QuitterLeGroupe) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Quitter le groupe'),
                                actions: [
                                  TextButton(
                                    onPressed: () async{
                                      Navigator.of(context)
                                          .pop();
                                    },
                                    child: Text('Quitter'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text('Annuler'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    )),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
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
              // get les informations du goupe
              DateTime dateDepart = snapshot.data!['dateDepart'].toDate();
              PlacesAutoCompleteResult lieuArrivee = PlacesAutoCompleteResult(
                  placeId: snapshot.data!['lieuArrivee']['placeId'],
                  description: snapshot.data!['lieuArrivee']['description'],
                  mainText: snapshot.data!['lieuArrivee']['mainText'],
                  secondaryText: snapshot.data!['lieuArrivee']
                      ['secondaryText']);
              groupe.idGroupe = widget.idGroupe;
              groupe.dateDepart = dateDepart;
              groupe.lieuArrivee = lieuArrivee;
              // get le proprietaire du groupe
              groupe.owner.identifiant = snapshot.data!['owner']['identifiant'];
              groupe.owner.email = snapshot.data!['owner']['email'];
              groupe.owner.numeroDeTelephone =
                  snapshot.data!['owner']['numeroDeTelephone'];
              groupe.owner.nomComplet = snapshot.data!['owner']['nomComplet'];
              groupe.owner.imageUrl = snapshot.data!['owner']['imageUrl'];
              // get les membres du groupe
              List<Map<String, dynamic>> membersData = (snapshot.data!['membres'] as List<dynamic>).cast<Map<String, dynamic>>();
              if (membersData.isNotEmpty) {
                List<Utilisateur> membres = membersData.map((memberData) {
                  return Utilisateur(
                      identifiant: memberData['identifiant'],
                      email: memberData['email'],
                      numeroDeTelephone: memberData['numeroDeTelephone'],
                      imageUrl: memberData['imageUrl'],
                      nomComplet: memberData['nomComplet'],
                      positionActuel: LatLng(0, 0));
                }).toList();
                groupe.membres = membres;
              }
              return Column(
                children: [
                  SizedBox(height: 20),
                  (!widget.estProprietaire)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 4, 0),
                              child: Text(
                                'Le propriétaire',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 10,),
                            InfoUserContainer(
                                groupe.owner.imageUrl,
                                groupe.owner.nomComplet,
                                groupe.owner.email,
                                groupe.owner.numeroDeTelephone,
                                false,0,''),
                          ],
                        )
                      : Text(
                          textAlign: TextAlign.center,
                          'Vous êtes le propriétaire',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color: Colors.black),
                        ),
                  SizedBox(height: 10,),
                  (groupe.membres.isNotEmpty) ? Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 4, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Les membres',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black),
                      ),
                    ),
                  ) : Center(child: Text(
                          'Aucun membre pour le moment',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.black
                          ),
                        ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: ListView.builder(
                        itemCount: groupe.membres.length,
                        itemBuilder: (context, index) {
                          final membreAffiche = groupe.membres[index];
                          return InfoUserContainer(
                            membreAffiche.imageUrl,
                            membreAffiche.nomComplet,
                            membreAffiche.email,
                            membreAffiche.numeroDeTelephone,
                            true,
                            index,
                            groupe.idGroupe
                          );
                        }
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget InfoUserContainer(String imageUrl, String nomComplet, String email,
      String numeroDeTelephone, bool ableToDelete, int index,String uidGroupe) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final padding = MediaQuery.of(context).padding;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      width: screenWidth,
      padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
      margin: EdgeInsets.symmetric(horizontal: 24,vertical: 24),
      height: (ableToDelete && widget.estProprietaire) ? 210 : 180,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    '$imageUrl',
                    fit: BoxFit.cover,
                    width: screenWidth / 7,
                    height: screenWidth / 7,
                  ),
                ),
                Text(
                  '  $nomComplet',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: Row(
              children: [
                Text(
                  'Email :',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(
                  width: screenWidth / 10,
                ),
                Text(
                  '$email',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.indigoAccent[400],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: screenWidth,
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(
                    width: 1.4,
                    color: Colors.indigoAccent,
                  )),
              onPressed: () {
                launchUrlString(
                    "tel:${numeroDeTelephone}");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_in_talk,
                    color: Colors.indigoAccent[400],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '${numeroDeTelephone}',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.indigoAccent[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          (widget.estProprietaire && ableToDelete)
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Voulez vous supprimer cet utilisateur ?'),
                          actions: [
                            TextButton(
                              onPressed: () async{
                                await _cloudFirestore.supprimerUtilisateurAuGroupe(auth.currentUser!.uid,uidGroupe, index);
                                Navigator.of(context)
                                    .pop();
                              },
                              child: Text('Oui'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop();
                              },
                              child: Text('Annuler'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                    size: 28,
                  ))
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
    );
  }
}
