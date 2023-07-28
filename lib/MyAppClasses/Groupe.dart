import 'package:places_service/places_service.dart';

class Groupe {
  String _idGroupe = '' ; // parceque Groupe est une subcollection pour Utilisateur
  PlacesAutoCompleteResult _lieuArrivee ;
  DateTime _dateDepart ;
  String _idOwner ;
  String _idGroupeOwner ;
  List<String> _membres ;
  Groupe({
    required PlacesAutoCompleteResult lieuArrivee,
    required DateTime dateDepart,
    required String idOwner,
    required String idGroupeOwner,
    List<String> membres = const [],
  })  :
        _lieuArrivee = lieuArrivee,
        _dateDepart = dateDepart,
        _idOwner = idOwner,
        _idGroupeOwner = idGroupeOwner,
        _membres = membres;

  String get idGroupe => _idGroupe;

  set idGroupe(String value) {
    _idGroupe = value;
  }

  void ajouterUnMembre(String String){
    _membres.add(String);
  }
  void supprimerUnMembre(int index){
    _membres.remove(index);
  }
  Map<String, dynamic> toMap() {
    return {
      'idGroupe': _idGroupe,
      'lieuArrivee': _lieuArrivee != null ? _convertPlaceResultToMap(_lieuArrivee) : null,
      'dateDepart' : _dateDepart,
      'idOwner': _idOwner,
      'idGroupeOwner': _idGroupeOwner,
      'membres': _membres,
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
    return Groupe(lieuArrivee: lieuArrivee, dateDepart: DateTime.now(), idOwner: '',idGroupeOwner: '');
  }

  PlacesAutoCompleteResult get lieuArrivee => _lieuArrivee;

  set lieuArrivee(PlacesAutoCompleteResult value) {
    _lieuArrivee = value;
  }

  DateTime get dateDepart => _dateDepart;

  set dateDepart(DateTime value) {
    _dateDepart = value;
  }

  String get idOwner => _idOwner;

  set idOwner(String value) {
    _idOwner = value;
  }

  String get idGroupeOwner => _idGroupeOwner;

  set idGroupeOwner(String value) {
    _idGroupeOwner = value;
  }

  List<String> get membres => _membres;

  set membres(List<String> value) {
    _membres = value;
  }
}