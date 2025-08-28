import 'package:biblioteca_app/controllers/user_controller.dart';
import 'package:biblioteca_app/models/user_models.dart';
import 'package:biblioteca_app/views/user/user_form_view.dart';
import 'package:flutter/material.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  //atributos
  final _controller = UserController();
  List<UserModels> _users = [];
  bool _loading = true;
  List<UserModels> _filteredUsers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load(); //carregar as informações iniciais de users
  }

  void _load() async {
    setState(() => _loading = true);
    try {
      _users = await _controller.fetchAll();
      _filteredUsers = _users;
    } catch (e) {
      //tratar erro aqui
    }
    setState(() => _loading = false);
  }

  //método para criar uma lista de usuário filtrada pelas letras que forem
  // digitas na barra de pesquisa
  void _usersFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _openForm({UserModels? user}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFormView(user: user)),
    );
    _load();
  }

  //build da Tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //não precisa de Appbar -> já tem a appbar da homeView
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pesquisar Usuário",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _usersFilter(),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Card(
                          child: ListTile(
                            title: Text(user.name),
                            subtitle: Text(user.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _openForm(user: user),
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () => _delete(user),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _delete(UserModels user) async {
    if (user.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Exclusão"),
        content: Text("Deseja realmente excluir o usuario ${user.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Exluir"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _controller.delete(user.id!);
        _load();
      } catch (e) {
        print(Text("Erro ao excluir"));
      }
    }
  }
}
