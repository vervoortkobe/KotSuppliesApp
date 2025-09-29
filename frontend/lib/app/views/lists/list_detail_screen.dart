import 'package:flutter/material.dart';
import 'package:kotsupplies/app/view_models/list_view_model.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/models/item.dart';
import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/services/api_service.dart';
import 'package:kotsupplies/app/view_models/item_view_model.dart';
import 'package:kotsupplies/app/view_models/auth_view_model.dart';
import 'package:kotsupplies/app/widgets/app_loading_indicator.dart';
import 'package:kotsupplies/app/views/categories/category_management_screen.dart';
import 'package:kotsupplies/app/views/items/item_form_screen.dart';

class ListDetailScreen extends StatefulWidget {
  final String listGuid;

  const ListDetailScreen({super.key, required this.listGuid});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  String? _selectedCategoryGuid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemViewModel>(
        context,
        listen: false,
      ).fetchListDetails(widget.listGuid);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kErrorColor),
    );
  }

  Future<void> _toggleItemChecked(Item item) async {
    final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
    try {
      await itemViewModel.updateItem(
        widget.listGuid,
        item,
        checked: !item.checked,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update item: $e');
    }
  }

  Future<void> _incrementItemAmount(Item item) async {
    final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
    try {
      await itemViewModel.updateItem(
        widget.listGuid,
        item,
        amount: (item.amount ?? 0) + 1,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update item: $e');
    }
  }

  Future<void> _decrementItemAmount(Item item) async {
    final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
    if ((item.amount ?? 0) > 0) {
      try {
        await itemViewModel.updateItem(
          widget.listGuid,
          item,
          amount: (item.amount ?? 0) - 1,
        );
      } catch (e) {
        _showErrorSnackBar('Failed to update item: $e');
      }
    }
  }

  Future<void> _deleteItem(String itemGuid) async {
    final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
    try {
      await itemViewModel.deleteItem(widget.listGuid, itemGuid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted successfully!'),
          backgroundColor: kSuccessColor,
        ),
      );
    } catch (e) {
      _showErrorSnackBar(
        itemViewModel.errorMessage ?? 'Failed to delete item.',
      );
    }
  }

  void _navigateToItemForm({Item? item}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(
          listGuid: widget.listGuid,
          listType: Provider.of<ItemViewModel>(
            context,
            listen: false,
          ).currentList!.type,
          item: item,
          categories: Provider.of<ItemViewModel>(
            context,
            listen: false,
          ).currentList!.categories,
        ),
      ),
    );
    if (result == true) {
      Provider.of<ItemViewModel>(
        context,
        listen: false,
      ).fetchListDetails(widget.listGuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ItemViewModel, AuthViewModel>(
      builder: (context, itemViewModel, authViewModel, child) {
        final list = itemViewModel.currentList;
        final currentUser = authViewModel.currentUser;

        if (itemViewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Loading List...',
                style: kHeadingStyle.copyWith(color: Colors.white),
              ),
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
            body: const AppLoadingIndicator(),
          );
        }

        if (itemViewModel.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Error',
                style: kHeadingStyle.copyWith(color: Colors.white),
              ),
              backgroundColor: kErrorColor,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Text(
                  itemViewModel.errorMessage!,
                  style: kBodyTextStyle.copyWith(color: kErrorColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (list == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'List Not Found',
                style: kHeadingStyle.copyWith(color: Colors.white),
              ),
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Text(
                'List details could not be loaded.',
                style: kBodyTextStyle,
              ),
            ),
          );
        }

        final List<Item> filteredItems = _selectedCategoryGuid == null
            ? list.items ?? []
            : (list.items ?? [])
                  .where((item) => item.category?.guid == _selectedCategoryGuid)
                  .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              list.title,
              style: kHeadingStyle.copyWith(color: Colors.white),
            ),
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            actions: [
              if (list.type == ListType.image_count)
                IconButton(
                  icon: const Icon(Icons.category),
                  tooltip: 'Manage Categories',
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryManagementScreen(listGuid: list.guid),
                      ),
                    );
                    if (result == true) {
                      itemViewModel.fetchListDetails(
                        widget.listGuid,
                      ); // Refresh list
                    }
                  },
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit List',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Edit List functionality not yet implemented.',
                      ),
                    ),
                  );
                },
              ),
              if (currentUser != null) ...[
                IconButton(
                  icon: const Icon(Icons.info),
                  tooltip: 'Debug Info',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Debug Info'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current User: ${currentUser.guid}'),
                            Text('List Creator: ${list.creatorGuid}'),
                            Text(
                              'Are Equal: ${list.creatorGuid == currentUser.guid}',
                            ),
                            Text(
                              'Current User Username: ${currentUser.username}',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Creator gets delete button
                if (list.creatorGuid == currentUser.guid)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete List',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: Text(
                            'Are you sure you want to delete "${list.title}"? This cannot be undone.',
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
                        try {
                          await Provider.of<ListViewModel>(
                            context,
                            listen: false,
                          ).deleteList(list.guid, currentUser.guid);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('List "${list.title}" deleted.'),
                                backgroundColor: kSuccessColor,
                              ),
                            );
                            Navigator.of(context).pop(true);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete list: $e'),
                                backgroundColor: kErrorColor,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                // Non-creator gets leave button
                if (list.creatorGuid != currentUser.guid)
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    tooltip: 'Leave List',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Leave'),
                          content: Text(
                            'Are you sure you want to leave "${list.title}"?',
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
                              child: const Text('Leave'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await Provider.of<ListViewModel>(
                            context,
                            listen: false,
                          ).leaveList(list.guid, currentUser.guid);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Left list "${list.title}".'),
                                backgroundColor: kSuccessColor,
                              ),
                            );
                            Navigator.of(context).pop(true);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to leave list: $e'),
                                backgroundColor: kErrorColor,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
              ],
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.description ?? 'No description provided.',
                      style: kBodyTextStyle.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: kSmallPadding),
                    Text(
                      'Share Code: ${list.shareCode}',
                      style: kSmallTextStyle.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (list.type == ListType.image_count &&
                        list.categories != null &&
                        list.categories!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: kDefaultPadding),
                          Text(
                            'Categories:',
                            style: kSubtitleStyle.copyWith(fontSize: 16),
                          ),
                          DropdownButton<String>(
                            value: _selectedCategoryGuid,
                            hint: const Text('All Categories'),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...list.categories!.map(
                                (category) => DropdownMenuItem(
                                  value: category.guid,
                                  child: Text(category.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryGuid = value;
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          'No items in this list yet.',
                          style: kBodyTextStyle.copyWith(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding,
                              vertical: kSmallPadding / 2,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: kDefaultBorderRadius,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(kDefaultPadding),
                              child: Row(
                                children: [
                                  if (list.type == ListType.image_count &&
                                      item.imageGuid != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: kDefaultPadding,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: kDefaultBorderRadius,
                                        child: Image.network(
                                          ApiService().getImageUrl(
                                            item.imageGuid!,
                                          ),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 60,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: kBodyTextStyle.copyWith(
                                            fontWeight: FontWeight.w600,
                                            decoration: item.checked
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if (item.category != null)
                                          Text(
                                            'Category: ${item.category!.name}',
                                            style: kSmallTextStyle.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (list.type == ListType.image_count)
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: kErrorColor,
                                          ),
                                          onPressed: () =>
                                              _decrementItemAmount(item),
                                        ),
                                        Text(
                                          '${item.amount ?? 0}',
                                          style: kBodyTextStyle,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: kSuccessColor,
                                          ),
                                          onPressed: () =>
                                              _incrementItemAmount(item),
                                        ),
                                      ],
                                    ),
                                  if (list.type == ListType.check)
                                    Checkbox(
                                      value: item.checked,
                                      onChanged: (bool? newValue) {
                                        if (newValue != null) {
                                          _toggleItemChecked(item);
                                        }
                                      },
                                      activeColor: kPrimaryColor,
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () =>
                                        _navigateToItemForm(item: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: kErrorColor,
                                    ),
                                    onPressed: () => _deleteItem(item.guid),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToItemForm(),
            label: const Text('Add Item'),
            icon: const Icon(Icons.add),
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
