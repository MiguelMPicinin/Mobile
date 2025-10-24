import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/point_controller.dart';
import '../controllers/firebase_controller.dart';
import '../models/location_point.dart';
import 'home_view.dart';

class MapSetWorkView extends StatefulWidget {
  const MapSetWorkView({super.key});

  @override
  State<MapSetWorkView> createState() => _MapSetWorkViewState();
}

class _MapSetWorkViewState extends State<MapSetWorkView> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  final _pointController = PointController();
  final _firebaseController = FirebaseController();
  bool _loading = false;
  String? _error;
  double _zoom = 15.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Serviço de localização desabilitado. Por favor, ative o GPS.';
          _loading = false;
        });
        return;
      }

      // Verificar permissões
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
          _error = 'Permissão de localização permanentemente negada. Ative nas configurações do dispositivo.';
          _loading = false;
        });
        return;
      }

      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _loading = false;
      });

      // Mover o mapa para a localização atual
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, _zoom);
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter localização: $e';
        _loading = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _goToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _zoom);
    } else {
      _getCurrentLocation();
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom += 1;
    });
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _zoom);
    }
  }

  void _zoomOut() {
    setState(() {
      _zoom -= 1;
    });
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _zoom);
    }
  }

  Future<void> _saveWorkLocation() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um local no mapa primeiro!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = _firebaseController.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _pointController.saveWorkLocation(
        LocationPoint(
          latitude: _selectedLocation!.latitude, 
          longitude: _selectedLocation!.longitude
        ),
        user.uid,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local de trabalho salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar local: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    
    if (_selectedLocation != null) {
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: _selectedLocation!,
          child: const Icon(
            Icons.location_pin,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Definir Local de Trabalho'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
            tooltip: 'Ir para minha localização',
          ),
        ],
      ),
      body: _loading && _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Instruções
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Como definir seu local de trabalho:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. Toque no mapa para selecionar o local de trabalho\n'
                            '2. Clique em "Salvar Local de Trabalho"',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Mapa
                    Expanded(
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: _currentLocation ?? const LatLng(-23.5505, -46.6333),
                              zoom: _zoom,
                              onTap: _onMapTap,
                            ),
                            children: [
                              // Camada do OpenStreetMap
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.yourapp',
                                // Alternativas se OpenStreetMap estiver lento:
                                // urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                // subdomains: ['a', 'b', 'c'],
                              ),
                              
                              // Camada de marcadores
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
                                  heroTag: "zoom_in",
                                  child: const Icon(Icons.add),
                                ),
                                const SizedBox(height: 8),
                                FloatingActionButton.small(
                                  onPressed: _zoomOut,
                                  heroTag: "zoom_out",
                                  child: const Icon(Icons.remove),
                                ),
                              ],
                            ),
                          ),
                          
                          // Botão de localização
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              onPressed: _goToCurrentLocation,
                              mini: true,
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.my_location, color: Colors.white),
                            ),
                          ),
                          
                          // Indicador de carregamento durante o salvamento
                          if (_loading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                    
                    // Informações do local selecionado
                    if (_selectedLocation != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.green[50],
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Local selecionado: '
                                '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                                '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Botão de salvar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedLocation != null && !_loading ? _saveWorkLocation : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedLocation != null ? Colors.green : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Salvar Local de Trabalho',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}