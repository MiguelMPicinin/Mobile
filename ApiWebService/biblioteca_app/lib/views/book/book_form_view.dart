import 'dart:ffi';

import 'package:biblioteca_app/controllers/books_controller.dart';
import 'package:biblioteca_app/models/books_models.dart';
import 'package:biblioteca_app/views/home_view.dart';
import 'package:flutter/material.dart';

class BookFormView extends StatefulWidget {
  final BooksModels? books;

  const BookFormView({super.key, this.books});

  @override
  State<BookFormView> createState() => _BookFormViewState();
}

class _BookFormViewState extends State<BookFormView> {
  final _formkey = GlobalKey<FormState>(); //armazenar as info do Form
  final _controller = BooksController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _avaliableController = TextEditingController();
  @override
  void initState() {
    super.initState();

    if (widget.books != null) {
      _titleController.text = widget.books!.title;
      _authorController.text = widget.books!.author;
      _avaliableController.text = widget.books!.avaliable.toString();
    }
  }

    void _save() async{
    if(_formkey.currentState!.validate()){
      final user = BooksModels(
        title: _titleController.text, 
        author: _authorController.text,
        avaliable: _avaliableController as bool);
      await _controller.create(user);
      Navigator.pop(context);
      Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (context)=> HomeView()));
    }
  }

    void _update() async{
    if(_formkey.currentState!.validate()){
      final user = BooksModels(
        id: widget.books?.id!,
        title: _titleController.text, 
        author: _authorController.text,
        avaliable: _avaliableController as bool);
      await _controller.update(user);
      Navigator.pop(context);
      Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (context)=> HomeView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(
        widget.books == null ? "Novo Usuário" : "Editar Usuário"
      ),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Titulo"),
                validator: (value) => value!.isEmpty? "Informe o titulo": null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: "Autor"),
                validator: (value) => value!.isEmpty? "Informe o autor": null,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: widget.books == null ? _save : _update,
                child: Text(widget.books == null ? "Salvar" : "Atualizar"))
            ],
          )),),
    );
  }
}
