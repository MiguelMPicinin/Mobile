import 'package:flutter/material.dart';
import '../controller/salario_controller.dart';
import 'home_screen.dart';

class SalarioScreen extends StatefulWidget {
  @override
  State<SalarioScreen> createState() => _SalarioScreenState();
}

class _SalarioScreenState extends State<SalarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final SalarioController _salarioController = SalarioController();

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final valor = double.tryParse(_controller.text) ?? 0.0;
      await _salarioController.setSalario(valor);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informe seu salário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Digite seu salário para começar:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Salário'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o salário' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}