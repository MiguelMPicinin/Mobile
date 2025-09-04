import 'package:biblioteca_app/controllers/user_controller.dart';
import 'package:biblioteca_app/models/user_models.dart';
import 'package:biblioteca_app/views/home_view.dart';
import 'package:biblioteca_app/views/user/user_list_view.dart';
import 'package:flutter/material.dart';

class UserFormView extends StatefulWidget {
  //atributo
  final UserModels? user; //pode ser nulo

  const UserFormView({super.key, this.user});

  @override
  State<UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends State<UserFormView> {
  //atributos
  final _formkey = GlobalKey<FormState>(); //armazenar as info do Form
  final _controller = UserController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //se for edição de usuário existent
    if(widget.user != null){
    _nameController.text = widget.user!.name;
    _emailController.text = widget.user!.email;
    }
    
  }

  void _save() async{
    if(_formkey.currentState!.validate()){
      final user = UserModels(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text, 
        email: _emailController.text);
      await _controller.create(user);
      Navigator.pop(context);
      Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (context)=> HomeView()));
    }
  }

  void _update() async{
    if(_formkey.currentState!.validate()){
      final user = UserModels(
        id: widget.user?.id,
        name: _nameController.text, 
        email: _emailController.text);
      await _controller.update(user);
      Navigator.pop(context);
      Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (context)=> UserListView()));
    }
  }

  //build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(
        widget.user == null ? "Novo Usuário" : "Editar Usuário"
      ),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nome"),
                validator: (value) => value!.isEmpty? "Informe o nome": null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty? "Informe o email": null,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: widget.user == null ? _save : _update,
                child: Text(widget.user == null ? "Salvar" : "Atualizar"))
            ],
          )),),
    );
  }
}