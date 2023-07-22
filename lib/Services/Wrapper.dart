import 'package:app_test/MyAppClasses/UserToAuthentificate.dart';
import 'package:app_test/MyAppPages/Connexion.dart';
import 'package:app_test/MyAppPages/MesGroupes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserToAuthentificate?>(context);
    if (user == null || !FirebaseAuth.instance.currentUser!.emailVerified) {
      return Connexion();
    } else {
      return MesGroupes();
    }
  }
}
