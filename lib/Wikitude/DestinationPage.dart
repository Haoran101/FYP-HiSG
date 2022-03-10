import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wikitude_flutter_app/DataSource/location_provider.dart';
import 'package:wikitude_flutter_app/Wikitude/arview.dart';
import 'package:wikitude_flutter_app/Wikitude/sample.dart';

class DestinationPage extends StatefulWidget {
  Sample sample;
  DestinationPage({required this.sample});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {

  late GoogleMapController mapController;

  late LatLng _center;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void initState() {
    determinePosition().then((pos) => 
    _center = LatLng(pos.latitude, pos.longitude));
    super.initState();
  }

  switchToARView() {
    //TODO: push view to request for destination
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ArViewWidget(sample: this.widget.sample)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search For Destination'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Container(
          height: 900,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
          ),
        ),
      );
  }
}