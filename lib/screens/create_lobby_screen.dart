import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CreateLobbyScreen extends StatefulWidget {
  const CreateLobbyScreen({super.key});

  @override
  State<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends State<CreateLobbyScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final inviteController = TextEditingController();

  final List<String> invitedPeople = [];

  void addInvite() {
    final value = inviteController.text.trim();

    if (value.isEmpty) return;

    setState(() {
      invitedPeople.add(value);
      inviteController.clear();
    });
  }

  void createLobby() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter lobby name')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lobby created with dummy data')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF0),
      appBar: AppBar(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        title: const Text('Create Lobby'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Create a shared expense lobby',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Invite friends, add expenses, and track who owes whom.',
            style: TextStyle(color: AppColors.greyText),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            decoration: inputDecoration('Lobby Name', Icons.groups_outlined),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: inputDecoration('Description', Icons.notes_outlined),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inviteController,
                  decoration: inputDecoration(
                    'Invite by email or phone',
                    Icons.person_add_alt,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: addInvite,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: invitedPeople.map((person) {
              return Chip(
                label: Text(person),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() => invitedPeople.remove(person));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: createLobby,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Create Lobby',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}