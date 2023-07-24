import 'package:app_test/MyAppClasses/Utilisateur.dart';
import 'package:places_service/places_service.dart';

class Groupe {
  String _idGroupe = '' ; // parceque Groupe est une subcollection pour Utilisateur
  PlacesAutoCompleteResult _lieuArrivee ;
  DateTime _dateDepart ;
  Utilisateur _owner ;
  List<Utilisateur> _membres ;
  Groupe({
    required PlacesAutoCompleteResult lieuArrivee,
    required DateTime dateDepart,
    required Utilisateur owner,
    List<Utilisateur> membres = const [],
  })  :
        _lieuArrivee = lieuArrivee,
        _dateDepart = dateDepart,
        _owner = owner,
        _membres = membres;
  DateTime get dateDepart => _dateDepart;
  set dateDepart(DateTime value) {_dateDepart = value;}
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
  Map<String, dynamic> toMap() {
    return {
      'idGroupe': _idGroupe,
      'lieuArrivee': _lieuArrivee != null ? _convertPlaceResultToMap(_lieuArrivee) : null,
      'dateDepart' : _dateDepart,
      'owner': _owner.toMap(),
      'membres': _membres.map((membre) => membre.toMap()).toList(),
    };
  }
  Map<String, dynamic> _convertPlaceResultToMap(PlacesAutoCompleteResult place) {
    return {
      'placeId': place.placeId,
      'description': place.description,
      'secondaryText': place.secondaryText,
      'mainText': place.mainText,
    };
  }
  static Groupe creerGroupeVide(){
    PlacesAutoCompleteResult lieuArrivee = PlacesAutoCompleteResult(
      placeId: '',
      description: '',
      mainText: '',
      secondaryText: '',
    );
    return Groupe(lieuArrivee: lieuArrivee, dateDepart: DateTime.now(), owner: Utilisateur.creerUtilisateurVide());
  }
}