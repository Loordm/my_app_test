import 'package:flutter/material.dart';
class MesGroupes extends StatefulWidget {
  static const String screenRoute = 'mesGroupes';
  const MesGroupes({Key? key}) : super(key: key);

  @override
  State<MesGroupes> createState() => _MesGroupesState();
}

class _MesGroupesState extends State<MesGroupes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('home page'),),
    );
  }
}
