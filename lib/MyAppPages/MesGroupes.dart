import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/MyAppPages/Creer%20un%20groupe.dart';
import 'package:app_test/Services/CloudFirestoreMethodes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  String currentUserIdGroupe = '';

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
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins'),
          ),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SafeArea(
          // le premier pour get le idOwner et le idGroupeOwner pour afficher les informations du groupe du owner
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
                currentUserIdGroupe = '';
                for (var groupe in allGroupes) {
                  if (groupe.exists) {
                    Groupe newGroupe = Groupe.creerGroupeVide();
                    newGroupe.idGroupe = groupe['idGroupe'];
                    currentUserIdGroupe = newGroupe.idGroupe;
                    newGroupe.idGroupeOwner = groupe['idGroupeOwner'];
                    if (newGroupe.idGroupeOwner.isEmpty) {
                      newGroupe.idGroupeOwner = newGroupe.idGroupe;
                    }
                    newGroupe.idOwner = groupe['idOwner'];
                    groupesList.add(newGroupe);
                  }
                }
                utilisateur.groupes.clear();
                utilisateur.groupes = groupesList;
                return (utilisateur.groupes.isNotEmpty)
                    ? ListView.builder(
                        itemCount: utilisateur.groupes.length,
                        itemBuilder: (context, index) {
                          final groupe = utilisateur.groupes[index];
                          // le 2eme pour get les info du groupe de chaque groupe du owner par les id precedents
                          if (groupe.idGroupeOwner.isNotEmpty) {
                            return StreamBuilder<DocumentSnapshot>(
                              stream: utilisateurCollection
                                  .doc(groupe.idOwner)
                                  .collection('Groupes')
                                  .doc(groupe.idGroupeOwner)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data != null && snapshot.data!.exists){
                                    Groupe groupeOwner = Groupe.creerGroupeVide();
                                    groupeOwner.idGroupe =
                                    snapshot.data!['idGroupe'];
                                    groupeOwner.idGroupeOwner =
                                    snapshot.data!['idGroupeOwner'];
                                    if (groupeOwner.idGroupeOwner.isEmpty) {
                                      groupeOwner.idGroupeOwner =
                                          groupeOwner.idGroupe;
                                    }
                                    groupeOwner.lieuArrivee =
                                        PlacesAutoCompleteResult(
                                          placeId: snapshot.data!['lieuArrivee']
                                          ['placeId'],
                                          description: snapshot.data!['lieuArrivee']
                                          ['description'],
                                          mainText: snapshot.data!['lieuArrivee']
                                          ['mainText'],
                                          secondaryText: snapshot.data!['lieuArrivee']
                                          ['secondaryText'],
                                        );
                                    groupeOwner.dateDepart =
                                        snapshot.data!['dateDepart'].toDate();
                                    groupeOwner.idOwner =
                                    snapshot.data!['idOwner'];
                                    Map<String, dynamic> membresData =
                                    snapshot.data!.data()
                                    as Map<String, dynamic>;
                                    if (membresData.isNotEmpty) {
                                      groupeOwner.membres = List<String>.from(
                                          membresData['membres']);
                                    }
                                    if (groupeOwner.membres
                                        .contains(auth.currentUser!.uid) ||
                                        groupeOwner.idOwner ==
                                            auth.currentUser!.uid) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (groupe.idOwner ==
                                              auth.currentUser!.uid) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InfoGroupe(
                                                            groupe.idGroupe,
                                                            true,
                                                            groupe.idGroupeOwner,
                                                            groupe.idOwner)));
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InfoGroupe(
                                                            groupe.idGroupe,
                                                            false,
                                                            groupe.idGroupeOwner,
                                                            groupe.idOwner)));
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          width: screenWidth,
                                          padding: padding,
                                          margin: const EdgeInsets.all(24),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 0, 0, 0),
                                                  child: Column(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                        Alignment.topLeft,
                                                        child: Text(
                                                          '${groupeOwner.lieuArrivee.description}',
                                                          style: const TextStyle(
                                                              fontSize: textSize,
                                                              fontFamily:
                                                              'Poppins',
                                                              color: Colors.black,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Align(
                                                        alignment:
                                                        Alignment.topLeft,
                                                        child: Text(
                                                          '${groupeOwner.dateDepart.day}/${groupeOwner.dateDepart.month}/${groupeOwner.dateDepart.year}',
                                                          style: const TextStyle(
                                                              fontSize: textSize,
                                                              fontFamily:
                                                              'Poppins',
                                                              color: Colors.black,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  groupe.idOwner ==
                                                      auth.currentUser!.uid
                                                      ? const Align(
                                                    alignment:
                                                    Alignment.center,
                                                    child: Text(
                                                      'Vous êtes le propriétaire',
                                                      style: TextStyle(
                                                          fontSize:
                                                          textSize,
                                                          fontFamily:
                                                          'Poppins',
                                                          color:
                                                          Colors.black),
                                                    ),
                                                  )
                                                      : const Align(
                                                    alignment:
                                                    Alignment.center,
                                                    child: Text(
                                                      'Vous êtes un membre',
                                                      style: TextStyle(
                                                          fontSize:
                                                          textSize,
                                                          fontFamily:
                                                          'Poppins',
                                                          color:
                                                          Colors.black),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                        Colors.red,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(24),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                          context) {
                                                            return AlertDialog(
                                                              title: (groupe
                                                                  .idOwner ==
                                                                  auth.currentUser!
                                                                      .uid)
                                                                  ? const Text(
                                                                  'Voulez vous vraiment supprimer ce groupe ?')
                                                                  : Text(
                                                                  'Voulez vous vraiment quitter ce groupe ?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await CloudFirestoreMethodes().supprimerGroupe(
                                                                        auth.currentUser!
                                                                            .uid,
                                                                        groupe
                                                                            .idGroupe);
                                                                    if (groupe
                                                                        .idOwner ==
                                                                        auth.currentUser!
                                                                            .uid) {
                                                                      ScaffoldMessenger.of(
                                                                          context)
                                                                          .showSnackBar(
                                                                        const SnackBar(
                                                                            duration: Duration(
                                                                                seconds:
                                                                                2),
                                                                            content:
                                                                            Text('Suppression du groupe avec succées')),
                                                                      );
                                                                    } else {
                                                                      await CloudFirestoreMethodes().supprimerUtilisateurAuGroupe(groupe.idOwner, groupe.idGroupeOwner, auth.currentUser!.uid);
                                                                      ScaffoldMessenger.of(
                                                                          context)
                                                                          .showSnackBar(
                                                                        const SnackBar(
                                                                            duration: Duration(
                                                                                seconds:
                                                                                2),
                                                                            content:
                                                                            Text('Vous avez quitter le groupe avec succées')),
                                                                      );
                                                                    }
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop();
                                                                  },
                                                                  child: (groupe.idOwner ==
                                                                      auth.currentUser!.uid) ? const Text(
                                                                      'Supprimer') : const Text('Quitter'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop();
                                                                  },
                                                                  child: const Text(
                                                                      'Annuler'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: groupe.idOwner ==
                                                          auth.currentUser!
                                                              .uid
                                                          ? const Text(
                                                        'Supprimer ce groupe',
                                                        style: TextStyle(
                                                            fontFamily:
                                                            'Poppins',
                                                            fontSize: 14,
                                                            color: Colors
                                                                .white),
                                                      )
                                                          : const Text(
                                                        'Quitter ce groupe',
                                                        style: TextStyle(
                                                            fontFamily:
                                                            'Poppins',
                                                            fontSize: 14,
                                                            color: Colors
                                                                .white),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      CloudFirestoreMethodes().supprimerGroupe(
                                          auth.currentUser!.uid,
                                          currentUserIdGroupe);
                                      return const SizedBox(
                                        height: 0,
                                        width: 0,
                                      );
                                    }
                                  }
                                  else {
                                    CloudFirestoreMethodes().supprimerGroupe(
                                        auth.currentUser!.uid,
                                        currentUserIdGroupe);
                                    return const SizedBox(
                                      height: 0,
                                      width: 0,
                                    );
                                  }
                                } else {
                                  return const SizedBox(
                                    height: 0,
                                    width: 0,
                                  );
                                }
                              },
                            );
                          }else {
                            return const SizedBox(
                              height: 0,
                              width: 0,
                            );
                          }
                        },
                      )
                    : const Center(
                        child: Text(
                          textAlign: TextAlign.center,
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
        label: const Text(
          'Ajouter un groupe',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
        ),
      ),
    );
  }
}
