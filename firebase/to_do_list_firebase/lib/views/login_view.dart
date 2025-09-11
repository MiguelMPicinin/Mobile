import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_firebase/views/registro_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  //atributos
  final _emailField = TextEditingController();
  final _senhaField = TextEditingController();
  final _authController = FirebaseAuth
      .instance; //controller para a manipulação do usuario no FirebaseAuth
  bool _senhaOculta = true;

  //Método
  void _login() async {
    try {
      //solicitar a autenticação do User
      await _authController.signInWithEmailAndPassword(
        email: _emailField.text.trim(),
        password: _senhaField.text,
        //Não precisa do Navigator pq a mudança a tela é feita atraves de um StreamBuilder
        //Já faz o direcionamento automatico apara a tela de tarefas
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Falha ao fazer login: $e")));
    }
  }

  //build da Tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
      body: Padding(padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller:  _emailField,
            decoration: InputDecoration(labelText: "Email"),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _senhaField,
            decoration: InputDecoration(labelText: "Senha", suffix: IconButton(
              onPressed: ()=> setState(() {
                _senhaOculta = !_senhaOculta;
              }), 
                  icon: _senhaOculta ? Icon(Icons.visibility) : Icon(Icons.visibility_off))),
                  obscureText: _senhaOculta,
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: _login, 
            child: Text("Login")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> RegistroView())),
              child: Text("Não tem uma Conta? Registre-se"))
        ],
      ),),
    );
  }
}
