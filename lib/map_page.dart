import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:developer';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController googleMapControoler;
  List<String> _selectedDestination = [];

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late BitmapDescriptor originIcon;
  late BitmapDescriptor destinationIcon;

  @override
  void initState() {
    setMarkerForDestinationAndOrigin();
    super.initState();
  }

  @override
  void dispose() {
    googleMapControoler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [_buildGoogleMap(), _buildBody()],
      ),
    );
  }

  final CameraPosition _kGooglePlex = const CameraPosition(
    bearing: 30,
    target: LatLng(-8.504769316012759, 115.26234855907279),
    zoom: 12,
  );

  void setMarkerForDestinationAndOrigin() async {
    originIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/ic_marker.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/ic_marker.png');
  }

  Widget _buildGoogleMap() {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 600,
        child: GoogleMap(
          markers: _markers,
          polylines: _polylines,
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (controller) {
            googleMapControoler = controller;
            _controller.complete(controller);
          },
        ),
      ),
    );
  }



  void _onReorder(int oldIndex, int newIndex) {
    log("oldIndex" + oldIndex.toString());
    log("newIndex" + newIndex.toString());
    setState(() {
      String row = _selectedDestination.removeAt(oldIndex);
      _selectedDestination.insert(newIndex, row);
    });
  }

  Widget _buildBody() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height - 500,
        decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  spreadRadius: 1.0, blurRadius: 0.5, color: Colors.black26)
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white),
        child: ReorderableColumn(
          onNoReorder: (index){
              print(index);
          },
          onReorderStarted: (index){
            print(index);
          },
          footer: IconButton(
            onPressed: () {
              setState(() {
                _selectedDestination.add("Mau pergi kemana ?");
              });
            },
            icon: const Icon(Icons.add),
          ),
          crossAxisAlignment: CrossAxisAlignment.start,
          draggingWidgetOpacity: 0.0,
          children: List.generate(_selectedDestination.length, (index) {
            return ListTile(
              leading: index == 0
                  ? const Icon(Icons.circle)
                  : index == _selectedDestination.length - 1
                      ? const Icon(Icons.location_on)
                      : const Icon(Icons.more_vert_outlined),
              key: ValueKey(index),
              title: Text(_selectedDestination[index]),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedDestination.removeAt(index);
                  });
                },
              ),
            );
          }),
          onReorder: _onReorder,
        ),
      ),
    );
  }
}
