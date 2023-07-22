class Invitation {
  String _idEnvoyeur ;
  String _idRecepteur ;
  String _idGroupe ;
  bool _acceptation ; // si true alors il a accepter l'invitation, sinon il a refuser
  bool _dejaTraite ; // si true alors on remplace les boutons accepte ou refuse par un container qui a le statut
                    // accepter ou refuse
  Invitation({
    required String idEnvoyeur,
    required String idRecepteur,
    required String idGroupe,
    required bool acceptation,
    required bool dejaTraite,
  })  : _idEnvoyeur = idEnvoyeur,
        _idRecepteur = idRecepteur,
        _idGroupe = idGroupe,
        _acceptation = acceptation,
        _dejaTraite = dejaTraite;
  bool get dejaTraite => _dejaTraite;
  set dejaTraite(bool value) {
    _dejaTraite = value;
  }
  bool get acceptation => _acceptation;
  set acceptation(bool value) {
    _acceptation = value;
  }
  String get idGroupe => _idGroupe;
  set idGroupe(String value) {
    _idGroupe = value;
  }
  String get idRecepteur => _idRecepteur;
  set idRecepteur(String value) {
    _idRecepteur = value;
  }
  String get idEnvoyeur => _idEnvoyeur;
  set idEnvoyeur(String value) {
    _idEnvoyeur = value;
  }
}