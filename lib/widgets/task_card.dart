import 'package:flutter/material.dart';
import '../model/task.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onConcluir;
  final VoidCallback onExcluir;
  final List<String> prioridades;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onConcluir,
    required this.onExcluir,
    required this.prioridades,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: task.isCompleted ? 0.6 : 1.0,
      child: Card(
        color: Colors.grey[900],
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título + ações
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
                        color: task.isCompleted ? Colors.green : Colors.grey,
                      ),
                    ),
                    onPressed: task.isCompleted ? null : onConcluir,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                    ),
                    onPressed: onExcluir,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Descrição
              if (task.descricao != null && task.descricao!.isNotEmpty)
                Text(
                  task.descricao!,
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 6),

              // Badges
              Wrap(
                spacing: 10,
                runSpacing: 8,
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
                        : task.prioridade == 2
                        ? Colors.red
                        : Colors.purple,
                  ),
                  if (task.dataTermino != null)
                    _buildBadge(
                      'Término: ${DateFormat('dd/MM/yyyy').format(task.dataTermino!)}',
                      Colors.blueGrey,
                    ),

                  if (isAtrasada(task))
                    _buildBadge('ATRASADA!', Colors.redAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isAtrasada(Task task) {
    return task.dataTermino != null &&
        task.dataTermino!.isBefore(DateTime.now()) &&
        !task.isCompleted;
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
}
