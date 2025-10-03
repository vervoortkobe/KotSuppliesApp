import 'package:flutter/material.dart';
import 'package:kotsupplies/app/widgets/app_loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/view_models/list_view_model.dart';
import 'package:kotsupplies/app/views/lists/list_detail_screen.dart';
import 'package:kotsupplies/app/models/list.dart';

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
    ListModel? joinedList = await listViewModel.joinList(
      _shareCodeController.text,
      widget.userGuid,
    );

    if (joinedList != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined list "${joinedList.title}" successfully!'),
            backgroundColor: kSuccessColor,
          ),
        );
        // Navigate to the joined list and remove join screen from stack
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ListDetailScreen(listGuid: joinedList.guid),
          ),
        );
      }
    } else {
      if (mounted) {
        _showErrorSnackBar(
          listViewModel.errorMessage ?? 'Failed to join list.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join List',
          style: kHeadingStyle.copyWith(color: Colors.white),
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
              Text(
                'Enter the Share Code of an existing list to join it and get access.',
                style: kBodyTextStyle.copyWith(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kDefaultPadding),
              TextFormField(
                controller: _shareCodeController,
                decoration: InputDecoration(
                  labelText: 'Share Code',
                  border: kDefaultInputBorder,
                  focusedBorder: kFocusedInputBorder,
                  prefixIcon: const Icon(Icons.qr_code),
                  helperText: 'Share codes are 6-character codes like "abc123"',
                ),
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the share code.';
                  }
                  if (value.length != 6) {
                    return 'Share codes are exactly 6 characters long.';
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
