import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/task.dart';
import '../../core/utils/image_storage.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_lists_cubit.dart';

class TaskFormPage extends StatefulWidget {
  final Task? initial;
  const TaskFormPage({super.key, this.initial});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _descController = TextEditingController(
      text: widget.initial?.description ?? '',
    );
    _imagePaths = List.from(widget.initial?.imagePaths ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      // For new tasks, use a temporary ID that will be replaced when task is created
      final taskId = widget.initial?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final savedPath = await ImageStorage.saveImage(File(image.path), taskId);
      setState(() {
        _imagePaths.add(savedPath);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final selectedListId =
        context.read<TaskListsCubit>().state.selectedListId ??
        now.millisecondsSinceEpoch.toString();
    if (widget.initial == null) {
      final taskId = now.millisecondsSinceEpoch.toString();
      // Move images from temp folder to actual task folder
      final List<String> finalImagePaths = [];
      for (final tempPath in _imagePaths) {
        if (tempPath.contains('temp_')) {
          final tempFile = File(tempPath);
          if (await tempFile.exists()) {
            final finalPath = await ImageStorage.saveImage(tempFile, taskId);
            finalImagePaths.add(finalPath);
            // Delete temp file
            await tempFile.delete();
          }
        } else {
          finalImagePaths.add(tempPath);
        }
      }
      final task = Task(
        id: taskId,
        listId: selectedListId,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        isDone: false,
        createdAt: now,
        imagePaths: finalImagePaths,
      );
      context.read<TaskBloc>().add(TaskAdded(task));
    } else {
      // Delete removed images
      final oldPaths = widget.initial!.imagePaths;
      for (final oldPath in oldPaths) {
        if (!_imagePaths.contains(oldPath)) {
          await ImageStorage.deleteImage(oldPath);
        }
      }
      final updated = widget.initial!.copyWith(
        listId: selectedListId,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        imagePaths: _imagePaths,
      );
      context.read<TaskBloc>().add(TaskUpdated(updated));
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Add Task')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Title is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descController,
                            decoration: const InputDecoration(
                              labelText: 'Description (optional)',
                              border: OutlineInputBorder(),
                            ),
                            minLines: 3,
                            maxLines: 6,
                          ),
                          const SizedBox(height: 16),
                          const Text('Images (optional)'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._imagePaths.asMap().entries.map((entry) {
                                final index = entry.key;
                                final imagePath = entry.value;
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(imagePath),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        color: Colors.white,
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                        ),
                                        onPressed: () => _removeImage(index),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add_photo_alternate),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.check),
                              label: Text(
                                isEditing ? 'Save Changes' : 'Add Task',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
