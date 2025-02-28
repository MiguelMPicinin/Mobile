import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() { //metodo principal para rodar a aplicação
  runApp(MyApp()); // construtor da classe principal
}

class MyApp extends StatelessWidget {  // classe principal
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // MaterialApp - contem os widgets para Android
      home: Scaffold( // Tela de visualização Basica
        appBar: AppBar(
          title: Text("Exemplo App de Dependencia"),
        ),
        body: Center(
          child: ElevatedButton(onPressed: (){
            Fluttertoast.showToast(
              msg: "Olá, Mundo!!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
          }, 
          child: Text("Clique aqui")),
        ),
      ),
    );
  }
}
