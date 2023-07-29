import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/Services/CloudFirestoreMethodes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../MyAppClasses/Utilisateur.dart';

class ConsulterLesMembres extends StatefulWidget {
  String idGroupe;
  bool estProprietaire;
  String idGroupeOwner;

  String idOwner;

  ConsulterLesMembres(
      this.idGroupe, this.estProprietaire, this.idGroupeOwner, this.idOwner);

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
  List<String> listIdUsers = [];
  String idOwner = '';
  Utilisateur owner = Utilisateur.creerUtilisateurVide();
  List<Utilisateur> resteUsers = [];
  List<Widget> listMembersWidget = [];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Les membres',
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
          IconTheme(
              data: const IconThemeData(color: Colors.black),
              child: (widget.estProprietaire)
                  ? PopupMenuButton<MenuValuesProprietaire>(
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<MenuValuesProprietaire>(
                          value: MenuValuesProprietaire.SupprimerGroupe,
                          child: Text('Supprimer le groupe'),
                        ),
                        const PopupMenuItem<MenuValuesProprietaire>(
                          value: MenuValuesProprietaire.InviterUnMembre,
                          child: Text('Inviter un membre'),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case MenuValuesProprietaire.SupprimerGroupe:
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Supprimer le groupe'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Supprimer'),
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
                          case MenuValuesProprietaire.InviterUnMembre:
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Inviter un membre'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Inviter'),
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
                    )
                  : PopupMenuButton<MenuValuesMembre>(
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<MenuValuesMembre>(
                          value: MenuValuesMembre.QuitterLeGroupe,
                          child: Text('Quitter le groupe'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == MenuValuesMembre.QuitterLeGroupe) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Quitter le groupe'),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Quitter'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('Annuler'),
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
      body: SingleChildScrollView(
        child: SafeArea(
          // 1) get all users ids from the groupe members
          child: StreamBuilder<DocumentSnapshot>(
            stream: utilisateurCollection
                .doc(widget.idOwner)
                .collection('Groupes')
                .doc(widget.idGroupeOwner)
                .snapshots(),
            builder: (context, snapshot) {
              listIdUsers.clear();
              resteUsers.clear();
              listMembersWidget.clear();
              idOwner = '';
              if (snapshot.hasData && snapshot.data != null) {
                // get le proprietaire du groupe
                idOwner = snapshot.data!['idOwner'];
                // get les membres du groupe
                Map<String, dynamic> membresData =
                    snapshot.data!.data() as Map<String, dynamic>;
                if (membresData.isNotEmpty) {
                  listIdUsers = List<String>.from(membresData['membres']);
                }
                listIdUsers.add(idOwner);
                return StreamBuilder<QuerySnapshot>(
                  stream: utilisateurCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('Il n\'existe aucun membre'));
                    } else {
                      resteUsers.clear();
                      listMembersWidget.clear();
                      final allUsers = snapshot.data!.docs;
                      int i = 0 ;
                      for (var u in allUsers) {
                        if (listIdUsers.contains(u['identifiant'])) {
                          if (u.exists) {
                            Utilisateur utilisateur =
                            Utilisateur.creerUtilisateurVide();
                            utilisateur.identifiant = u['identifiant'];
                            utilisateur.nomComplet = u['nomComplet'];
                            utilisateur.email = u['email'];
                            utilisateur.numeroDeTelephone =
                            u['numeroDeTelephone'];
                            utilisateur.imageUrl = u['imageUrl'];
                            if (utilisateur.identifiant == idOwner &&
                                listIdUsers
                                    .contains(utilisateur.identifiant)) {
                              // si ce utilisateur est le owner
                              // et il faut qu'il fait partie du groupe
                              owner = Utilisateur.creerUtilisateurVide();
                              owner = utilisateur;
                            } else if (utilisateur.identifiant !=
                                idOwner &&
                                listIdUsers
                                    .contains(utilisateur.identifiant)) {
                              // si ce utilisateur est un membre
                              // et il faut qu'il fait partie du groupe
                              resteUsers.add(utilisateur);
                              listMembersWidget.add(InfoUserContainer(
                                  utilisateur.imageUrl,
                                  utilisateur.nomComplet,
                                  utilisateur.email,
                                  utilisateur.numeroDeTelephone,
                                  true,
                                  i,
                                  groupe.idGroupe)
                              );
                              i++;
                            }
                          }
                        }
                      }
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          (!widget.estProprietaire)
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(24, 8, 4, 0),
                                child: Text(
                                  'Le propriétaire',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      color: Colors.black),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InfoUserContainer(
                                  owner.imageUrl,
                                  owner.nomComplet,
                                  owner.email,
                                  owner.numeroDeTelephone,
                                  false,
                                  0,
                                  ''),
                            ],
                          )
                              : const Text(
                            textAlign: TextAlign.center,
                            'Vous êtes le propriétaire',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                color: Colors.black),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          (resteUsers.isNotEmpty)
                              ? const Padding(
                            padding: EdgeInsets.fromLTRB(24, 8, 4, 0),
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
                          )
                              : Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: const Center(
                            child: Text(
                                'Aucun membre pour le moment',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color: Colors.black),
                            ),
                          ),
                              ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: listMembersWidget,
                          ),
                        ],
                      );
                    }
                  },
                );
              } else {
                return const SizedBox(
                  width: 0,
                  height: 0,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget InfoUserContainer(
      String imageUrl,
      String nomComplet,
      String email,
      String numeroDeTelephone,
      bool ableToDelete,
      int index,
      String uidGroupe) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      width: screenWidth,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: SizedBox(
              width: screenWidth,
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: screenWidth / 7,
                        height: screenWidth / 7,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      textAlign : TextAlign.left,
                      '  $nomComplet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: SizedBox(
              width: screenWidth,
              child: Row(
                children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                      'Email :      ',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                       ),
                    ),
                  Expanded(
                    child: SelectableText(
                      textAlign: TextAlign.left,
                      email,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.indigoAccent[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: screenWidth,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(
                    width: 1.4,
                    color: Colors.indigoAccent,
                  )),
              onPressed: () {
                launchUrlString("tel:$numeroDeTelephone");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_in_talk,
                    color: Colors.indigoAccent[400],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    numeroDeTelephone,
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
                          title:
                              const Text('Voulez vous supprimer cet utilisateur ?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                await _cloudFirestore
                                    .supprimerUtilisateurAuGroupe(
                                        auth.currentUser!.uid,
                                        widget.idGroupeOwner,
                                        index);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Oui'),
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
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                    size: 28,
                  ))
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}
