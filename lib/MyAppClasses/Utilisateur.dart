import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Groupe.dart';
import 'Invitation.dart';

class Utilisateur{
  String _identifiant ;
  String _nomComplet ;
  String _email ;
  String _numeroDeTelephone ;
  String _imageUrl = 'https://imgv3.fotor.com/images/blog-richtext-image/10-profile-picture-ideas-to-make-you-stand-out.jpg' ;
  LatLng _positionActuel ;
  List<Groupe> _groupes ;
  List<Invitation> _invitations ;
  Utilisateur({
    required String identifiant,
    required String nomComplet,
    required String email,
    required String numeroDeTelephone,
    required String imageUrl,
    required LatLng positionActuel,
    List<Groupe> groupes = const [],
    List<Invitation> invitations = const [],
  })  : _identifiant = identifiant,
        _nomComplet = nomComplet,
        _email = email,
        _numeroDeTelephone = numeroDeTelephone,
        _imageUrl = imageUrl,
        _positionActuel = positionActuel,
        _groupes = groupes,
        _invitations = invitations;
  String get identifiant => _identifiant;
  set identifiant(String value) {_identifiant = value;}
  String get numeroDeTelephone => _numeroDeTelephone;
  set numeroDeTelephone(String value) {_numeroDeTelephone = value;}
  String get nomComplet => _nomComplet;
  set nomComplet(String value) {_nomComplet = value;}
  String get imageUrl => _imageUrl;
  set imageUrl(String value) {_imageUrl = value;}
  String get email => _email;
  set email(String value) {_email = value;}
  LatLng get positionActuel => _positionActuel;
  set positionActuel(LatLng value) {_positionActuel = value;}
  List<Groupe> get groupes => _groupes;
  set groupes(List<Groupe> value) {_groupes = value;}
  List<Invitation> get invitations => _invitations;
  set invitations(List<Invitation> value) {
    _invitations = value;
  }
  void ajouterGroupe(Groupe groupe){
    _groupes.add(groupe);
  }
  void supprimerGroupe(int index){
    _groupes.remove(index);
  }
  void ajouterUtilisateurAuGroupe(int indexGroupe, Utilisateur utilisateur){
    _groupes[indexGroupe].ajouterUnMembre(utilisateur);
  }
  void supprimerUtilisateurDuGroupe(int indexGroupe, int indexUtilisateur){
    _groupes[indexGroupe].supprimerUnMembre(indexUtilisateur);
  }
  void ajouterInvitation(Invitation invitation){
    _invitations.add(invitation);
  }
  static Utilisateur creerUtilisateurVide(){
    return Utilisateur(identifiant: '',nomComplet: '',email: '',numeroDeTelephone: '',imageUrl: 'https://imgv3.fotor.com/images/blog-richtext-image/10-profile-picture-ideas-to-make-you-stand-out.jpg',positionActuel: LatLng(0,0),groupes: [],invitations: []);
  }
  Map<String, dynamic> toMap() {
    return {
      'identifiant': _identifiant,
      'nomComplet': _nomComplet,
      'email': _email,
      'numeroDeTelephone': _numeroDeTelephone,
      'imageUrl': _imageUrl,
      'positionActuel': GeoPoint(_positionActuel.latitude, _positionActuel.longitude),
    };
  }
}