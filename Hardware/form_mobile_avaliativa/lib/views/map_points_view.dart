// views/map_points_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  final MapController _mapController = MapController();
  final _pointController = PointController();
  final _firebaseController = FirebaseController();
  LocationPoint? _workLocation;
  LatLng? _currentLocation;
  bool _canRegister = false;
  bool _loading = true;
  String? _error;
  double _zoom = 16.0;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Verificar permissões de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permissão de localização negada';
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Permissão de localização permanentemente negada. Ative nas configurações.';
          _loading = false;
        });
        return;
      }

      await _loadWorkLocation();
      await _getCurrentLocation();
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar localização: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadWorkLocation() async {
    final user = _firebaseController.currentUser;
    if (user == null) return;
    
    final location = await _pointController.fetchWorkLocation(user.uid);
    setState(() {
      _workLocation = location;
    });
    
    // Mover o mapa para o local de trabalho se existir (agendado após o frame para garantir que o controller esteja pronto)
    if (location != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(
            LatLng(location.latitude, location.longitude),
            _zoom,
          );
        } catch (_) {
          // Se o controller ainda não estiver pronto, ignorar o movimento
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
      _checkDistance();
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter localização atual: $e';
        _loading = false;
      });
    }
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

    setState(() {
      _loading = true;
    });

    try {
      final point = WorkPoint(
        userId: user.uid,
        timestamp: DateTime.now(),
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        isWorking: true,
      );
      await _pointController.saveWorkPoint(point);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ponto registrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar ponto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _getCurrentLocation();
    _checkDistance();
  }

  void _zoomIn() {
    setState(() {
      _zoom += 1;
    });
    if (_workLocation != null) {
      _mapController.move(
        LatLng(_workLocation!.latitude, _workLocation!.longitude),
        _zoom,
      );
    }
  }

  void _zoomOut() {
    setState(() {
      _zoom -= 1;
    });
    if (_workLocation != null) {
      _mapController.move(
        LatLng(_workLocation!.latitude, _workLocation!.longitude),
        _zoom,
      );
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    
    if (_workLocation != null) {
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(_workLocation!.latitude, _workLocation!.longitude),
          child: const Icon(
            Icons.work,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }
    
    if (_currentLocation != null) {
      markers.add(
        Marker(
          width: 30.0,
          height: 30.0,
          point: _currentLocation!,
          child: const Icon(
            Icons.my_location,
            color: Colors.green,
            size: 30,
          ),
        ),
      );
    }
    
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Ponto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _firebaseController.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: _workLocation != null
                                  ? LatLng(_workLocation!.latitude, _workLocation!.longitude)
                                  : const LatLng(-23.5505, -46.6333),
                              zoom: _zoom,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.form_mobile_avaliativa',
                              ),
                              MarkerLayer(
                                markers: _buildMarkers(),
                              ),
                            ],
                          ),
                          // Controles de zoom
                          Positioned(
                            right: 16,
                            top: 16,
                            child: Column(
                              children: [
                                FloatingActionButton.small(
                                  onPressed: _zoomIn,
                                  heroTag: "zoom_in_1",
                                  child: const Icon(Icons.add),
                                ),
                                const SizedBox(height: 8),
                                FloatingActionButton.small(
                                  onPressed: _zoomOut,
                                  heroTag: "zoom_out_1",
                                  child: const Icon(Icons.remove),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (!_canRegister) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _workLocation == null
                                          ? 'Local de trabalho não definido. Defina o local primeiro.'
                                          : 'Você precisa estar a até 100m do local de trabalho para registrar ponto.',
                                      style: const TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          ElevatedButton(
                            onPressed: _canRegister ? _registerPoint : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canRegister ? Colors.green : Colors.grey,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Registrar Ponto'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Histórico de Pontos:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: user == null
                          ? const Center(child: Text('Usuário não autenticado'))
                          : StreamBuilder<List<WorkPoint>>(
                              stream: _pointController.getWorkPoints(user.uid),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(child: Text('Erro: ${snapshot.error}'));
                                }
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final points = snapshot.data!;
                                if (points.isEmpty) {
                                  return const Center(child: Text('Nenhum ponto registrado.'));
                                }
                                return ListView.builder(
                                  itemCount: points.length,
                                  itemBuilder: (context, idx) {
                                    final p = points[idx];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      child: ListTile(
                                        leading: const Icon(Icons.work, color: Colors.blue),
                                        title: Text(
                                          '${p.timestamp.day}/${p.timestamp.month}/${p.timestamp.year} '
                                          '${p.timestamp.hour.toString().padLeft(2, '0')}:${p.timestamp.minute.toString().padLeft(2, '0')}',
                                        ),
                                        subtitle: Text('Lat: ${p.latitude.toStringAsFixed(4)}, Lng: ${p.longitude.toStringAsFixed(4)}'),
                                        trailing: Icon(
                                          Icons.check_circle,
                                          color: p.isWorking ? Colors.green : Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}