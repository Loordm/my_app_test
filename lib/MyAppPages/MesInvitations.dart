import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/MyAppClasses/Utilisateur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:places_service/places_service.dart';

import '../MyAppClasses/Invitation.dart';
import '../Services/CloudFirestoreMethodes.dart';

class MesInvitations extends StatefulWidget {
  static const String screenRoute = '/mesInvitations';

  const MesInvitations({Key? key}) : super(key: key);

  @override
  State<MesInvitations> createState() => _MesInvitationsState();
}

class _MesInvitationsState extends State<MesInvitations> {
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('Utilisateur');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _cloudFirestore = CloudFirestoreMethodes();
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Align(
            alignment: Alignment.center,
            child: Text(
              'Mes Invitations',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Poppins'),
            ),
          ),
        ),
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: StreamBuilder(
            stream:
                utilisateurCollection.doc(auth.currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text(
                    'Vous n\'avez aucune invitation pour le moment',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 16),
                  ),
                );
              } else {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                List<Invitation> invitations = [];
                if (data['invitations'] != null) {
                  List<dynamic> invitationsData = data['invitations'];
                  invitations = invitationsData.map((invitationData) {
                    return Invitation(
                      idEnvoyeur: invitationData['idEnvoyeur'],
                      idRecepteur: invitationData['idRecepteur'],
                      idGroupe: invitationData['idGroupe'],
                      acceptation: invitationData['acceptation'],
                      dejaTraite: invitationData['dejaTraite'],
                    );
                  }).toList();
                }
                /// wrap it with a StremBuilder of the user of idEnvoyeur
                return (invitations.isNotEmpty) ? ListView.builder(
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invitation = invitations[index];
                    return StreamBuilder<DocumentSnapshot>(
                      stream: utilisateurCollection
                          .doc(invitation.idEnvoyeur)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center();
                        } else {
                          Utilisateur utilisateur =
                              Utilisateur.creerUtilisateurVide();
                          utilisateur.identifiant =
                              snapshot.data!['identifiant'];
                          utilisateur.email = snapshot.data!['email'];
                          utilisateur.numeroDeTelephone =
                              snapshot.data!['numeroDeTelephone'];
                          utilisateur.nomComplet = snapshot.data!['nomComplet'];
                          utilisateur.imageUrl =
                              snapshot.data!['imageUrl'];
                          return StreamBuilder<DocumentSnapshot>(
                            stream: utilisateurCollection
                                .doc(utilisateur.identifiant)
                                .collection('Groupes')
                                .doc(invitation.idGroupe)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center();
                              }
                              else if (snapshot.connectionState == ConnectionState.waiting) {
                                // While data is loading
                                return const CircularProgressIndicator();
                              }
                              else if (snapshot.hasError) {
                                // Handle the error
                                return Text('Error: ${snapshot.error}');
                              }
                              else {
                                if (snapshot.data!.exists) {
                                  Groupe groupe = Groupe.creerGroupeVide();
                                  DateTime dateDepart = snapshot.data!['dateDepart'].toDate();
                                  PlacesAutoCompleteResult lieuArrivee = PlacesAutoCompleteResult(
                                      placeId: snapshot
                                          .data!['lieuArrivee']['placeId'],
                                      description: snapshot
                                          .data!['lieuArrivee']['description'],
                                      mainText: snapshot
                                          .data!['lieuArrivee']['mainText'],
                                      secondaryText: snapshot
                                          .data!['lieuArrivee']
                                      ['secondaryText']);
                                  groupe.lieuArrivee = lieuArrivee;
                                  groupe.dateDepart = dateDepart;
                                  // get id owner
                                  groupe.idOwner = snapshot.data!['idOwner'] ;
                                  groupe.idGroupeOwner = invitation.idGroupe;
                                  Map<String, dynamic> membersData = snapshot.data!.data() as Map<String, dynamic>;
                                  if (membersData.isNotEmpty) {
                                    List<String> membres = [];
                                    membres = List<String>.from(membersData['membres']);
                                    groupe.membres = membres;
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    width: screenWidth,
                                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 24),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 0, 0),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: SizedBox(
                                              width: screenWidth,
                                              child: Row(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.topLeft,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius
                                                          .circular(100),
                                                      child: Image.network(
                                                        utilisateur.imageUrl,
                                                        fit: BoxFit.cover,
                                                        width: screenWidth / 7,
                                                        height: screenWidth / 7,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '  ${utilisateur
                                                              .nomComplet}',
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontFamily: 'Poppins',
                                                            fontWeight: FontWeight
                                                                .w300,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        SelectableText(
                                                          '  ${utilisateur
                                                              .numeroDeTelephone}    ',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontFamily: 'Poppins',
                                                            fontWeight: FontWeight
                                                                .w300,
                                                            color: Colors
                                                                .indigoAccent[400],
                                                          ),
                                                        ),
                                                        SelectableText(
                                                          '  ${utilisateur.email}',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontFamily: 'Poppins',
                                                            fontWeight: FontWeight
                                                                .w300,
                                                            color: Colors
                                                                .indigoAccent[400],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6,),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 8, 0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              const Text(
                                                textAlign: TextAlign.center,
                                                'Invitation pour rejoindre le groupe de Grine Mohammed pour allez vers :',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                textAlign: TextAlign.center,
                                                '${lieuArrivee
                                                    .description}, le ${dateDepart
                                                    .day}/${dateDepart
                                                    .month}/${dateDepart.year}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .indigoAccent[400],
                                                ),
                                              ),
                                              const SizedBox(height: 12,),
                                              (!invitations[index].dejaTraite)
                                                  ? Column(
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .green[200],
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          invitations[index]
                                                              .dejaTraite =
                                                          true;
                                                          invitations[index]
                                                              .acceptation =
                                                          true;
                                                        });
                                                        await _cloudFirestore.modifierInvitation(auth.currentUser!.uid, index, true);
                                                        await _cloudFirestore.ajouterGroupe(auth.currentUser!.uid, groupe,invitation.idGroupe);
                                                        await _cloudFirestore.ajouterUtilisateurAuGroupe(groupe.idOwner, invitation.idGroupe, auth.currentUser!.uid);
                                                        /// ajouter cet utilisateur a toutes les membres du groupe du owner
                                                      },
                                                      child: SizedBox(
                                                        width: screenWidth,
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              color: Colors
                                                                  .green,
                                                              child: const Icon(
                                                                  Icons.check),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .center,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(16.0),
                                                                  child: Text(
                                                                    'Accepter l\'invitation',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontFamily: 'Poppins',
                                                                      fontWeight: FontWeight
                                                                          .bold,
                                                                      color: Colors
                                                                          .green[600],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: screenHeight / 40,),
                                                  SizedBox(
                                                    width: screenWidth,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .red[200],
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          invitations[index]
                                                              .dejaTraite =
                                                          true;
                                                          invitations[index]
                                                              .acceptation =
                                                          false;
                                                        });
                                                        await _cloudFirestore
                                                            .modifierInvitation(
                                                            auth.currentUser!
                                                                .uid, index,
                                                            false);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            color: Colors.red,
                                                            child: const Icon(
                                                                Icons.close),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .center,
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(16.0),
                                                                child: Text(
                                                                  'Réfuser l\'invitation',
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontFamily: 'Poppins',
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors
                                                                        .red[600],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                                  :
                                              Container(
                                                margin: const EdgeInsets.fromLTRB(
                                                    5, 0, 5, 0),
                                                padding: const EdgeInsets.fromLTRB(
                                                    0, 10, 0, 10),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .circular(20),
                                                  color: (invitations[index]
                                                      .acceptation) ? Colors
                                                      .green[100] : Colors
                                                      .red[100],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    (invitations[index]
                                                        .acceptation) ? const Icon(
                                                      Icons.check_circle,
                                                      size: 40,
                                                      color: Colors.green,

                                                    ) :
                                                    const Icon(
                                                      Icons.cancel,
                                                      size: 40,
                                                      color: Colors.red,

                                                    ),
                                                    (invitations[index]
                                                        .acceptation) ? const Text(
                                                      "L'invitation a été acceptée",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.green,
                                                      ),
                                                    ) :
                                                    const Text(
                                                      "L'invitation a été refusée",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.red,
                                                      ),
                                                    )

                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20,),
                                      ],
                                    ),
                                  );
                                }else {
                                  _cloudFirestore.supprimerInvitation(auth.currentUser!.uid, index);
                                  return const SizedBox(width: 0,height: 0,);
                                }
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                ) : const Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    'Vous n\'avez aucune invitation pour le moment',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 16),
                  ),
                );
              }
            },
          ),
        ));
  }
}
