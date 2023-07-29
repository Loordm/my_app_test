import 'package:app_test/MyAppPages/Connexion.dart';
import 'package:app_test/MyAppPages/Creer%20un%20groupe.dart';
import 'package:app_test/MyAppPages/Inscription.dart';
import 'package:app_test/MyAppPages/MesGroupes.dart';
import 'package:app_test/MyAppPages/MesInvitations.dart';
import 'package:app_test/MyAppPages/MonProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyAppPages/Acceuil.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _auth = FirebaseAuth.instance ;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: UniqueKey(),
      debugShowCheckedModeBanner: false,
      initialRoute: _auth.currentUser == null ? Connexion.screenRoute : Acceuil.screenRoute,
      routes: {
        Connexion.screenRoute: (context) => Connexion(),
        Inscription.screenRoute: (context) => const Inscription(),
        Acceuil.screenRoute: (context) => const Acceuil(),
        MesGroupes.screenRoute: (context) => const MesGroupes(),
        MesInvitations.screenRoute: (context) => const MesInvitations(),
        MonProfile.screenRoute: (context) => const MonProfile(),
        CreerGroupe.screenRoute: (context) => const CreerGroupe(),
      },
    );
  }
}
