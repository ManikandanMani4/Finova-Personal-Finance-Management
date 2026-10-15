
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/challenges_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  static const String routeName = '/challenges';

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final ChallengesService _service = ChallengesService();

  Future<void> _showAddChallengeDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New challenge'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Enter a title'
                      : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration:
                  const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Enter a description'
                      : null,
                ),
                TextFormField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Savings target (₹)',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value ?? '');
                    if (amount == null || !amount.isFinite || amount <= 0) {
                      return 'Enter a valid target';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await _service.addChallenge(
          title: titleController.text,
          description: descriptionController.text,
          targetAmount: double.parse(targetController.text),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Challenge created')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not create challenge: $error')),
          );
        }
      }
    }

    titleController.dispose();
    descriptionController.dispose();
    targetController.dispose();
  }

  Future<void> _updateProgress(
      String id,
      double current,
      double target,
      ) async {
    final controller = TextEditingController(text: current.toStringAsFixed(0));

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update progress'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Current progress (₹), target ₹${target.toStringAsFixed(0)}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value.isFinite && value >= 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (amount == null || !mounted) return;

    try {
      await _service.updateProgress(
        challengeId: id,
        progressAmount: amount,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update progress: $error')),
        );
      }
    }
  }

  Future<void> _deleteChallenge(String id) async {
    try {
      await _service.deleteChallenge(id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete challenge: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16866A);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Challenges')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddChallengeDialog,
        backgroundColor: green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New challenge'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.watchChallenges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load challenges. Check your connection.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag_outlined, size: 60, color: green),
                    SizedBox(height: 12),
                    Text(
                      'No challenges yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Create a challenge and start tracking progress.'),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final title = data['title']?.toString() ?? 'Challenge';
              final description = data['description']?.toString() ?? '';
              final target =
                  (data['targetAmount'] as num?)?.toDouble() ?? 0;
              final progress =
                  (data['progressAmount'] as num?)?.toDouble() ?? 0;
              final completed = data['isCompleted'] == true;
              final ratio =
              target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag, color: green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete challenge',
                            onPressed: () => _deleteChallenge(doc.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                      Text(description),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: ratio.toDouble(),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        color: completed ? Colors.green : green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${progress.toStringAsFixed(0)} of '
                            '₹${target.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              completed ? 'Completed!' : '${(ratio * 100).round()}% complete',
                              style: TextStyle(
                                color: completed ? Colors.green : green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!completed)
                            TextButton(
                              onPressed: () => _updateProgress(
                                doc.id,
                                progress,
                                target,
                              ),
                              child: const Text('Update progress'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
