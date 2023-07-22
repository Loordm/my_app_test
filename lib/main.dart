import 'package:app_test/MyAppPages/Connexion.dart';
import 'package:app_test/MyAppPages/Inscription.dart';
import 'package:app_test/MyAppPages/MesGroupes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Connexion.screenRoute,
      routes: {
        Connexion.screenRoute: (context) => Connexion(),
        Inscription.screenRoute: (context) => Inscription(),
        MesGroupes.screenRoute: (context) => MesGroupes(),
      },
    );
  }
}
