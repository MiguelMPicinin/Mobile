import 'package:flutter/material.dart';
import 'package:biblioteca_app/controllers/books_controller.dart';
import 'package:biblioteca_app/controllers/loan_controller.dart';
import 'package:biblioteca_app/controllers/user_controller.dart';
import 'package:biblioteca_app/models/books_models.dart';
import 'package:biblioteca_app/models/loan_models.dart';
import 'package:biblioteca_app/models/user_models.dart';
import 'package:biblioteca_app/views/home_view.dart';

class LoanFormView extends StatefulWidget {
  final LoanModels? loan;

  const LoanFormView({super.key, this.loan});

  @override
  State<LoanFormView> createState() => _LoanFormViewState();
}

class _LoanFormViewState extends State<LoanFormView> {
  final _formKey = GlobalKey<FormState>();

  final _loanController = LoanController();
  final _userController = UserController();
  final _bookController = BooksController();

  final _startDateController = TextEditingController();
  final _returnedController = TextEditingController();

  List<UserModels> _users = [];
  List<BooksModels> _books = [];

  UserModels? _selectedUser;
  BooksModels? _selectedBook;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.loan != null) {
      _startDateController.text = widget.loan!.startDate;
      _returnedController.text = widget.loan!.returned.toString();
    }
  }

  Future<void> _loadData() async {
    try {
      final users = await _userController.fetchAll();
      final books = await _bookController.fetchAll();

      setState(() {
        _users = users;
        _books = books;

        if (widget.loan != null) {
          _selectedUser = _users.firstWhere((u) => u.id == widget.loan!.userId);
          _selectedBook = _books.firstWhere((b) => b.id == widget.loan!.bookId);
        }

        _loading = false;
      });
    } catch (e) {
      // Trate o erro aqui, se necessário
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate() &&
        _selectedUser != null &&
        _selectedBook != null) {
      final newLoan = LoanModels(
        id: widget.loan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _selectedUser!.id!,
        bookId: _selectedBook!.id!,
        startDate: _startDateController.text,
        returned: _returnedController.text.toLowerCase() == 'true',
      );

      try {
        if (widget.loan == null) {
          await _loanController.create(newLoan);
        } else {
          await _loanController.update(newLoan);
        }

        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeView()),
        );
      } catch (e) {
        // Trate o erro aqui
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.loan == null ? "Novo Empréstimo" : "Editar Empréstimo"),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loan == null ? "Novo Empréstimo" : "Editar Empréstimo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<UserModels>(
                value: _selectedUser,
                decoration: InputDecoration(labelText: "Usuário"),
                items: _users.map((user) {
                  return DropdownMenuItem(
                    value: user,
                    child: Text(user.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedUser = value),
                validator: (value) => value == null ? "Selecione um usuário" : null,
              ),
              DropdownButtonFormField<BooksModels>(
                value: _selectedBook,
                decoration: InputDecoration(labelText: "Livro"),
                items: _books.map((book) {
                  return DropdownMenuItem(
                    value: book,
                    child: Text(book.title),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedBook = value),
                validator: (value) => value == null ? "Selecione um livro" : null,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(labelText: "Data de Início"),
                validator: (value) =>
                    value!.isEmpty ? "Informe a data de início" : null,
              ),
              TextFormField(
                controller: _returnedController,
                decoration: InputDecoration(labelText: "Devolvido (true/false)"),
                validator: (value) =>
                    value!.isEmpty ? "Informe se foi devolvido" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(widget.loan == null ? "Salvar" : "Atualizar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
