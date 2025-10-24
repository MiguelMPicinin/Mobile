// views/home_view.dart
import 'package:flutter/material.dart';
import 'package:form_mobile_avaliativa/controllers/firebase_controller.dart';
import 'package:form_mobile_avaliativa/controllers/point_controller.dart';
import 'package:form_mobile_avaliativa/models/location_point.dart';
import 'package:form_mobile_avaliativa/views/historico_view.dart';
import 'package:form_mobile_avaliativa/views/map_set_work_view.dart';
import 'package:form_mobile_avaliativa/views/registro_ponto_view.dart';
import 'package:form_mobile_avaliativa/views/historico_view.dart';
import 'package:form_mobile_avaliativa/views/registro_ponto_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _firebaseController = FirebaseController();
  final _pointController = PointController();
  LocationPoint? _workLocation;
  bool _loading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _loading = true;
    });

    final user = _firebaseController.currentUser;
    if (user != null) {
      // Extrair nome do email (parte antes do @)
      _userName = user.email?.split('@').first ?? 'Usuário';
      
      // Carregar local de trabalho
      _workLocation = await _pointController.fetchWorkLocation(user.uid);
    }

    setState(() {
      _loading = false;
    });
  }

  void _navigateToSetWorkLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapSetWorkView()),
    ).then((_) {
      // Recarregar dados quando voltar
      _loadUserData();
    });
  }

  void _navigateToRegisterPoint() {
  if (_workLocation == null) {
    _showWorkLocationRequiredDialog();
    return;
  }
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RegisterPointView(workLocation: _workLocation!),
    ),
  );
}

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryView()),
    );
  }

  void _showWorkLocationRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Local de Trabalho Necessário'),
        content: const Text(
          'Você precisa definir um local de trabalho antes de registrar pontos. '
          'Deseja definir agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Depois'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSetWorkLocation();
            },
            child: const Text('Definir Agora'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _firebaseController.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Ponto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho de boas-vindas
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, $_userName!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _workLocation != null
                                      ? 'Local de trabalho definido'
                                      : 'Local de trabalho não definido',
                                  style: TextStyle(
                                    color: _workLocation != null
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Título da seção de ações
                  const Text(
                    'Ações Disponíveis:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Grid de botões
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3.5,
                      children: [
                        // Botão 1: Definir Local de Trabalho
                        _buildActionCard(
                          icon: Icons.work_outline,
                          title: 'Definir Local de Trabalho',
                          subtitle: _workLocation != null
                              ? 'Local já definido - Toque para alterar'
                              : 'Toque para definir seu local de trabalho',
                          color: Colors.blue,
                          onTap: _navigateToSetWorkLocation,
                          badge: _workLocation != null
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                              : const Icon(Icons.warning, color: Colors.orange, size: 16),
                        ),

                        // Botão 2: Bater Ponto
                        _buildActionCard(
                          icon: Icons.fingerprint,
                          title: 'Bater Ponto',
                          subtitle: _workLocation != null
                              ? 'Registrar ponto (até 100m do local)'
                              : 'Defina o local de trabalho primeiro',
                          color: _workLocation != null ? Colors.green : Colors.grey,
                          onTap: _navigateToRegisterPoint,
                          enabled: _workLocation != null,
                        ),

                        // Botão 3: Histórico de Pontos
                        _buildActionCard(
                          icon: Icons.history,
                          title: 'Histórico de Pontos',
                          subtitle: 'Visualizar todos os registros',
                          color: Colors.purple,
                          onTap: _navigateToHistory,
                        ),
                      ],
                    ),
                  ),

                  // Informações adicionais
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Informações:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _workLocation != null
                                ? '• Local de trabalho definido\n'
                                  '• Você pode bater ponto a até 100m de distância\n'
                                  '• Use biometria para autenticação rápida'
                                : '• Defina seu local de trabalho primeiro\n'
                                  '• Depois você poderá bater pontos\n'
                                  '• Use biometria para autenticação rápida',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
    Widget? badge,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: enabled ? color : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: enabled ? color : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled ? Colors.black54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                badge,
              ],
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: enabled ? color : Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}