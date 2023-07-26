import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/MyAppClasses/Utilisateur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  bool dejaTraite = false ;
  bool accepte_refuse = false ;
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
              'Mes Invitations',
              style: TextStyle(
                  fontSize: 30,
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(
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
                Utilisateur currentUser = Utilisateur.creerUtilisateurVide();
                currentUser.identifiant = data['identifiant'];
                currentUser.email = data['email'];
                currentUser.nomComplet = data['nomComplet'];
                currentUser.numeroDeTelephone = data['numeroDeTelephone'];
                currentUser.imageUrl = data['imageUrl'];
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return Center();
                        } else {
                          dejaTraite = invitation.dejaTraite;
                          accepte_refuse = invitation.acceptation;
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
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData) {
                                return Center();
                              } else {
                                Groupe groupe = Groupe.creerGroupeVide();
                                DateTime dateDepart = snapshot.data!['dateDepart'].toDate();
                                PlacesAutoCompleteResult lieuArrivee = PlacesAutoCompleteResult(
                                    placeId: snapshot.data!['lieuArrivee']['placeId'],
                                    description: snapshot.data!['lieuArrivee']['description'],
                                    mainText: snapshot.data!['lieuArrivee']['mainText'],
                                    secondaryText: snapshot.data!['lieuArrivee']
                                    ['secondaryText']);
                                groupe.lieuArrivee = lieuArrivee ;
                                groupe.dateDepart = dateDepart;
                                // get owner
                                groupe.owner.identifiant = snapshot.data!['owner']['identifiant'];
                                groupe.owner.email = snapshot.data!['owner']['email'];
                                groupe.owner.numeroDeTelephone =
                                snapshot.data!['owner']['numeroDeTelephone'];
                                groupe.owner.nomComplet = snapshot.data!['owner']['nomComplet'];
                                groupe.owner.imageUrl = snapshot.data!['owner']['imageUrl'];
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
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  width: screenWidth,
                                  height: (!dejaTraite) ? screenHeight/2.6 : screenHeight/3.2,
                                  padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
                                  margin: EdgeInsets.symmetric(horizontal: 24,vertical: 24),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(100),
                                              child: Image.network(
                                                '${utilisateur.imageUrl}',
                                                fit: BoxFit.cover,
                                                width: screenWidth / 7,
                                                height: screenWidth / 7,
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  '  ${utilisateur.nomComplet}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '  ${utilisateur.numeroDeTelephone}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w300,
                                                        color: Colors.indigoAccent[400],
                                                      ),
                                                    ),
                                                    SizedBox(width: screenWidth/20,),
                                                    Text(
                                                      '${utilisateur.email}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w300,
                                                        color: Colors.indigoAccent[400],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 6,),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Invitation pour rejoindre le groupe de Grine Mohammed pour allez vers :',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              '${lieuArrivee.description}, le ${dateDepart.day}/${dateDepart.month}/${dateDepart.year}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigoAccent[400],
                                              ),
                                            ),
                                            SizedBox(height: 12,),
                                            (!dejaTraite) ? Column(
                                              children: [
                                                Container(
                                                  width: screenWidth,
                                                  height: 50,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green[200],
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    onPressed: () async{
                                                      await _cloudFirestore.modifierInvitation(auth.currentUser!.uid, index, true);
                                                      await _cloudFirestore.ajouterGroupe(auth.currentUser!.uid, groupe);
                                                      print('****************************************');
                                                      print('idGroupe = ${invitation.idGroupe}');
                                                      print('****************************************');
                                                      await _cloudFirestore.ajouterUtilisateurAuGroupe(groupe.owner.identifiant, invitation.idGroupe, currentUser);
                                                    },
                                                    child: Container(
                                                      width: screenWidth,
                                                      height: 50,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            color: Colors.green,
                                                            child: Icon(Icons.check),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Expanded(
                                                            child: Align(
                                                              alignment: Alignment.center,
                                                              child: Text(
                                                                'Accepter l\'invitation',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily: 'Poppins',
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.green[600],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: screenHeight/40,),
                                                Container(
                                                  width: screenWidth,
                                                  height: 50,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red[200],
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    onPressed: () async{
                                                      await _cloudFirestore.modifierInvitation(auth.currentUser!.uid, index, false);
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          color: Colors.red,
                                                          child: Icon(Icons.close),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                              'Réfuser l\'invitation',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily: 'Poppins',
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.red[600],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ) :
                                            Container(
                                              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                color: (accepte_refuse) ? Colors.green[100] : Colors.red[100],
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  (accepte_refuse) ? Icon(
                                                    Icons.check_circle,
                                                    size: 40,
                                                    color: Colors.green,

                                                  ) :
                                                  Icon(
                                                    Icons.cancel,
                                                    size: 40,
                                                    color: Colors.red,

                                                  ),
                                                  (accepte_refuse) ? Text("L\'invitation a été acceptée",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.green,
                                                    ),
                                                  ) :
                                                  Text("L\'invitation a été refusée",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.red,
                                                    ),
                                                  )

                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                ) : Center(
                  child: Text(
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
