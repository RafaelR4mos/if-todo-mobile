import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/model/task.dart';

// API
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'todoapp',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212), // Fundo escuro
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
      ),
      home: const MyHomePage(title: 'Minhas tasks'),
    );
  }
}

Future<List<Task>> fetchTasks() async {
  final response = await http.get(
    Uri.parse(
      'http://200.19.1.19/20222GR.ADS0011/api-php/Controller/crud-task.php?oper=Listar',
    ),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    final List<dynamic> data = responseBody['dados'];
    return data.map((json) => Task.fromMap(json)).toList();
  } else {
    throw Exception('Erro ao buscar tarefas: ${response.statusCode}');
  }
}

Future<bool> createTask(Task task) async {
  final url = Uri.parse(
    'http://200.19.1.19/20222GR.ADS0011/api-php/Controller/crud-task.php?oper=Inserir',
  );

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'title': task.titulo,
      'description': task.descricao,
      'category': task.categoria,
      'priority': task.prioridade,
      'due_date': task.dataTermino?.toIso8601String(),
      'is_completed': task.isCompleted,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    print('Erro ao criar tarefa: ${response.statusCode}');
    return false;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  Future<bool> concluirTask(int idTask) async {
    final url = Uri.parse(
      'http://200.19.1.19/20222GR.ADS0011/api-php/Controller/crud-task.php?oper=Concluir&id_task=$idTask',
    );

    final response = await http.put(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro ao concluir tarefa: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> deleteTask(int idTask) async {
    final url = Uri.parse(
      'http://200.19.1.19/20222GR.ADS0011/api-php/Controller/crud-task.php?oper=Excluir&id_task=$idTask',
    );

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro ao excluir tarefa: ${response.statusCode}');
      return false;
    }
  }

  void carregarTarefas() async {
    try {
      final tarefasCarregadas = await fetchTasks();
      if (!mounted) return;
      setState(() {
        tarefas = tarefasCarregadas;
      });
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
    }
  }

  void _abrirBottomSheetNovaTask() {
    final _formKey = GlobalKey<FormState>();

    String? titulo;
    String? descricao;
    String? categoriaSelecionada;
    String? prioridadeSelecionada;
    int? prioridadeSelecionadaIndex;
    DateTime? dataSelecionada;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Text(
                            "Adicionar Tarefa",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Título
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Título',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Informe o título'
                                    : null,
                        onSaved: (value) => titulo = value,
                      ),
                      const SizedBox(height: 12),

                      // Descrição
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                        onSaved: (value) => descricao = value,
                      ),
                      const SizedBox(height: 12),

                      // Categoria
                      DropdownButtonFormField<String>(
                        value: categoriaSelecionada,
                        decoration: InputDecoration(
                          labelText: 'Categoria',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        dropdownColor: Colors.grey[900],
                        style: const TextStyle(color: Colors.white),
                        items:
                            categorias.map((categoria) {
                              return DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                        onChanged:
                            (value) => setModalState(
                              () => categoriaSelecionada = value,
                            ),
                        validator:
                            (value) =>
                                value == null ? 'Escolha uma categoria' : null,
                      ),
                      const SizedBox(height: 12),

                      // Prioridade
                      DropdownButtonFormField<String>(
                        value: prioridadeSelecionada,
                        decoration: InputDecoration(
                          labelText: 'Prioridade',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        dropdownColor: Colors.grey[900],
                        style: const TextStyle(color: Colors.white),
                        items:
                            prioridades.map((prioridade) {
                              return DropdownMenuItem(
                                value: prioridade,
                                child: Text(prioridade),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            prioridadeSelecionada = value;
                            prioridadeSelecionadaIndex = prioridades.indexOf(
                              value!,
                            );
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Escolha uma prioridade' : null,
                      ),
                      const SizedBox(height: 18),

                      // Data de término
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: dataSelecionada ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.deepPurple,
                                    onPrimary: Colors.white,
                                    surface: Colors.black87,
                                    onSurface: Colors.white,
                                  ),
                                  dialogTheme: DialogThemeData(
                                    backgroundColor: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setModalState(() => dataSelecionada = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data de Término',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.grey[850],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            dataSelecionada != null
                                ? '${dataSelecionada!.day.toString().padLeft(2, '0')}/'
                                    '${dataSelecionada!.month.toString().padLeft(2, '0')}/'
                                    '${dataSelecionada!.year}'
                                : 'Selecionar data',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botão de salvar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Criar',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              final Task novaTask = Task(
                                titulo: titulo!,
                                descricao: descricao,
                                categoria: categoriaSelecionada!,
                                prioridade: prioridadeSelecionadaIndex!,
                                dataTermino: dataSelecionada,
                              );

                              final sucesso = await createTask(novaTask);

                              if (!mounted) return;

                              if (sucesso) {
                                carregarTarefas(); // recarrega a lista do banco
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erro ao salvar tarefa'),
                                  ),
                                );
                              }

                              Navigator.of(context).pop(); // Fecha o modal
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      color: Colors.grey[900],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título + status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.titulo,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration:
                                          task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: Icon(
                                      task.isCompleted
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      key: ValueKey(task.isCompleted),
                                      color:
                                          task.isCompleted
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                  ),

                                  onPressed:
                                      task.isCompleted
                                          ? null
                                          : () async {
                                            final sucesso = await concluirTask(
                                              task.idTask,
                                            );
                                            if (!mounted) return;
                                            if (sucesso) {
                                              carregarTarefas();
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Erro ao concluir tarefa',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    final sucesso = await deleteTask(
                                      task.idTask,
                                    );
                                    if (!mounted) return;
                                    if (sucesso) {
                                      carregarTarefas();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Erro ao excluir tarefa',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (task.descricao != null &&
                                task.descricao!.isNotEmpty)
                              Text(
                                task.descricao!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 10,
                              children: [
                                _buildBadge(
                                  'Categoria: ${task.categoria}',
                                  const Color.fromARGB(255, 99, 69, 150),
                                ),
                                _buildBadge(
                                  'Prioridade: ${prioridades[task.prioridade]}',
                                  task.prioridade == 0
                                      ? Colors.green
                                      : task.prioridade == 1
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                                if (task.dataTermino != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: _buildBadge(
                                      'Término: ${task.dataTermino!.day.toString().padLeft(2, '0')}/'
                                      '${task.dataTermino!.month.toString().padLeft(2, '0')}/'
                                      '${task.dataTermino!.year}',
                                      Colors.blueGrey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
