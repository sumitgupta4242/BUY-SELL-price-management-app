// lib/add_edit_item_page.dart

import 'package:flutter/material.dart';
import 'item_model.dart';
import 'database_helper.dart';

class AddEditItemPage extends StatefulWidget {
  final Item? item;

  const AddEditItemPage({super.key, this.item});

  @override
  // ignore: library_private_types_in_public_api
  _AddEditItemPageState createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _buyingPriceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _wholesalePriceController = TextEditingController();
  final TextEditingController _maintenanceCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      // Handle null values by showing an empty string
      _buyingPriceController.text = widget.item!.buyingPrice?.toString() ?? '';
      _sellingPriceController.text = widget.item!.sellingPrice?.toString() ?? '';
      _wholesalePriceController.text = widget.item!.wholesalePrice?.toString() ?? '';
      _maintenanceCostController.text = widget.item!.maintenanceCost?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _wholesalePriceController.dispose();
    _maintenanceCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add New Item' : 'Edit Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: _saveItem,
            tooltip: 'Save',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name is the only required field
              _buildTextFormField(
                  controller: _nameController,
                  labelText: 'Item Name *',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _buyingPriceController,
                labelText: 'Buying Price',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _sellingPriceController,
                labelText: 'Selling Price',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _wholesalePriceController,
                labelText: 'Wholesale Selling Price',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _maintenanceCostController,
                labelText: 'Maintenance Cost',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // A helper function to check if a string is a valid number
    bool isNumeric(String? s) {
      if (s == null || s.isEmpty) {
        return true; // Empty is valid since fields are optional
      }
      return double.tryParse(s) != null;
    }

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      // Combine custom validator with number check
      validator: (value) {
        if (validator != null) {
          final error = validator(value);
          if (error != null) return error;
        }
        if (keyboardType == TextInputType.number && !isNumeric(value)) {
          return 'Please enter a valid number.';
        }
        return null;
      },
    );
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();

      // Use double.tryParse to safely convert text to double, defaulting to null if invalid or empty
      final buyingPrice = double.tryParse(_buyingPriceController.text);
      final sellingPrice = double.tryParse(_sellingPriceController.text);
      final wholesalePrice = double.tryParse(_wholesalePriceController.text);
      final maintenanceCost = double.tryParse(_maintenanceCostController.text);

      final itemToSave = Item(
        id: widget.item?.id,
        name: _nameController.text,
        buyingPrice: buyingPrice,
        sellingPrice: sellingPrice,
        wholesalePrice: wholesalePrice,
        maintenanceCost: maintenanceCost,
        // If it's a new item, use `now`. If editing, preserve original creation date.
        createdAt: widget.item?.createdAt ?? now,
        // Always set `updatedAt` to `now` on any save.
        updatedAt: now,
      );

      if (widget.item == null) {
        await DatabaseHelper.instance.createItem(itemToSave);
      } else {
        await DatabaseHelper.instance.updateItem(itemToSave);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
