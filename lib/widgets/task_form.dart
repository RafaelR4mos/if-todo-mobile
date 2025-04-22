import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:todoapp/model/task.dart';

class TaskForm extends StatefulWidget {
  final Function(Task) onSave;
  final List<String> categorias;
  final List<String> prioridades;

  const TaskForm({
    Key? key,
    required this.onSave,
    required this.categorias,
    required this.prioridades,
  }) : super(key: key);

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();

  String? titulo;
  String? descricao;
  String? categoriaSelecionada;
  String? prioridadeSelecionada;
  int? prioridadeSelecionadaIndex;
  DateTime? dataSelecionada;

  @override
  Widget build(BuildContext context) {
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Adicionar Tarefa",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
                decoration: _inputDecoration('Título'),
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
                decoration: _inputDecoration('Descrição'),
                maxLines: 3,
                onSaved: (value) => descricao = value,
              ),
              const SizedBox(height: 12),

              // Categoria
              DropdownButtonFormField<String>(
                value: categoriaSelecionada,
                decoration: _inputDecoration('Categoria'),
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items:
                    widget.categorias
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => categoriaSelecionada = value),
                validator:
                    (value) => value == null ? 'Escolha uma categoria' : null,
              ),
              const SizedBox(height: 12),

              // Prioridade
              DropdownButtonFormField<String>(
                value: prioridadeSelecionada,
                decoration: _inputDecoration('Prioridade'),
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items:
                    widget.prioridades
                        .map(
                          (pri) =>
                              DropdownMenuItem(value: pri, child: Text(pri)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    prioridadeSelecionada = value;
                    prioridadeSelecionadaIndex = widget.prioridades.indexOf(
                      value!,
                    );
                  });
                },
                validator:
                    (value) => value == null ? 'Escolha uma prioridade' : null,
              ),
              const SizedBox(height: 18),

              // Data de término
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
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
                          dialogTheme: const DialogTheme(
                            backgroundColor: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => dataSelecionada = picked);
                  }
                },
                child: InputDecorator(
                  decoration: _inputDecoration('Data de Término'),
                  child: Text(
                    dataSelecionada != null
                        ? DateFormat('dd/MM/yyyy').format(dataSelecionada!)
                        : 'Selecionar data',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botão Criar
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final novaTask = Task(
                        titulo: titulo!,
                        descricao: descricao,
                        categoria: categoriaSelecionada!,
                        prioridade: prioridadeSelecionadaIndex!,
                        dataTermino: dataSelecionada,
                      );

                      widget.onSave(novaTask);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
