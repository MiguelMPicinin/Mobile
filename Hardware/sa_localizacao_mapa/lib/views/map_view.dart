import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sa_localizacao_mapa/controllers/map_controller.dart';
import 'package:sa_localizacao_mapa/models/location_point.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  //atributos
  List<LocationPoint> pontos = [];
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OpenStreetView com pontos"),),
      body: ValueListenableBuilder(
        valueListenable: , 
        builder: Column(
          children: [
            Expanded(
              child: FlutterMap)
          ],
        )),
    );
  }
}
