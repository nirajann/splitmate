import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    inviteController.dispose();
    super.dispose();
  }

  void addInvite() {
    final value = inviteController.text.trim();

    if (value.isEmpty) return;

    setState(() {
      invitedPeople.add(value);
      inviteController.clear();
    });
  }

  void createLobby() {
    final appState = context.read<AppState>();

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter lobby name')));
      return;
    }

    appState.createLobby(
      name: name,
      description: description,
      invitedPeople: invitedPeople,
    );

    final createdLobby = appState.currentUserLobbies.first;

    for (final person in invitedPeople) {
      appState.addMemberToLobby(lobbyId: createdLobby.id, nameOrEmail: person);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name lobby created successfully')));

    Navigator.pop(context);
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
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
                    'Invite by name or email',
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

          if (invitedPeople.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: invitedPeople.map((person) {
                return Chip(
                  backgroundColor: const Color(0xFFFFE4D7),
                  label: Text(
                    person,
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() => invitedPeople.remove(person));
                  },
                );
              }).toList(),
            ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This lobby will start with ${invitedPeople.length + 1} member${invitedPeople.length + 1 == 1 ? '' : 's'}. You can add expenses after creating it.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
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
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
      prefixIcon: Icon(icon, color: AppColors.orange),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}
