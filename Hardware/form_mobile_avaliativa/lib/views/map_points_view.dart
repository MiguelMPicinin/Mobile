import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/point_controller.dart';
import '../controllers/firebase_controller.dart';
import '../models/location_point.dart';
import '../models/work_point.dart';

class MapPointsView extends StatefulWidget {
  const MapPointsView({super.key});

  @override
  State<MapPointsView> createState() => _MapPointsViewState();
}

class _MapPointsViewState extends State<MapPointsView> {
  final _pointController = PointController();
  final _firebaseController = FirebaseController();
  LocationPoint? _workLocation;
  LatLng? _currentLocation;
  bool _canRegister = false;

  @override
  void initState() {
    super.initState();
    _loadWorkLocation();
    _getCurrentLocation();
  }

  Future<void> _loadWorkLocation() async {
    final user = _firebaseController.currentUser;
    if (user == null) return;
    final location = await _pointController.fetchWorkLocation(user.uid);
    setState(() {
      _workLocation = location;
    });
    _checkDistance();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _checkDistance();
  }

  void _checkDistance() {
    if (_workLocation != null && _currentLocation != null) {
      final userPoint = LocationPoint(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );
      setState(() {
        _canRegister = _pointController.isWithinAllowedDistance(_workLocation!, userPoint);
      });
    }
  }

  Future<void> _registerPoint() async {
    final user = _firebaseController.currentUser;
    if (user == null || _currentLocation == null) return;
    final point = WorkPoint(
      userId: user.uid,
      timestamp: DateTime.now(),
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      isWorking: true
    );
    await _pointController.saveWorkPoint(point);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ponto registrado!')),
    );
    setState(() {}); // Atualiza lista
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{};
    if (_workLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('work'),
        position: LatLng(_workLocation!.latitude, _workLocation!.longitude),
        infoWindow: const InfoWindow(title: 'Local de Trabalho'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }
    if (_currentLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('current'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: 'Sua Localização'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    final user = _firebaseController.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Ponto')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _workLocation != null
                    ? LatLng(_workLocation!.latitude, _workLocation!.longitude)
                    : const LatLng(-23.5505, -46.6333),
                zoom: 16,
              ),
              markers: markers,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _canRegister ? _registerPoint : null,
              child: const Text('Registrar Ponto'),
            ),
          ),
          const Divider(),
          const Text('Registros de Ponto:', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: user == null
                ? const Center(child: Text('Usuário não autenticado'))
                : StreamBuilder<List<WorkPoint>>(
                    stream: _pointController.getWorkPoints(user.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final points = snapshot.data!;
                      if (points.isEmpty) return const Text('Nenhum ponto registrado.');
                      return ListView.builder(
                        itemCount: points.length,
                        itemBuilder: (context, idx) {
                          final p = points[idx];
                          return ListTile(
                            title: Text(
                              'Data: ${p.timestamp.day}/${p.timestamp.month}/${p.timestamp.year} '
                              'Hora: ${p.timestamp.hour}:${p.timestamp.minute}',
                            ),
                            subtitle: Text('Lat: ${p.latitude}, Lng: ${p.longitude}'),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}