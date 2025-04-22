class Task {
  final int idTask;
  final String titulo;
  final String? descricao;
  final String categoria;
  final int prioridade;
  final DateTime? dataTermino;
  final bool isCompleted;
  final String? createdAt;
  final String? updatedAt;

  Task({
    this.idTask = 0,
    required this.titulo,
    this.descricao,
    required this.categoria,
    required this.prioridade,
    this.dataTermino,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  // Para salvar em banco
  Map<String, dynamic> toMap() {
    return {
      'title': titulo,
      'description': descricao,
      'category': categoria,
      'priority': prioridade,
      'due_date': dataTermino?.toIso8601String(),
      'is_completed': isCompleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Para ler do banco/JSON e criar uma Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      idTask: int.tryParse('${map['id_task']}') ?? 0,
      titulo: map['title'],
      descricao: map['description'],
      categoria: map['category'],
      prioridade: map['priority'],
      dataTermino:
          map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      isCompleted: map['is_completed'] ?? false,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
