import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/MyAppClasses/Invitation.dart';
import 'package:app_test/MyAppPages/Dialog%20Inviter%20un%20membre.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:places_service/places_service.dart';

import '../Services/CloudFirestoreMethodes.dart';
import 'Choix du lieu darrivee.dart';

class CreerGroupe extends StatefulWidget {
  static const screenRoute = '/creerGroupe';

  const CreerGroupe({Key? key}) : super(key: key);

  @override
  State<CreerGroupe> createState() => _CreerGroupeState();
}

class _CreerGroupeState extends State<CreerGroupe> {
  final _lieuArriveeController = TextEditingController();
  PlacesAutoCompleteResult? lieuArrivee;
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('Utilisateur');
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;
  DateTime dateDepart = DateTime.now();
  DateTime? _selectedDate;
  int indexEmail = 0;
  List<String> emailListString = [];
  List<Widget> emailListWidget = [];
  final _cloudFirestore = CloudFirestoreMethodes();

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

  /// -------------------------------------------------------------------------------------------------

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
              'Créer un groupe',
              style: TextStyle(
                  fontSize: 24,
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
            IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.transparent,
                  size: screenWidth / 10,
                ),
                onPressed: null),
          ],
        ),
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Donnez le lieu d\'arrivée',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black),
                ),
                TextFormField(
                  controller: _lieuArriveeController,
                  readOnly: true,
                  onTap: () async {
                    lieuArrivee = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return ChoixLieuArrivee(modifier_ou_creer: false,idGroupe: '');
                      },
                    );
                    if (lieuArrivee != null) {
                      _lieuArriveeController.text = lieuArrivee!.description!;
                    } else {
                      _lieuArriveeController.text = '';
                    }
                  },
                  decoration: const InputDecoration(
                      hintText: 'Lieu d\'arrivée',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                      )),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Donnez la date de départ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
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
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'Inviter des membres',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      IconButton(
                          onPressed: () async {
                            final emailValue = await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return const InviterUnMembre();
                              },
                            );
                            if (emailValue != null && emailValue.isNotEmpty) {
                              setState(() {
                                emailListWidget.add(EmailWidget(emailValue));
                                emailListWidget.add(const SizedBox(
                                  height: 20,
                                ));
                                emailListString.add(emailValue);
                                emailListString.add('');
                              });
                            }
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.indigoAccent[400],
                            size: 30,
                          ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: emailListWidget,
                ),
                SizedBox(
                  height: screenHeight / 10,
                ),
              ],
            ),
          ),
        )),
        floatingActionButton: SizedBox(
          width: screenWidth / 2,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              if (lieuArrivee != null && lieuArrivee!.description!.isNotEmpty){
                setState(() {
                  isLoading = true;
                });
                Groupe groupe = Groupe(
                    lieuArrivee: lieuArrivee!,
                    dateDepart: dateDepart,
                    idOwner: auth.currentUser!.uid,
                    idGroupeOwner: '');
                await _cloudFirestore.ajouterGroupe(
                    FirebaseAuth.instance.currentUser!.uid, groupe, '');
                // envoier les invitations
                for (String emailValue in emailListString) {
                  if (emailValue.isNotEmpty) {
                    QuerySnapshot querySnapshot = await utilisateurCollection
                        .where('email', isEqualTo: emailValue)
                        .get();
                    // email est unique, donc elle retourne un seul utilisateur
                    if (querySnapshot.docs.isNotEmpty) {
                      for (QueryDocumentSnapshot utilisateurDoc
                          in querySnapshot.docs) {
                        Map<String, dynamic> dataUtilisateur =
                            utilisateurDoc.data() as Map<String, dynamic>;
                        if (dataUtilisateur.isNotEmpty) {
                          Invitation invitation = Invitation(
                              idEnvoyeur: auth.currentUser!.uid,
                              idRecepteur: dataUtilisateur['identifiant'],
                              idGroupe: groupe.idGroupe,
                              acceptation: false,
                              dejaTraite: false);
                          await _cloudFirestore.envoyerInvitation(
                              invitation.idRecepteur, invitation);
                        }
                      }
                    } // fin si il ya une resultat de recherche
                  } // fin si email est non vide
                }
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Création du groupe avec succée')));
                Navigator.pop(context);
              }else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Vous devez donner le lieu d\'arrivée pour pouvoir créer un groupe')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigoAccent[400],
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(24), // Border radius of the button
              ),
            ),
            child: (!isLoading)
                ? const Text(
                    'Créer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                    ),
                  )
                : const CircularProgressIndicator(
                    color: Colors.white,
                  ),
          ),
        ));
  }

  Widget EmailWidget(String email) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black38,
          ),
          borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              email,
              style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 16, color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            IconButton(
                onPressed: () {
                  int index = 0;
                  for (String emailValue in emailListString) {
                    if (emailValue == email) break;
                    index++;
                  }
                  setState(() {
                    emailListWidget.removeAt(index);
                    emailListWidget.removeAt(index);
                    emailListString.removeAt(index);
                    emailListString.removeAt(index);
                  });
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 30,
                ))
          ],
        ),
      ),
    );
  }
}
