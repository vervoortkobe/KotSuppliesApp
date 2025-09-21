import 'package:flutter/material.dart';
import 'package:kotsupplies/app/widgets/app_loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/view_models/list_view_model.dart';

class CreateListScreen extends StatefulWidget {
  const CreateListScreen({Key? key}) : super(key: key);

  @override
  _CreateListScreenState createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ListType? _selectedListType;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kErrorColor),
    );
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedListType == null) {
      _showErrorSnackBar('Please select a list type.');
      return;
    }

    final listViewModel = Provider.of<ListViewModel>(context, listen: false);
    final newList = await listViewModel.createList(
      _titleController.text,
      _selectedListType!,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
    );

    if (newList != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('List "${newList.title}" created successfully!'),
          backgroundColor: kSuccessColor,
        ),
      );
      Navigator.of(context).pop(true); // Pop with true to indicate success
    } else {
      _showErrorSnackBar(
        listViewModel.errorMessage ?? 'Failed to create list.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New List', style: kHeadingStyle),
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
                  labelText: 'List Title',
                  border: kDefaultInputBorder,
                  focusedBorder: kFocusedInputBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for your list.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kDefaultPadding),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: kDefaultInputBorder,
                  focusedBorder: kFocusedInputBorder,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: kDefaultPadding),
              DropdownButtonFormField<ListType>(
                value: _selectedListType,
                hint: const Text('Select List Type'),
                decoration: InputDecoration(
                  border: kDefaultInputBorder,
                  focusedBorder: kFocusedInputBorder,
                ),
                items: ListType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type
                          .toString()
                          .split('.')
                          .last
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedListType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a list type.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kLargePadding),
              Consumer<ListViewModel>(
                builder: (context, listViewModel, child) {
                  return listViewModel.isLoading
                      ? const AppLoadingIndicator()
                      : ElevatedButton(
                          onPressed: _createList,
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
                          child: const Text(
                            'Create List',
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
