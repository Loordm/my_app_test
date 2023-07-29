import 'package:app_test/MyAppPages/MesInvitations.dart';
import 'package:app_test/MyAppPages/MonProfile.dart';
import 'package:flutter/material.dart';

import 'MesGroupes.dart';
class Acceuil extends StatefulWidget {
  static const String screenRoute = '/acceuil';
  const Acceuil({Key? key}) : super(key: key);
  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  int _selectedIndex = 0 ;
  List<Widget> listWidgets = <Widget>[
    const MesGroupes(),
    const MesInvitations(),
    const MonProfile()
  ];
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() {
          _selectedIndex = index ;
        }),
        height: screenHeight/13.2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Mes groupes',
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Invitations',
            selectedIcon: Icon(Icons.groups_sharp),
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profil',
            selectedIcon: Icon(Icons.account_circle),
          ),
        ],
      ),
      body: listWidgets[_selectedIndex],
    );
  }
}
