import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TarefasView extends StatefulWidget {
  const TarefasView({super.key});

  @override
  State<TarefasView> createState() => _TarefasViewState();
}

class _TarefasViewState extends State<TarefasView> {
  // atributos
  final _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  final _tarefasField = TextEditingController();

  // método para adicionar tarefa
  void _addTarefa() async {
    if (_tarefasField.text.trim().isEmpty || _user == null) return;
    try {
      await _db
          .collection("usuarios")
          .doc(_user!.uid)
          .collection("tarefas")
          .add({
            "titulo": _tarefasField.text.trim(),
            "concluida": false,
            "dataCriacao": Timestamp.now(),
          });
      _tarefasField.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao adicionar tarefa: $e")));
    }
  }

  // método para atualizar o status da tarefa
  void _atualizarTarefa(String id, bool concluida) async {
    try {
      await _db
          .collection("usuarios")
          .doc(_user!.uid)
          .collection("tarefas")
          .doc(id)
          .update({"concluida": concluida});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao atualizar tarefa: $e")));
    }
  }

  // método para deletar tarefa
  void _deleteTarefa(String id) async {
    try {
      await _db
          .collection("usuarios")
          .doc(_user!.uid)
          .collection("tarefas")
          .doc(id)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao deletar tarefa: $e")));
    }
  }

  // build da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Tarefas"),
        actions: [
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tarefasField,
              decoration: InputDecoration(
                labelText: "Nova Tarefa",
                border: OutlineInputBorder(),
                suffix: IconButton(
                  onPressed: () async {
                    if (_tarefasField.text.trim().isEmpty) return;
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Criar Tarefa"),
                        content: Text("Deseja adicionar esta tarefa?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text("Confirmar"),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _addTarefa();
                    }
                  },
                  icon: Icon(Icons.add),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection("usuarios")
                    .doc(_user?.uid)
                    .collection("tarefas")
                    .orderBy("dataCriacao", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("Não existem tarefas criadas"));
                  }
                  final tarefas = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) {
                      final tarefa = tarefas[index];
                      final tarefaData = tarefa.data() as Map<String, dynamic>;
                      bool concluida = tarefaData["concluida"] ?? false;
                      return ListTile(
                        title: Text(tarefaData["titulo"]),
                        leading: Checkbox(
                          value: concluida,
                          onChanged: (value) async {
                            _atualizarTarefa(tarefa.id, value!);
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteTarefa(tarefa.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
