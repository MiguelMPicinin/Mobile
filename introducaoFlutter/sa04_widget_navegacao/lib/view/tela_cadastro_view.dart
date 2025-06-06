//criar a classe Tela de Cadastro

import 'package:flutter/material.dart';

class TelaCadastroView  extends StatefulWidget{
  _TelaCadastroViewState createState() => _TelaCadastroViewState();
}

class _TelaCadastroViewState extends State<TelaCadastroView>{
  //classe com o método build
  //atributos
  final _formKey = GlobalKey<FormState>();
  String _nome = "";
  String _email = "";
  double _idade = 13;
  bool _aceiteTermos = false;
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro"),centerTitle: true,),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:Column(
            children: [
              //Campo do Nome
              TextFormField(
                decoration: InputDecoration(labelText: "Digite o Nome"),
                validator: (value) => value!.length>=3 ? null : "Insira um Nome" , //Operador Ternário
                onSaved: (value)=> _nome = value!,
              ),
              SizedBox(height: 20,),
              //Campo do Email
              TextFormField(
                decoration: InputDecoration(labelText: "Digite o Email"),
                validator: (value) => value!.contains("@") ? null : "Insira um Email Válido", //Operador Ternário
                onSaved: (value)=> _email = value!,
              ),
              SizedBox(height: 20,),
              //Slider da Idade
              Text("Informe a Idade"),
              Slider(
                value: _idade,
                min: 13,
                max: 99,
                divisions: 86,
                label: _idade.round().toString(), 
                onChanged: (value)=>setState(() {
                  _idade = value;
                })),
                SizedBox(height: 20,),
                // CheckBox de Aceite
                CheckboxListTile(
                  value: _aceiteTermos,
                  title: Text("Aceitos os Termos de Uso."),
                  onChanged: (value)=>setState(() {
                    _aceiteTermos = value!;
                  })),
                SizedBox(height: 20,),
                //botão de Envio
                ElevatedButton(
                  onPressed: _enviarDados, 
                  child: Text("Enviar"))
                
            ],
          )), ),
    );
  }


  void _enviarDados() {
    if(_formKey.currentState!.validate() && _aceiteTermos){
      _formKey.currentState!.save();
      Navigator.pushNamed(context, "/confirmacao");
    }
  }
}