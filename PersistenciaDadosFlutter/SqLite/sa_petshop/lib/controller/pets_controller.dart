import 'package:sa_petshop/database/db_helper.dart';
import 'package:sa_petshop/models/pet_model.dart';

class PetsController {
  //atributo -> é coneão com db
  final PetShopDBHelper _dbHelper = PetShopDBHelper();

  Future<int> addPet(Pet pet) async {
    return await _dbHelper.insertPet(pet);
  }

  Future<List<Pet>> fetchPets() async {
    return await _dbHelper.getPets();
  }

  Future<Pet?> findPetById(int id) async {
    return await _dbHelper.getPetById(id);
  }

  Future<int> deletePet(int id) async {
    return await _dbHelper.deletePet(id);
  }
}
