import 'package:app_test/MyAppClasses/Utilisateur.dart';
import 'package:app_test/MyAppPages/Connexion.dart';
import 'package:app_test/Services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Services/CloudFirestoreMethodes.dart';

class MonProfile extends StatefulWidget {
  static const String screenRoute = '/monProfile';

  const MonProfile({Key? key}) : super(key: key);

  @override
  State<MonProfile> createState() => _MonProfileState();
}

class _MonProfileState extends State<MonProfile> {
  final ImagePicker _imagePicker = ImagePicker();
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('Utilisateur');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _cloudFirestore = CloudFirestoreMethodes();
  final _contrNomComplet = TextEditingController();
  final _contrNumeroDuTelephone = TextEditingController();
  bool _changementNomComplet = false;

  bool _changementNumero = false;

  bool isLoading = false;

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
            'Mon profil',
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
        child: SingleChildScrollView(
          child: StreamBuilder(
            stream:
                utilisateurCollection.doc(auth.currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('');
              } else {
                if (snapshot.data!.exists) {
                  Utilisateur utilisateur = Utilisateur.creerUtilisateurVide();
                  utilisateur.identifiant = snapshot.data!['identifiant'];
                  utilisateur.nomComplet = snapshot.data!['nomComplet'];
                  utilisateur.email = snapshot.data!['email'];
                  utilisateur.numeroDeTelephone =
                      snapshot.data!['numeroDeTelephone'];
                  utilisateur.imageUrl = snapshot.data!['imageUrl'];
                  _contrNomComplet.text = utilisateur.nomComplet;
                  _contrNumeroDuTelephone.text = utilisateur.numeroDeTelephone;
                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Image.asset(
                            'assets/rectangle.png',
                            height: screenHeight * 0.2,
                            fit: BoxFit.fitWidth,
                          ),
                          (!isLoading)
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(
                                  utilisateur.imageUrl,
                                  fit: BoxFit.cover,
                                  width: screenWidth / 3.8,
                                  height: screenWidth / 3.8,
                                ),
                              )
                              : const CircularProgressIndicator(),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      SelectableText(
                        utilisateur.email,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Changer votre photo',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.indigoAccent[400]),
                          ),
                          IconButton(
                              onPressed: () async {
                                /// 1) get the image from gallery
                                XFile? file = await _imagePicker.pickImage(
                                    source: ImageSource.gallery);
                                setState(() {
                                  isLoading = true;
                                });
                                /// 2) upload the image in firebase storage
                                if (file == null){
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }
                                Reference referenceRoot =
                                    FirebaseStorage.instance.ref();
                                Reference referenceDirImages =
                                    referenceRoot.child('images');
                                Reference referenceImageToUpload =
                                    referenceDirImages
                                        .child(auth.currentUser!.uid);
                                try {
                                  await referenceImageToUpload
                                      .putFile(File(file.path));
                                  utilisateur.imageUrl =
                                      await referenceImageToUpload
                                          .getDownloadURL();
                                  setState(() {
                                    utilisateur.imageUrl = utilisateur.imageUrl;
                                  });
                                  await _cloudFirestore.modifierImage(
                                      auth.currentUser!.uid,
                                      utilisateur.imageUrl);
                                  setState(() {
                                    isLoading = false;
                                  });
                                } catch (error) {
                                  throw Exception(
                                      'Erreur dans le set de l\'image');
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              icon: Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.indigoAccent[400],
                              ))
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nom complet',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: Colors.black),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _contrNomComplet,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .grey), // Add color to the border here
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .grey), // Add color to the border here
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .indigoAccent), // Add color to the border here
                                  ),
                                  fillColor: Colors.white60,
                                  filled: true,
                                  hintText: 'Nom complet',
                                  hintStyle: TextStyle(fontFamily: 'poppins'),
                                ),
                                onChanged: (value) {
                                  _changementNomComplet = true;
                                },
                              ),
                              const SizedBox(
                                height: 26,
                              ),
                              const Text(
                                'Numéro du téléphone',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: Colors.black),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _contrNumeroDuTelephone,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .grey), // Add color to the border here
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .grey), // Add color to the border here
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .indigoAccent), // Add color to the border here
                                  ),
                                  fillColor: Colors.white60,
                                  filled: true,
                                  hintText: 'Numéro du télephone',
                                  hintStyle: TextStyle(fontFamily: 'Poppins'),
                                ),
                                onChanged: (value) {
                                  _changementNumero = true;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: screenWidth,
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_changementNomComplet) {
                              await _cloudFirestore.modifierNomComplet(
                                  auth.currentUser!.uid, _contrNomComplet.text);
                            }
                            if (_changementNumero) {
                              await _cloudFirestore.modifierNumeroDeTelephone(
                                  auth.currentUser!.uid,
                                  _contrNumeroDuTelephone.text);
                            }
                            if (_changementNumero || _changementNomComplet) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text('Modification avec succée')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  24), // Border radius of the button
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Valider les modifications',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: TextButton(
                          onPressed: () async {
                            await AuthService().signOut();
                            Navigator.pushNamedAndRemoveUntil(context,
                                Connexion.screenRoute, (route) => false);
                          },
                          child: const Text(
                            'Déconnexion',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                color: Colors.red),
                          ),
                        ),
                      )
                    ],
                  );
                }
                else {
                  return const SizedBox(height: 0,width: 0,);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
