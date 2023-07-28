import 'package:app_test/MyAppClasses/Utilisateur.dart';
import 'package:app_test/MyAppPages/Connexion.dart';
import 'package:app_test/Services/CloudFirestoreMethodes.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Services/auth.dart';
import 'Acceuil.dart';
import 'Loading.dart';
class Inscription extends StatefulWidget {
  static const String screenRoute = '/inscription' ;
  const Inscription({Key? key}) : super(key: key);

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  bool _isObscured = false ;
  final AuthService _auth = AuthService();
  final CloudFirestoreMethodes _cfm = CloudFirestoreMethodes();
  final _nomCompletController = TextEditingController();
  final _numeroDeTelephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: screenWidth,
                padding: padding,
                child: Image.asset(
                  'assets/shapetest.png',
                  fit: BoxFit.cover,
                  height: screenHeight*0.2,
                ),
              ),
              const Text(
                'Inscription',
                style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomCompletController,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.black,
                          size: 20,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                        ),
                        labelText: 'Nom complet',
                        labelStyle: TextStyle(
                          fontSize: screenWidth/28
                        ),
                        hintText:
                        'Entrez votre nom complet',
                        hintStyle: TextStyle(
                            color: Colors.grey[700], fontSize: screenWidth/28),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    SizedBox(height: screenHeight*0.04),
                    TextFormField(
                      controller: _numeroDeTelephoneController,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                        ),
                        labelText: 'Numéro de téléphone',
                        labelStyle: TextStyle(
                            fontSize: screenWidth/28
                        ),
                        hintText:
                        'Entrez votre numéro de téléphone',
                        hintStyle: TextStyle(
                            color: Colors.grey[700], fontSize: screenWidth/28),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    SizedBox(height: screenHeight*0.04),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            fontSize: screenWidth/28
                        ),
                        hintText:
                        'Entrez votre email',
                        hintStyle: TextStyle(
                            color: Colors.grey[700], fontSize: screenWidth/28),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    SizedBox(height: screenHeight*0.04),
                    TextFormField(
                      controller: _motDePasseController,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !_isObscured,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.black,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: _isObscured
                              ? const Icon(Icons.visibility_outlined,
                            color: Colors.black,
                          )
                              : const Icon(
                            Icons.visibility_off_outlined,
                            color: Colors.black,),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                        ),
                        labelText: 'Mot de passe',
                        labelStyle: TextStyle(
                            fontSize: screenWidth/28
                        ),
                        hintText:
                        'Entrez votre mot de passe',
                        hintStyle: TextStyle(
                            color: Colors.grey[700], fontSize: screenWidth/28),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    SizedBox(height: screenHeight*0.04),
                    SizedBox(
                      width: screenWidth,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Loading()),
                          );
                          Utilisateur utilisateur = Utilisateur(
                              identifiant: '',
                              nomComplet: _nomCompletController.text,
                              email: _emailController.text,
                              numeroDeTelephone: _numeroDeTelephoneController.text,
                              imageUrl: 'https://imgv3.fotor.com/images/blog-richtext-image/10-profile-picture-ideas-to-make-you-stand-out.jpg',
                              positionActuel: const LatLng(0,0)
                          );
                          dynamic result = await _auth.signUp(
                              _emailController.text,
                              _motDePasseController.text,
                              utilisateur);
                          if (result == null) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cette adresse email est déja utilisé ou cette email est fausse'),
                              ),
                            );
                          } else {
                            utilisateur.identifiant = result!.uid ;
                            await _cfm.creerUtilisateur(utilisateur);
                            Navigator.pushNamedAndRemoveUntil(context, Acceuil.screenRoute, (route) => false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Inscription avec réussite')
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24), // Border radius of the button
                          ),
                        ),
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth/20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: (){Navigator.pushReplacementNamed(context, Connexion.screenRoute);},
                  child: const Text.rich(
                    TextSpan(
                      text: 'Vous avez déjà un compte? ',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13.0,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Connectez-vous',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 13.0,
                            fontFamily: 'Poppins',
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),

                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
