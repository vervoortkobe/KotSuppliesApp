import 'package:flutter/material.dart';
import 'package:kotsupplies/app/widgets/app_loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/view_models/list_view_model.dart';

class JoinListScreen extends StatefulWidget {
  final String userGuid;

  const JoinListScreen({super.key, required this.userGuid});

  @override
  JoinListScreenState createState() => JoinListScreenState();
}

class JoinListScreenState extends State<JoinListScreen> {
  final _shareCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kErrorColor),
    );
  }

  Future<void> _joinList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final listViewModel = Provider.of<ListViewModel>(context, listen: false);
    bool success = await listViewModel.joinList(
      _shareCodeController.text,
      widget.userGuid,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined list successfully!'),
          backgroundColor: kSuccessColor,
        ),
      );
      Navigator.of(context).pop(true); // Pop with true to indicate success
    } else {
      _showErrorSnackBar(listViewModel.errorMessage ?? 'Failed to join list.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join List', style: kHeadingStyle),
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
              Text(
                'Enter the List GUID (or Share Code, if your API supports it) to join an existing list.',
                style: kBodyTextStyle.copyWith(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kDefaultPadding),
              TextFormField(
                controller: _shareCodeController,
                decoration: InputDecoration(
                  labelText: 'List GUID / Share Code',
                  border: kDefaultInputBorder,
                  focusedBorder: kFocusedInputBorder,
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the list GUID or share code.';
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
                          onPressed: _joinList,
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
                          child: const Text('Join List', style: kBodyTextStyle),
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
