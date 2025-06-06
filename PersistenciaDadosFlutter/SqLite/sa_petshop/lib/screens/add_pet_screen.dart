//formulario para adicionar novo pet

import 'package:flutter/material.dart';
import 'package:sa_petshop/controller/pets_controller.dart';
import 'package:sa_petshop/models/pet_model.dart';
import 'package:sa_petshop/screens/home_screen.dart';

class AddPetScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddPetScreen();
}

class _AddPetScreen extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>(); // chave para o formulario
  final _petsController = PetsController();

  String _nome = "";
  String _raca = "";
  String _nomeDono = "";
  String _telefoneDono = "";

  Future<void> _salvarPet() async {
    if (_formKey.currentState!.validate()) {
      final newPet = Pet(
        nome: _nome,
        raca: _raca,
        nomeDono: _nomeDono,
        telefoneDono: _telefoneDono,
      );

      //mando pra o banco
      try {
        await _petsController.addPet(newPet);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Exception: $e")));
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      ); //retorna para a home screen reconstruindo a tela
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Novo Pet")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Nome do Pet"),
                validator:
                    (value) => value!.isEmpty ? "Campo não preenchido" : null,
                onSaved: (value) => _nome = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Raça do Pet"),
                validator:
                    (value) => value!.isEmpty ? "Campo não preenchido" : null,
                onSaved: (value) => _raca = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Nome do Dono"),
                validator:
                    (value) => value!.isEmpty ? "Campo não preenchido" : null,
                onSaved: (value) => _nomeDono = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Telefone do Dono"),
                validator:
                    (value) => value!.isEmpty ? "Campo não preenchido" : null,
                onSaved: (value) => _telefoneDono = value!,
              ),
              ElevatedButton(onPressed: _salvarPet, child: Text("Salvar")),
            ],
          ),
        ),
      ),
    );
  }
}
