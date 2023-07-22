import 'package:app_test/MyAppClasses/Utilisateur.dart';
import 'package:places_service/places_service.dart';

class Groupe {
  String _idGroupe ; // parceque Groupe est une subcollection pour Utilisateur
  PlacesAutoCompleteResult _lieuArrivee ;
  DateTime _dateTimeDepart ;
  Utilisateur _owner ;
  List<Utilisateur> _membres ;
  Groupe({
    required String idGroupe,
    required PlacesAutoCompleteResult lieuArrivee,
    required DateTime dateTimeDepart,
    required Utilisateur owner,
    List<Utilisateur> membres = const [],
  })  : _idGroupe = idGroupe,
        _lieuArrivee = lieuArrivee,
        _dateTimeDepart = dateTimeDepart,
        _owner = owner,
        _membres = membres;
  DateTime get dateTimeDepart => _dateTimeDepart;
  set dateTimeDepart(DateTime value) {_dateTimeDepart = value;}
  List<Utilisateur> get membres => _membres;
  set membres(List<Utilisateur> value) {_membres = value;}
  Utilisateur get owner => _owner;
  set owner(Utilisateur value) {_owner = value;}
  String get idGroupe => _idGroupe;
  set idGroupe(String value) {_idGroupe = value;}
  PlacesAutoCompleteResult get lieuArrivee => _lieuArrivee;
  set lieuArrivee(PlacesAutoCompleteResult value) {_lieuArrivee = value;}
  void ajouterUnMembre(Utilisateur utilisateur){
    _membres.add(utilisateur);
  }
  void supprimerUnMembre(int index){
    _membres.remove(index);
  }
}