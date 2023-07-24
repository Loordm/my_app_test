import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/MyAppClasses/Invitation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../MyAppClasses/Utilisateur.dart';

class CloudFirestoreMethodes {
  final CollectionReference _utilisateurCollection = FirebaseFirestore.instance.collection('Utilisateur');
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
  Future<void> ajouterUtilisateurAuGroupe(String uidUtilisateur, String uidGroupe, Utilisateur utilisateur) async{
    DocumentReference groupeDocRef = _utilisateurCollection.doc(uidUtilisateur).collection("Groupes").doc(uidGroupe);
    Map<String, dynamic> userMap = utilisateur.toMap();
    await groupeDocRef.update({
      'membres': FieldValue.arrayUnion([userMap]),
    });
  }
  Future<void>supprimerGroupe(String uid, String idGroupe) async{
    DocumentReference groupeRef = _utilisateurCollection.doc(uid).collection('Groupes').doc(idGroupe);
    groupeRef.delete();
  }
  Future<void> supprimerUtilisateurAuGroupe(String uidUser, String uidGroupe, int index) async {
    DocumentReference groupeDocRef = _utilisateurCollection.doc(uidUser).collection('Groupes').doc(uidGroupe);
    await groupeDocRef.get().then((snapshot) {
      if (snapshot.exists) {
        List<Map<String, dynamic>> listMembres = List<Map<String, dynamic>>.from((snapshot.data() as Map<String, dynamic>)['membres']);
        if (index >= 0 && index < listMembres.length) {
          listMembres.removeAt(index);
          groupeDocRef.update({'membres': listMembres});
        } else {
          throw Exception("Index non valide");
        }
      } else {
        throw Exception("Utilisateur non existant");
      }
    });
  }
}