import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/point_controller.dart';
import '../controllers/firebase_controller.dart';
import '../models/location_point.dart';
import 'map_points_view.dart';

class MapSetWorkView extends StatefulWidget {
  const MapSetWorkView({super.key});

  @override
  State<MapSetWorkView> createState() => _MapSetWorkViewState();
}

class _MapSetWorkViewState extends State<MapSetWorkView> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final _pointController = PointController();
  final _firebaseController = FirebaseController();

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  Future<void> _saveWorkLocation() async {
    if (_selectedLocation == null) return;
    final user = _firebaseController.currentUser;
    if (user == null) return;
    await _pointController.saveWorkLocation(
      LocationPoint(latitude: _selectedLocation!.latitude, longitude: _selectedLocation!.longitude),
      user.uid,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local de trabalho salvo!')),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => const MapPointsView(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Definir Local de Trabalho')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-23.5505, -46.6333), zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onTap: _onMapTap,
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('work'),
                        position: _selectedLocation!,
                        infoWindow: const InfoWindow(title: 'Local de Trabalho'),
                      )
                    }
                  : {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selectedLocation != null ? _saveWorkLocation : null,
              child: const Text('Salvar Local de Trabalho'),
            ),
          ),
        ],
      ),
    );
  }
}