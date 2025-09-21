import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/models/category.dart';
import 'package:kotsupplies/app/view_models/item_view_model.dart';
import 'package:kotsupplies/app/widgets/app_loading_indicator.dart';

class CategoryManagementScreen extends StatefulWidget {
  final String listGuid;

  const CategoryManagementScreen({Key? key, required this.listGuid})
    : super(key: key);

  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _categoryNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kErrorColor),
    );
  }

  Future<void> _createOrUpdateCategory({Category? categoryToEdit}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
    bool success = false;
    String action = categoryToEdit == null ? 'created' : 'updated';

    try {
      if (categoryToEdit == null) {
        await itemViewModel.createCategory(
          widget.listGuid,
          _categoryNameController.text,
        );
      } else {
        await itemViewModel.updateCategory(
          widget.listGuid,
          categoryToEdit.guid,
          _categoryNameController.text,
        );
      }
      success = true;
    } catch (e) {
      _showErrorSnackBar(
        itemViewModel.errorMessage ?? 'Failed to $action category.',
      );
    }

    if (success) {
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category $action successfully!'),
          backgroundColor: kSuccessColor,
        ),
      );
      // No need to call fetchListDetails explicitly here, itemViewModel handles notifyListeners
    }
  }

  Future<void> _deleteCategory(String categoryGuid, String categoryName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete category "$categoryName"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kErrorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
      try {
        await itemViewModel.deleteCategory(widget.listGuid, categoryGuid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category deleted successfully!'),
            backgroundColor: kSuccessColor,
          ),
        );
      } catch (e) {
        _showErrorSnackBar(
          itemViewModel.errorMessage ?? 'Failed to delete category.',
        );
      }
    }
  }

  void _showCategoryFormDialog({Category? category}) {
    _categoryNameController.text = category?.name ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Add New Category' : 'Edit Category'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _categoryNameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              border: kDefaultInputBorder,
              focusedBorder: kFocusedInputBorder,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a category name.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          Consumer<ItemViewModel>(
            builder: (context, itemViewModel, child) {
              return itemViewModel.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () =>
                          _createOrUpdateCategory(categoryToEdit: category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(category == null ? 'Add' : 'Update'),
                    );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories', style: kHeadingStyle),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ItemViewModel>(
        builder: (context, itemViewModel, child) {
          if (itemViewModel.isLoading) {
            return const AppLoadingIndicator();
          }
          if (itemViewModel.errorMessage != null) {
            return Center(
              child: Text(itemViewModel.errorMessage!, style: kErrorTextStyle),
            );
          }
          final categories = itemViewModel.currentList?.categories ?? [];
          if (categories.isEmpty) {
            return Center(
              child: Text(
                'No categories yet. Add one!',
                style: kBodyTextStyle.copyWith(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: kSmallPadding / 2,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: kDefaultBorderRadius,
                ),
                child: ListTile(
                  title: Text(
                    category.name,
                    style: kBodyTextStyle.copyWith(fontWeight: FontWeight.w500),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            _showCategoryFormDialog(category: category),
                      ),
                      if (category.name !=
                          'uncategorized') // Cannot delete default category as per API
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: kErrorColor,
                          ),
                          onPressed: () =>
                              _deleteCategory(category.guid, category.name),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryFormDialog(),
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
