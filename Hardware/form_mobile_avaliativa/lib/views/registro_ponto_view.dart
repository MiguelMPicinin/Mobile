// views/register_point_view.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/point_controller.dart';
import '../controllers/firebase_controller.dart';
import '../models/location_point.dart';
import '../models/work_point.dart';

class RegisterPointView extends StatefulWidget {
  final LocationPoint workLocation;
  
  const RegisterPointView({super.key, required this.workLocation});

  @override
  State<RegisterPointView> createState() => _RegisterPointViewState();
}

class _RegisterPointViewState extends State<RegisterPointView> {
  final _pointController = PointController();
  final _firebaseController = FirebaseController();
  LocationPoint? _currentLocation;
  bool _loading = true;
  bool _canRegister = false;
  double _distance = 0;
  String? _error;
  bool _isNextEntry = true; // Controla se o próximo ponto é entrada ou saída

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkNextPointType();
  }

  Future<void> _checkNextPointType() async {
    final user = _firebaseController.currentUser;
    if (user == null) return;

    try {
      // Buscar o último ponto do usuário para determinar o próximo tipo
      final pointsStream = _pointController.getWorkPoints(user.uid);
      final pointsList = await pointsStream.first;
      
      if (pointsList.isEmpty) {
        // Se não há pontos, o próximo é entrada
        setState(() {
          _isNextEntry = true;
        });
      } else {
        // Verificar o último ponto registrado
        final lastPoint = pointsList.first;
        setState(() {
          _isNextEntry = !lastPoint.isWorking; // Alterna entre entrada e saída
        });
      }
    } catch (e) {
      // Em caso de erro, assume que o próximo é entrada
      setState(() {
        _isNextEntry = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
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
      
      final currentLocation = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Calcular distância
      final distance = _pointController.calculateDistance(
        widget.workLocation.latitude,
        widget.workLocation.longitude,
        currentLocation.latitude,
        currentLocation.longitude,
      );

      setState(() {
        _currentLocation = currentLocation;
        _distance = distance;
        _canRegister = distance <= 100;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter localização: $e';
        _loading = false;
      });
    }
  }

  Future<void> _registerPointWithPassword() async {
    await _registerPoint();
  }

  Future<void> _registerPointWithBiometrics() async {
    final authenticated = await _firebaseController.authenticateWithBiometrics();
    if (authenticated) {
      await _registerPoint();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autenticação biométrica falhou'),
          backgroundColor: Colors.red,
        ),
      );
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
        isWorking: _isNextEntry, // Usa a variável que controla entrada/saída
      );
      
      await _pointController.saveWorkPoint(point);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_isNextEntry ? 'Entrada' : 'Saída'} registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Voltar para home após sucesso
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Ponto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _loading
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
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status da localização
                      Card(
                        color: _canRegister ? Colors.green[50] : Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                _canRegister ? Icons.check_circle : Icons.warning,
                                color: _canRegister ? Colors.green : Colors.orange,
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _canRegister 
                                          ? 'Dentro da Área Permitida'
                                          : 'Fora da Área Permitida',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _canRegister ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Distância: ${_distance.toStringAsFixed(1)}m '
                                      '${_canRegister ? '≤' : '>'} 100m',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Indicador do tipo de ponto
                      Card(
                        color: _isNextEntry ? Colors.blue[50] : Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isNextEntry ? Icons.login : Icons.logout,
                                color: _isNextEntry ? Colors.blue : Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isNextEntry ? 'Próximo: ENTRADA' : 'Próximo: SAÍDA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _isNextEntry ? Colors.blue : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Informações de localização
                      const Text(
                        'Informações de Localização:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildLocationInfo(
                        'Local de Trabalho:',
                        '${widget.workLocation.latitude.toStringAsFixed(6)}, '
                        '${widget.workLocation.longitude.toStringAsFixed(6)}',
                        Icons.work,
                      ),

                      _buildLocationInfo(
                        'Sua Localização:',
                        _currentLocation != null
                            ? '${_currentLocation!.latitude.toStringAsFixed(6)}, '
                              '${_currentLocation!.longitude.toStringAsFixed(6)}'
                            : 'Não disponível',
                        Icons.my_location,
                      ),

                      const Spacer(),

                      // Botões de ação
                      if (_canRegister) ...[
                        const Text(
                          'Escolha como registrar:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _registerPointWithPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isNextEntry ? Colors.blue : Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: Icon(_isNextEntry ? Icons.login : Icons.logout),
                            label: Text(
                              _isNextEntry ? 'Registrar Entrada' : 'Registrar Saída',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _registerPointWithBiometrics,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isNextEntry ? Colors.green : Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.fingerprint),
                            label: Text(
                              _isNextEntry ? 'Entrada com Biometria' : 'Saída com Biometria',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _getCurrentLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Atualizar Localização',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),
                      
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Voltar'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLocationInfo(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}