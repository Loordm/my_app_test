import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/MyAppClasses/Invitation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../MyAppClasses/Utilisateur.dart';

class CloudFirestoreMethodes {
  final CollectionReference _utilisateurCollection = FirebaseFirestore.instance.collection('Utilisateur');
  final CollectionReference _testCollection = FirebaseFirestore.instance.collection('test');
  Future<void> creerTest(String text)async{
    await _testCollection.add({
      'text': text
    });
  }
  Future<void> creerUtilisateur(Utilisateur utilisateur) async {
    await _utilisateurCollection.doc(utilisateur.identifiant).set({
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
  
  Future<void> envoyerInvitation(String uidRecepteur,Invitation invitation) async{
    DocumentReference utilisateurDocRef = _utilisateurCollection.doc(uidRecepteur);
    Map<String, dynamic> invitMap = invitation.toMap();
    await utilisateurDocRef.update({
      'invitations': FieldValue.arrayUnion([invitMap]),
    });
  }
  
  Future<void> ajouterGroupe(String uid, Groupe groupe) async {
    Map<String, dynamic> groupeData = groupe.toMap();
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('Utilisateur')
        .doc(uid)
        .collection('Groupes')
        .add(groupeData);
    // sauvegarder le groupe id
    groupe.idGroupe = docRef.id;
    groupeData = groupe.toMap();
    await FirebaseFirestore.instance
        .collection('Utilisateur')
        .doc(uid)
        .collection('Groupes')
        .doc(docRef.id)
        .set(groupeData);
  }
  Future<void>annulerGroupe(String uid, String idGroupe) async{
    DocumentReference groupeRef = _utilisateurCollection.doc(uid).collection('Groupes').doc(idGroupe);
    groupeRef.delete();
  }
}