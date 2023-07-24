import 'package:flutter/material.dart';
class MesInvitations extends StatefulWidget {
  static const String screenRoute = '/mesInvitations';

  const MesInvitations({Key? key}) : super(key: key);

  @override
  State<MesInvitations> createState() => _MesInvitationsState();
}

class _MesInvitationsState extends State<MesInvitations> {
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
            'Mes Invitations',
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
