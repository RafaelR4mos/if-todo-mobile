import 'package:flutter/material.dart';

import 'package:todoapp/services/task_service.dart';
import 'package:todoapp/model/task.dart';
import 'package:todoapp/widgets/task_card.dart';
import 'package:todoapp/widgets/task_form.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> tarefas = [];

  final List<String> categorias = ['Estudo', 'Trabalho', 'Pessoal'];
  final List<String> prioridades = ['Baixa', 'Média', 'Alta', 'Crítica'];

  String? categoriaSelecionada;
  String? prioridadeSelecionada;
  int? prioridadeSelecionadaIndex;
  DateTime? dataSelecionada;

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  void carregarTarefas() async {
    try {
      final tarefasCarregadas = await TaskService.fetchTasks();

      if (!mounted) return;

      setState(() {
        tarefas = tarefasCarregadas;
      });
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
    }
  }

  void _abrirBottomSheetNovaTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TaskForm(
          categorias: categorias,
          prioridades: prioridades,
          onSave: (novaTask) async {
            final sucesso = await TaskService.createTask(novaTask);

            //Resolve problemas relacionado a destruição de widget.
            if (!mounted) return;

            if (sucesso) {
              carregarTarefas();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Erro ao salvar tarefa')),
              );
            }

            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: TextStyle(color: Colors.white)),
            Container(
              height: 40,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/images/avatar.png'),
              ),
            ),
          ],
        ),
      ),
      body:
          tarefas.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/checklist.png'),
                    Text('O que você vai fazer hoje?'),
                    Text('Clique em "+" para adicionar novas tasks'),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: tarefas.length,
                itemBuilder: (context, index) {
                  final task = tarefas[index];
                  return TaskCard(
                    task: task,
                    onConcluir: () async {
                      final sucesso = await TaskService.concluirTask(
                        task.idTask,
                      );
                      if (!mounted) return;
                      if (sucesso) carregarTarefas();
                    },
                    onExcluir: () async {
                      final sucesso = await TaskService.deleteTask(task.idTask);
                      if (!mounted) return;
                      if (sucesso) carregarTarefas();
                    },
                    prioridades: prioridades,
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirBottomSheetNovaTask,
        tooltip: 'Abrir sheet nova task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
