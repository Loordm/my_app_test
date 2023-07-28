import 'package:app_test/MyAppClasses/Groupe.dart';
import 'package:app_test/MyAppClasses/Invitation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Future<void>modifierInvitation(String uid, int index, bool accepter) async {
    int i = 0 ;
    List<Invitation> listeInvitation = [];
    await _utilisateurCollection
        .doc(uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        List<dynamic> invitationsData = snapshot.get('invitations');
          for (var invitationData in invitationsData) {
            Invitation invitation = Invitation(
              idEnvoyeur: invitationData['idEnvoyeur'],
              idRecepteur: invitationData['idRecepteur'],
              idGroupe: invitationData['idGroupe'],
              acceptation: invitationData['acceptation'],
              dejaTraite: invitationData['dejaTraite'],
            );
            if (i == index) {
              invitation.dejaTraite = true;
              invitation.acceptation = accepter;
            }
            listeInvitation.add(invitation);
            i++ ;
          }
      }
  });
    DocumentReference utilisateurDocRef = _utilisateurCollection.doc(uid);
    List<Map<String, dynamic>> invitationsMapList = listeInvitation.map((notification) => notification.toMap()).toList();
    await utilisateurDocRef.update({'invitations': invitationsMapList});
  }
  Future<void> supprimerInvitation(String uid, int index) async {
    DocumentReference utilisateurDocRef = _utilisateurCollection.doc(uid);
    await utilisateurDocRef.get().then((snapshot) {
      if (snapshot.exists) {
        List<Map<String, dynamic>> invitations = List<Map<String, dynamic>>.from((snapshot.data() as Map<String, dynamic>)['invitations']);
        if (index >= 0 && index < invitations.length) {
          invitations.removeAt(index);
          utilisateurDocRef.update({'invitations': invitations});
        } else {
          throw Exception("Invalid index for invitation deletion.");
        }
      } else {
        throw Exception("Utilisateur does not exist.");
      }
    });
  }

  Future<void> ajouterGroupe(String uid, Groupe groupe) async {
    Map<String, dynamic> groupeData = groupe.toMap();
    DocumentReference docRef = await _utilisateurCollection
        .doc(uid)
        .collection('Groupes')
        .add(groupeData);
    // sauvegarder le groupe id
    groupe.idGroupe = docRef.id;
    groupeData = groupe.toMap();
    await _utilisateurCollection
        .doc(uid)
        .collection('Groupes')
        .doc(docRef.id)
        .set(groupeData);
  }
  Future<void> ajouterUtilisateurAuGroupe(String uidUtilisateur, String uidGroupe, Utilisateur utilisateur) async{
    DocumentReference groupeDocRef = _utilisateurCollection.doc(uidUtilisateur).collection('Groupes').doc(uidGroupe);
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
  Future<void> modifierPositionActuel(String uid, LatLng positionActuel) async {
    DocumentReference utilisateurDocRef = _utilisateurCollection.doc(uid);
    final position = GeoPoint(positionActuel.latitude, positionActuel.longitude);
    await utilisateurDocRef.update({'positionActuel': position});
  }
  Future<void> modifierNomComplet(String uid, String nomComplet) async {
    DocumentReference utilisateurDocRef = _utilisateurCollection.doc(uid);
    await utilisateurDocRef.update({'nomComplet': nomComplet});
  }
  Future<void> modifierNumeroDeTelephone(String uid, String numeroDeTephone) async {
    DocumentReference utilisateurDocRef = _utilisateurCollection.doc(uid);
    await utilisateurDocRef.update({'numeroDeTelephone': numeroDeTephone});
  }
  Future<void> modifierImage(String uid, String imageUrl) async {
    DocumentReference utilisateurDocRef = _utilisateurCollection.doc(uid);
    await utilisateurDocRef.update({'imageUrl': imageUrl});
  }
}