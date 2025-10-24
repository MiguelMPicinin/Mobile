// views/history_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/point_controller.dart';
import '../controllers/firebase_controller.dart';
import '../models/work_point.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final _pointController = PointController();
  final _firebaseController = FirebaseController();
  List<WorkPoint> _points = [];
  bool _loading = true;
  String? _error;
  bool _indexError = false;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    setState(() {
      _loading = true;
      _error = null;
      _indexError = false;
    });

    final user = _firebaseController.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Usuário não autenticado';
        _loading = false;
      });
      return;
    }

    try {
      // Tenta a stream normal primeiro
      final stream = _pointController.getWorkPoints(user.uid);
      await for (final points in stream) {
        setState(() {
          _points = points;
          _loading = false;
        });
        break; // Pegamos apenas o primeiro resultado para teste
      }
    } catch (e) {
      if (e.toString().contains('index') || e.toString().contains('INDEX')) {
        setState(() {
          _indexError = true;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erro ao carregar pontos: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadPointsWithoutIndex() async {
    final user = _firebaseController.currentUser;
    if (user == null) return;

    try {
      // Consulta simples sem ordenação complexa
      final querySnapshot = await FirebaseFirestore.instance
          .collection('work_points')
          .where('userId', isEqualTo: user.uid)
          .get();

      final points = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WorkPoint.fromMap(data);
      }).toList();

      // Ordenação manual
      points.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _points = points;
        _indexError = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar pontos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pontos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPoints,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _indexError
              ? _buildIndexErrorWidget()
              : _error != null
                  ? _buildErrorWidget()
                  : _points.isEmpty
                      ? _buildEmptyWidget()
                      : _buildPointsList(),
    );
  }

  Widget _buildIndexErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, size: 64, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Índice em Criação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'O banco de dados está configurando o índice necessário.\n'
              'Isso pode levar alguns minutos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadPoints,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Tentar Novamente'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _loadPointsWithoutIndex,
                  child: const Text('Carregar Sem Ordenação'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadPoints,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhum ponto registrado',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsList() {
    return Column(
      children: [
        // Resumo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total de Registros:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${_points.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        // Lista
        Expanded(
          child: ListView.builder(
            itemCount: _points.length,
            itemBuilder: (context, index) {
              final point = _points[index];
              return _buildPointCard(point);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPointCard(WorkPoint point) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: point.isWorking ? Colors.green[50] : Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                point.isWorking ? Icons.work : Icons.exit_to_app,
                color: point.isWorking ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatDate(point.timestamp)} às ${_formatTime(point.timestamp)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Local: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    point.isWorking ? 'Entrada' : 'Saída',
                    style: TextStyle(
                      color: point.isWorking ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: point.isWorking ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}