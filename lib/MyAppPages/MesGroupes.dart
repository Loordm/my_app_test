import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/MyAppPages/Creer%20un%20groupe.dart';
import 'package:app_test/Services/CloudFirestoreMethodes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:places_service/places_service.dart';
import '../MyAppClasses/Utilisateur.dart';
import 'Informations du groupe.dart';

class MesGroupes extends StatefulWidget {
  static const String screenRoute = '/mesGroupes';

  const MesGroupes({Key? key}) : super(key: key);

  @override
  State<MesGroupes> createState() => _MesGroupesState();
}

class _MesGroupesState extends State<MesGroupes> {
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('Utilisateur');
  final FirebaseAuth auth = FirebaseAuth.instance;
  Utilisateur utilisateur = Utilisateur.creerUtilisateurVide();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final padding = MediaQuery.of(context).padding;
    const double textSize = 16;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Mes groupes',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins'),
          ),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: utilisateurCollection
                .doc(auth.currentUser!.uid)
                .collection('Groupes')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Il n\'existe aucun groupe');
              } else {
                final allGroupes = snapshot.data!.docs;
                List<Groupe> groupesList = [];
                for (var groupe in allGroupes) {
                  if (groupe.exists) {
                    Groupe newGroupe = Groupe.creerGroupeVide();
                    newGroupe.idGroupe = groupe['idGroupe'];
                    newGroupe.lieuArrivee = PlacesAutoCompleteResult(
                      placeId: groupe['lieuArrivee']['placeId'],
                      description: groupe['lieuArrivee']['description'],
                      mainText: groupe['lieuArrivee']['mainText'],
                      secondaryText: groupe['lieuArrivee']['secondaryText'],
                    );
                    newGroupe.dateDepart = groupe['dateDepart'].toDate();
                    GeoPoint geoPointArrivee = groupe['owner']['positionActuel'];
                    newGroupe.owner = Utilisateur(
                      identifiant: groupe['owner']['identifiant'],
                      nomComplet: groupe['owner']['nomComplet'],
                      email: groupe['owner']['email'],
                      numeroDeTelephone: groupe['owner']['numeroDeTelephone'],
                      imageUrl: groupe['owner']['imageUrl'],
                      positionActuel: LatLng(
                          geoPointArrivee.latitude, geoPointArrivee.longitude),
                    );
                    groupesList
                        .add(
                        newGroupe); // Add the new Groupe object to the list
                  }
                }
                utilisateur.groupes = groupesList;
                return (utilisateur.groupes.isNotEmpty)
                    ? ListView.builder(
                        itemCount: utilisateur.groupes.length,
                        itemBuilder: (context, index) {
                          final groupe = utilisateur.groupes[index];
                          return GestureDetector(
                            onTap: () {
                              if (groupe.owner.identifiant ==
                                  auth.currentUser!.uid) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            InfoGroupe(groupe.idGroupe, true)));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => InfoGroupe(
                                            groupe.idGroupe, false)));
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    12), // Set the radius here
                              ),
                              width: screenWidth,
                              height: 200,
                              padding: padding,
                              margin: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 0, 0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${groupe.lieuArrivee.description}',
                                            style: const TextStyle(
                                                fontSize: textSize,
                                                fontFamily: 'Poppins',
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            '${groupe.dateDepart.day}/${groupe.dateDepart.month}/${groupe.dateDepart.year}',
                                            style: const TextStyle(
                                                fontSize: textSize,
                                                fontFamily: 'Poppins',
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      groupe.owner.identifiant ==
                                              auth.currentUser!.uid
                                          ? const Text(
                                              'Vous êtes le propriétaire',
                                              style: TextStyle(
                                                  fontSize: textSize,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black),
                                            )
                                          : const Text(
                                              'Vous êtes un membre',
                                              style: TextStyle(
                                                  fontSize: textSize,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black),
                                            ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await CloudFirestoreMethodes()
                                              .supprimerGroupe(
                                                  auth.currentUser!.uid,
                                                  groupe.idGroupe);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                duration: Duration(seconds: 2),
                                                content: Text(
                                                    'Supprition du groupe avec succees')),
                                          );
                                        },
                                        child: groupe.owner.identifiant ==
                                                auth.currentUser!.uid
                                            ? const Text(
                                                'Supprimer ce groupe',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              )
                                            : const Text(
                                                'Quitter ce groupe',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'Vous n\'avez aucun groupe pour le moment',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 16),
                        ),
                      );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.pushNamed(context, CreerGroupe.screenRoute);
        },
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigoAccent[400],
        label: const Text('Ajouter un groupe',style: TextStyle(fontFamily: 'Poppins',fontSize: 12),),
      ),
    );
  }
}
