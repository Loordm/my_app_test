import 'package:flutter/material.dart';

class InviterUnMembre extends StatefulWidget {
  const InviterUnMembre({Key? key}) : super(key: key);

  @override
  State<InviterUnMembre> createState() => _InviterUnMembreState();
}

class _InviterUnMembreState extends State<InviterUnMembre> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    return AlertDialog(
      backgroundColor: Colors.grey[300],
      title: const Text(
        'Inviter un membre',
        style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Poppins'),
      ),
      content: SizedBox(
        width: screenWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donnez l’email de votre partenaire',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black),
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.pop(context,_emailController.text);
            },
            child: Text(
              'Inviter',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigoAccent[400]),
            )
        ),
        const SizedBox(width: 10,),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(
            'Annuler',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.indigoAccent[400]),
        )
        )
      ],
    );
  }
}
