import 'package:flutter/material.dart';
import 'package:places_service/places_service.dart';
class ChoixLieuArrivee extends StatefulWidget {

  @override
  State<ChoixLieuArrivee> createState() => _ChoixLieuArriveeState();
}

class _ChoixLieuArriveeState extends State<ChoixLieuArrivee> {
  final TextEditingController _departController = TextEditingController();
  String querry = "";
  bool showSuggestion = true;
  final _placesService = PlacesService();
  PlacesAutoCompleteResult? departData ;
  String? depart;
  PlacesAutoCompleteResult? lieuArrivee;
  Future<dynamic> getPredictions(String querry) async {
    List<PlacesAutoCompleteResult>? response;
    if (querry != "") {
      response = await _placesService.getAutoComplete(querry);
    }
    return response;
  }

  @override
  void initState() {
    super.initState();
    _placesService.initialize(
        apiKey: "AIzaSyC9sGlH43GL0Jer73n9ETKsxNpZqvrWn-k");
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        width: 700,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:  EdgeInsets.all(16),
                child: Column(
                  children: [
                    Form(
                      child: TextFormField(
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 14),
                        controller: _departController,
                        onChanged: (value) {
                          setState(() {
                            showSuggestion = true;
                            querry = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Lieu',
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                  ],
                ),
              ),
              Column(
                  children: [
                    Visibility(
                      visible: (_departController.text.isEmpty),
                      replacement: FutureBuilder(
                          future: getPredictions(querry),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && showSuggestion) {
                                return ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return const Divider(
                                      thickness: 1,
                                    );
                                  },
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    var data = snapshot.data[index];
                                    var prediction = data.description;
                                    return ListTile(
                                      onTap: () async{
                                        setState((){
                                          showSuggestion = false;
                                          departData = data;
                                          lieuArrivee = PlacesAutoCompleteResult(
                                            placeId: departData!.placeId,
                                            description: departData!.description,
                                            mainText: departData!.mainText,
                                            secondaryText: departData!.secondaryText
                                          );
                                          depart = prediction;
                                          _departController.value =
                                              TextEditingValue(
                                                text: depart!,
                                                selection: TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: depart!.length),
                                                ),
                                              );
                                        });
                                      },
                                      title: Text(prediction),
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: (lieuArrivee == null) ?Text(
                                          'Pas de résultat, tapez clairment votre lieu',
                                          style: TextStyle(fontFamily: 'poppins'),
                                        )
                                        : Text(''),
                                      ),
                                    ));
                              }
                            } else {
                              return const Text(
                                "Recherche...",
                                style: TextStyle(fontFamily: 'Poppins'),
                              );
                            }
                          }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                    ),
                  ]),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: (){
          if (lieuArrivee != null) {
            Navigator.pop(context,lieuArrivee);
          }else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('Vous devez entrer le lieu d\'arrivee')
              ),
            );
          }
        },
            child: Text('Ok')),
        TextButton(onPressed: () => Navigator.pop(context)
            , child: Text('Annuler'))
      ],
    );
  }
}