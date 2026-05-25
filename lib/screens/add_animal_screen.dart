import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_helper.dart';

class AddAnimalScreen extends StatefulWidget {
  final Map<String, dynamic>? animal; // Optional data for Edit Mode

  const AddAnimalScreen({super.key, this.animal});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _tagController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedType = 'Cow';
  final List<String> _animalTypes = ['Cow', 'Buffalo', 'Goat', 'Sheep'];

  File? _animalImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // ✅ PRE-FILL FORM FOR EDIT MODE
    if (widget.animal != null) {
      _tagController.text = widget.animal!['tag_id'];
      _breedController.text = widget.animal!['breed'];
      _ageController.text = widget.animal!['age'].toString();
      _selectedType = widget.animal!['type'];
      if (widget.animal!['image_path'] != "") {
        _animalImage = File(widget.animal!['image_path']);
      }
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() {
        _animalImage = File(photo.path);
      });
    }
  }

  // ✅ MODERN BOTTOM SHEET FOR IMAGE UPLOAD
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Upload Animal Photo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.green),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.animal != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5), // Premium off-white background
      // ✅ MODERN APP BAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: Text(
          isEditMode ? "Edit Animal" : "Add New Animal",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ✅ PREMIUM IMAGE UPLOADER
            Center(
              child: GestureDetector(
                onTap: _showImageSourceOptions,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: _animalImage == null
                            ? Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                                width: 2,
                                style: BorderStyle.solid,
                              )
                            : null,
                        image: _animalImage != null
                            ? DecorationImage(
                                image: FileImage(_animalImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _animalImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 40,
                                  color: Colors.green.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Add Photo",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),

                    // Floating Edit Badge
                    if (_animalImage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ✅ STYLED FORM FIELDS
            _buildTextField(
              controller: _tagController,
              label: "Tag ID",
              icon: Icons.sell_outlined,
            ),
            const SizedBox(height: 16),

            // Dropdown Field
            Container(
              decoration: _inputDecorationBox(),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: "Animal Type",
                  prefixIcon: const Icon(
                    FontAwesomeIcons.cow,
                    size: 18,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                items: _animalTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _breedController,
              label: "Breed (e.g. Sahiwal)",
              icon: Icons.pets_rounded,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _ageController,
              label: "Age (Years)",
              icon: Icons.access_time_rounded,
              isNumber: true,
            ),
            const SizedBox(height: 32),

            // ✅ PREMIUM SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: Colors.green.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  if (_tagController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tag ID is required!")),
                    );
                    return;
                  }

                  Map<String, dynamic> row = {
                    'tag_id': _tagController.text,
                    'type': _selectedType,
                    'breed': _breedController.text,
                    'age': _ageController.text,
                    'image_path': _animalImage?.path ?? "",
                  };

                  if (!isEditMode) {
                    await DatabaseHelper().insertAnimal(row);
                  } else {
                    row['id'] = widget.animal!['id'];
                    await DatabaseHelper().updateAnimal(row);
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context, true);
                },
                child: Text(
                  isEditMode ? "UPDATE ANIMAL" : "SAVE ANIMAL",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper widget for beautiful text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Container(
      decoration: _inputDecorationBox(),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  // Helper for the soft shadow box behind fields
  BoxDecoration _inputDecorationBox() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
