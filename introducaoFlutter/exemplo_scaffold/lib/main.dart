import 'package:flutter/material.dart';

// void Main
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //estudo do scaffold
      home: Scaffold(
        //barra de navegação superior
        appBar: AppBar(
          title: Text("Exemplo appBar"),
          backgroundColor: Colors.blue,
        ),
        //Corpo do aplicativo
        body:Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Text("Coluna 1"),
                Text("Coluna 2"),
                Text("Coluna 3")],
                ),
                Text("Linha 2"),
                Text("Libha 3"),
            ],
        ) ,
        //barra lateral (menu hamburguer)
        drawer: Drawer(
          child: ListView(
            children: [Text("Inicio"), Text("Conteudo"), Text("Contato")],
          ),
        ),
        //barra de navegação inferior
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Pesquisa"),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Usuario"),
          ],
        ),
        //botão flutuante
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Botão Clicado");
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
