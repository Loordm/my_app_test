import 'package:flutter/material.dart';
class MonProfile extends StatefulWidget {
  static const String screenRoute = '/monProfile';
  const MonProfile({Key? key}) : super(key: key);

  @override
  State<MonProfile> createState() => _MonProfileState();
}

class _MonProfileState extends State<MonProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Mon profil',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins'
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[300],
    );
  }
}
