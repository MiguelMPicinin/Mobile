import 'package:flutter/material.dart';
import 'package:sa_petshop/controller/pets_controller.dart';
import 'package:sa_petshop/models/pet_model.dart';
import 'package:sa_petshop/screens/add_pet_screen.dart';
import 'package:sa_petshop/screens/pet_detalhe_screen.dart';

class HomeScreen extends StatefulWidget {
  //controla as mudanças de State
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Faz o build da tela
  final PetsController _petsController = PetsController();

  List<Pet> _pets = [];
  bool _isLoanding = true; // enquanto carrega o banco

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoanding = true;
      _pets = [];
    });
    try {
      _pets = await _petsController.fetchPets();
    } catch (erro) {
      //pega o erro do sistema
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Exception: $erro")));
    } finally {
      //execução obrigatória
      setState(() {
        _isLoanding = false;
      });
    }
  }

  @override //buildar a tela
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Meus Pets")),
      body: //Operador ternario
          _isLoanding
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _pets.length,
                itemBuilder: (context, index) {
                  final pet = _pets[index];
                  return ListTile(
                    title: Text(pet.nome),
                    subtitle: Text(pet.raca),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PetDetalheScreen(petId: pet.id!), //Leva o id do pet selecionado
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Adicionar Novo Pet",
        onPressed: () async {
          //Pagina de Cadastro de Novo Pet
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPetScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
