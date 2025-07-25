import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/vault_controller.dart';
import '../models/vault_item.dart';

class AddVaultItemView extends StatefulWidget {
  @override
  _AddVaultItemViewState createState() => _AddVaultItemViewState();
}

class _AddVaultItemViewState extends State<AddVaultItemView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  VaultItemType _selectedType = VaultItemType.note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('Add Vault Item'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter title',
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _contentController,
                  label: 'Content',
                  hint: 'Enter sensitive content',
                  maxLines: 5,
                ),
                SizedBox(height: 20),
                _buildDropdown(),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save to Vault',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Field cannot be empty' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<VaultItemType>(
      value: _selectedType,
      dropdownColor: Color(0xFF1A1A1A),
      iconEnabledColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Type',
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: VaultItemType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            type.name[0].toUpperCase() + type.name.substring(1),
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (type) {
        if (type != null) setState(() => _selectedType = type);
      },
    );
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final newItem = VaultItem(
        id: Uuid().v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        createdAt: now,
        updatedAt: now,
      );

      final vaultController = Provider.of<VaultController>(context, listen: false);
      await vaultController.addVaultItem(newItem);

      Navigator.of(context).pop(); // go back to vault view
    }
  }
}
