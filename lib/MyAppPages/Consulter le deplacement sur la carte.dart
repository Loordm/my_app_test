import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:app_test/Services/CloudFirestoreMethodes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../MyAppClasses/Utilisateur.dart';

class DeplacementSurLaCarte extends StatefulWidget {
  String idGroupe;
  List<String> listIdUsers;

  DeplacementSurLaCarte(this.idGroupe, this.listIdUsers);

  @override
  State<DeplacementSurLaCarte> createState() => _DeplacementSurLaCarteState();
}

class _DeplacementSurLaCarteState extends State<DeplacementSurLaCarte> {
  late HashSet<Marker> markers;
  Position? current_location;
  BitmapDescriptor locationMarker = BitmapDescriptor.defaultMarker;
  final Set<Polyline> _polylineSet = <Polyline>{};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('Utilisateur');
  List<String> listIdUsers = [];

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> setCustomMarker() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/current_location.png")
        .then((icon) => locationMarker = icon);
  }

  Future<void> addMarker() async {
    await getBytesFromAsset("assets/images/current_location.png", 120)
        .then((value) {
      if (mounted) {
        setState(() {
          markers.add(Marker(
            markerId: const MarkerId("cuurent_pos"),
            position:
                LatLng(current_location!.latitude, current_location!.longitude),
            icon: BitmapDescriptor.fromBytes(value),
          ));
        });
      }
    });
  }

  Future<void> addUserMarkers(Utilisateur utilisateur) async {
    if (utilisateur.identifiant != auth.currentUser!.uid) {
      Uint8List imageData = await getBytesFromAsset(
          utilisateur.imageUrl, 120); // Adjust the width as needed
      BitmapDescriptor userMarkerIcon = BitmapDescriptor.fromBytes(imageData);
      markers.add(Marker(
        markerId: MarkerId(utilisateur.identifiant),
        position: utilisateur.positionActuel,
        icon: userMarkerIcon,
      ));

      // Update the state to reflect the changes
      if (mounted) {
        setState(() {});
      }
    }
  }

  void setPolylines(LatLng depart, LatLng arrive) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyC9sGlH43GL0Jer73n9ETKsxNpZqvrWn-k",
        PointLatLng(depart.latitude, depart.longitude),
        PointLatLng(arrive.latitude, arrive.longitude));
    for (var element in result.points) {
      polylineCoordinates.add(LatLng(element.latitude, element.longitude));
    }
    setState(() {
      _polylineSet.add(Polyline(
          polylineId: const PolylineId("Route"),
          points: polylineCoordinates,
          color: Colors.blue));
    });
  }

  late GoogleMapController mapController;
  LatLng? currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    print('*******************************************');
    print('listId = ${widget.listIdUsers}');
    print('*******************************************');
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  StreamSubscription<Position>? positionStream;

  void _getCurrentPosition() async {
    Geolocator.requestPermission().then((permission) async {
      if (permission == LocationPermission.denied) {
        return;
      }
      positionStream = Geolocator.getPositionStream().listen((position) async {
        currentPosition = LatLng(position.latitude, position.longitude);
        setState(() {
          sauvgarderPositionActuel(position.latitude, position.longitude);
        });
      });
    });
  }

  sauvgarderPositionActuel(double lat, double lng) async {
    await CloudFirestoreMethodes()
        .modifierPositionActuel(auth.currentUser!.uid, LatLng(lat, lng));
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Scaffold(
      body: currentPosition == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  backgroundColor: Colors.indigoAccent[400],
                ),
                Text('Veuillez patienter un instant...')
              ],
            ))
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPosition!,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
      ),
    );
  }
}
