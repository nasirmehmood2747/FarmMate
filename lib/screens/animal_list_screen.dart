import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_helper.dart';
import 'add_animal_screen.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  List<Map<String, dynamic>> _animals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshAnimals();
  }

  void _refreshAnimals() async {
    final data = await DatabaseHelper().getAnimals();
    if (!mounted) return;

    setState(() {
      _animals = data;
      _isLoading = false;
    });
  }

  // ✅ Delete Function (Kept exactly as you wrote it)
  void _deleteItem(int id) async {
    await DatabaseHelper().deleteAnimal(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Animal deleted successfully!"),
        behavior: SnackBarBehavior.floating, // Makes the snackbar float nicely
      ),
    );
    _refreshAnimals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Lets the Dashboard's off-white show through
      // ✅ PREMIUM FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Add Animal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAnimalScreen()),
          );
          if (result == true) _refreshAnimals();
        },
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _animals.isEmpty
          ? _buildEmptyState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Beautiful Screen Header
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    "My Herd",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // ✅ Animal List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: _animals.length,
                    itemBuilder: (context, index) {
                      final animal = _animals[index];
                      return _buildAnimalCard(animal);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ✅ MODERN EMPTY STATE UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.cow,
              size: 60,
              color: Colors.green.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No animals yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the + button below to add your first animal to the farm.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ✅ PREMIUM ANIMAL CARD UI
  Widget _buildAnimalCard(Map<String, dynamic> animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Animal Image (Modern Rounded Square)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              image: animal['image_path'] != ""
                  ? DecorationImage(
                      image: FileImage(File(animal['image_path'])),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: animal['image_path'] == ""
                ? const Icon(
                    FontAwesomeIcons.cow,
                    color: Colors.green,
                    size: 30,
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // 2. Animal Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tag: ${animal['tag_id']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${animal['breed']}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${animal['age']} Years Old",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 3. Action Buttons (Edit & Delete wrapped in soft circles)
          Column(
            children: [
              _buildActionButton(
                icon: Icons.edit_rounded,
                color: Colors.blue,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddAnimalScreen(animal: animal),
                    ),
                  );
                  if (result == true) _refreshAnimals();
                },
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                icon: Icons.delete_rounded,
                color: Colors.redAccent,
                onTap: () => _showDeleteDialog(animal['id']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for the small circular action buttons
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ✅ STYLED DELETE CONFIRMATION DIALOG
  void _showDeleteDialog(int animalId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              "Delete Animal?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to remove this animal? This action cannot be undone.",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              _deleteItem(animalId);
              Navigator.of(ctx).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
