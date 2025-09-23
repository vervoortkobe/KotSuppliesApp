import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotsupplies/app/widgets/app_loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/services/api_service.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/models/category.dart';
import 'package:kotsupplies/app/models/item.dart';
import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/view_models/item_view_model.dart';

class ItemFormScreen extends StatefulWidget {
  final String listGuid;
  final ListType listType;
  final Item? item; // For editing
  final List<Category>? categories; // For image_count lists

  const ItemFormScreen({
    super.key,
    required this.listGuid,
    required this.listType,
    this.item,
    this.categories,
  });

  @override
  ItemFormScreenState createState() => ItemFormScreenState();
}

class ItemFormScreenState extends State<ItemFormScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _checked = false;
  File? _pickedImage;
  String? _selectedCategoryGuid;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _amountController.text = (widget.item!.amount ?? 1).toString();
      _checked = widget.item!.checked;
      _selectedCategoryGuid = widget.item!.category?.guid;
    } else {
      _amountController.text = '1'; // Default for new items
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kErrorColor),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);

    try {
      if (widget.item == null) {
        // Create new item
        await itemViewModel.createItem(
          widget.listGuid,
          _titleController.text,
          amount: widget.listType == ListType.imageCount
              ? int.tryParse(_amountController.text)
              : null,
          checked: widget.listType == ListType.check ? _checked : null,
          categoryGuid: widget.listType == ListType.imageCount
              ? _selectedCategoryGuid
              : null,
          image: widget.listType == ListType.imageCount ? _pickedImage : null,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item created successfully!'),
            backgroundColor: kSuccessColor,
          ),
        );
      } else {
        // Update existing item
        await itemViewModel.updateItem(
          widget.listGuid,
          widget.item!,
          title: _titleController.text,
          amount: widget.listType == ListType.imageCount
              ? int.tryParse(_amountController.text)
              : null,
          checked: widget.listType == ListType.check ? _checked : null,
          categoryGuid: widget.listType == ListType.imageCount
              ? _selectedCategoryGuid
              : null,
          image: widget.listType == ListType.imageCount ? _pickedImage : null,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully!'),
            backgroundColor: kSuccessColor,
          ),
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true); // Pop with true to indicate success
      }
    } catch (e) {
      _showErrorSnackBar(itemViewModel.errorMessage ?? 'Failed to save item.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Add New Item' : 'Edit Item',
          style: kHeadingStyle,
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Item Title',
                  border: kDefaultInputBorder,
                  focusedBorder: kFocusedInputBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for the item.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kDefaultPadding),
              if (widget.listType == ListType.imageCount) ...[
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: kDefaultInputBorder,
                    focusedBorder: kFocusedInputBorder,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPadding),
                if (widget.categories != null &&
                    widget.categories!.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryGuid,
                    hint: const Text('Select Category (Optional)'),
                    decoration: InputDecoration(
                      border: kDefaultInputBorder,
                      focusedBorder: kFocusedInputBorder,
                    ),
                    items: widget.categories!.map((category) {
                      return DropdownMenuItem(
                        value: category.guid,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryGuid = value;
                      });
                    },
                  ),
                  const SizedBox(height: kDefaultPadding),
                ],
                // Image Picker
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: kDefaultBorderRadius,
                          border: Border.all(color: Colors.grey.shade300),
                          image: _pickedImage != null
                              ? DecorationImage(
                                  image: FileImage(_pickedImage!),
                                  fit: BoxFit.cover,
                                )
                              : (widget.item?.imageGuid != null &&
                                        widget.item!.imageGuid!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          ApiService().getImageUrl(
                                            widget.item!.imageGuid!,
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child:
                            _pickedImage == null &&
                                (widget.item?.imageGuid == null ||
                                    widget.item!.imageGuid!.isEmpty)
                            ? Icon(
                                Icons.image,
                                size: 60,
                                color: Colors.grey.shade600,
                              )
                            : null,
                      ),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          _pickedImage != null ||
                                  (widget.item?.imageGuid != null &&
                                      widget.item!.imageGuid!.isNotEmpty)
                              ? 'Change Image'
                              : 'Add Image',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (widget.listType == ListType.check) ...[
                SwitchListTile(
                  title: const Text('Checked'),
                  value: _checked,
                  onChanged: (bool newValue) {
                    setState(() {
                      _checked = newValue;
                    });
                  },
                  activeThumbColor: kPrimaryColor,
                ),
              ],
              const SizedBox(height: kLargePadding),
              Consumer<ItemViewModel>(
                builder: (context, itemViewModel, child) {
                  return itemViewModel.isLoading
                      ? const AppLoadingIndicator()
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: kSmallPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: kDefaultBorderRadius,
                            ),
                          ),
                          child: Text(
                            widget.item == null ? 'Add Item' : 'Update Item',
                            style: kBodyTextStyle,
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
