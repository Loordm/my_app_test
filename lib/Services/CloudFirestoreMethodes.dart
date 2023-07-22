import 'package:cloud_firestore/cloud_firestore.dart';
import '../MyAppClasses/Utilisateur.dart';

class CloudFirestoreMethodes {
  final CollectionReference utilisateurCollection = FirebaseFirestore.instance.collection('Utilisateur');
  Future<void> creerUtilisateur(Utilisateur utilisateur) async {
    await utilisateurCollection.doc(utilisateur.identifiant).set({
      'identifiant': utilisateur.identifiant,
      'nomComplet': utilisateur.nomComplet,
      'email': utilisateur.email,
      'numeroDeTelephone': utilisateur.numeroDeTelephone,
      'imageUrl': utilisateur.imageUrl,
      'positionActuel': GeoPoint(utilisateur.positionActuel.latitude, utilisateur.positionActuel.longitude),
      'invitations': utilisateur.invitations.map((invitation) => {
        'idEnvoyeur': invitation.idEnvoyeur,
        'idRecepteur': invitation.idRecepteur,
        'idGroupe': invitation.idGroupe,
        'acceptation': invitation.acceptation,
        'dejaTraite': invitation.dejaTraite,
      }).toList(),
    });
  }
}