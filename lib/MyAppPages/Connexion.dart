import 'package:app_test/MyAppPages/Inscription.dart';
import 'package:flutter/material.dart';

import '../Services/auth.dart';
import 'Loading.dart';
import 'MesGroupes.dart';
class Connexion extends StatefulWidget {
  static const String screenRoute = 'connexion' ;
  Connexion({Key? key}) : super(key: key);
  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  bool _isObscured = false ;
  final AuthService _auth = AuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _motDePasseController = TextEditingController();
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
            Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold
                ),
            ),
            SizedBox(height: screenHeight*0.1,),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(fontFamily: 'Poppins'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                      ),
                      labelText: 'Email',
                      hintText:
                      'Entrez votre email',
                      hintStyle: TextStyle(
                          color: Colors.grey[700], fontSize: 14),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: screenHeight*0.04),
                  TextFormField(
                    controller: _motDePasseController,
                    style: TextStyle(fontFamily: 'Poppins'),
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
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                      ),
                      labelText: 'Mot de passe',
                      hintText:
                      'Entrez votre mot de passe',
                      hintStyle: TextStyle(
                          color: Colors.grey[700], fontSize: 14),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: screenHeight*0.04),
                  Container(
                    width: screenWidth,
                    height: 56,
                    child: ElevatedButton(
                        onPressed: ()async{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Loading()),
                          );
                          dynamic result = await _auth.signIn(
                              _emailController.text,
                              _motDePasseController.text);
                          if (result == null) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez vérifier vos données'),
                              ),
                            );
                          }else {
                            Navigator.pushNamedAndRemoveUntil(context, MesGroupes.screenRoute, (route) => false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text('Connexion avec réussite')
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Connecter',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                          ),
                        ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24), // Border radius of the button
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight*0.04),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                      onPressed: (){Navigator.pushReplacementNamed(context, Inscription.screenRoute);},
                      child: Text.rich(
                        TextSpan(
                          text: 'Vous n\'avez encore un compte? ',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 13.0,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Inscrivez-Vous',
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
          ],
        )
      ),
    );
  }
}
