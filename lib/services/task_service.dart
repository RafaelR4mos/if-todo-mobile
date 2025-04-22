import 'package:todoapp/model/task.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
  static const String BASE_URL =
      'http://200.19.1.19/20222GR.ADS0011/api-php/Controller/crud-task.php';

  // GET - LISTA TODAS TASKS
  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$BASE_URL?oper=Listar'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> data = responseBody['dados'];
      return data.map((json) => Task.fromMap(json)).toList();
    } else {
      throw Exception('Erro ao buscar tarefas: ${response.statusCode}');
    }
  }

  // POST - CRIA UMA TASK
  static Future<bool> createTask(Task task) async {
    final url = Uri.parse('$BASE_URL?oper=Inserir');

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

  // PUT - ATUALIZA is_completed para TRUE
  static Future<bool> concluirTask(int idTask) async {
    final url = Uri.parse('$BASE_URL?oper=Concluir&id_task=$idTask');

    final response = await http.put(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro ao concluir tarefa: ${response.statusCode}');
      return false;
    }
  }

  // DELETE - EXCLUI UMA TASK pelo ID
  static Future<bool> deleteTask(int idTask) async {
    final url = Uri.parse('$BASE_URL?oper=Excluir&id_task=$idTask');

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro ao excluir tarefa: ${response.statusCode}');
      return false;
    }
  }
}
