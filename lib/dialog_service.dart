import 'package:flutter/material.dart';
import 'package:reply_dialogs/dialog_result.dart';

class DialogServiceWithContext {
  final BuildContext _context;
  final DialogService _dialogService;

  DialogServiceWithContext(this._dialogService, this._context);

  void showSnackBar(String message, [String? moreInformation]) {
    _dialogService.showSnackBar(_context, message, moreInformation);
  }

  Future<bool> showMessage(String title, String message,
      {String? cancel, String? accept, String? moreInformation}) {
    return _dialogService.showMessage(
      _context,
      title,
      message,
      accept: accept,
      cancel: cancel,
      moreInformation: moreInformation,
    );
  }

  Future<DialogResult<T>?> showSelectList<T>({
    required String title,
    required List<T> options,
    T? selectedOption,
    String Function(T)? toStringFunction,
    bool multiSelect = false,
  }) {
    return _dialogService.showSelectList(
      context: _context,
      title: title,
      options: options,
      selectedOption: selectedOption,
      toStringFunction: toStringFunction,
      multiSelect: multiSelect,
    );
  }
}

class DialogService {
  static DialogServiceWithContext of(BuildContext context) {
    return DialogServiceWithContext(DialogService(), context);
  }

  void showSnackBar(BuildContext context, String message,
      [String? moreInformation]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (moreInformation != null)
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (moreInformation != null)
              GestureDetector(
                onTap: () =>
                    showMessage(context, 'More Information', moreInformation),
                child: Text(
                  'More Information',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> showMessage(BuildContext context, String title, String message,
      {String? cancel, String? accept, String? moreInformation}) async {
    final List<Widget> actionWidgets = <Widget>[];

    bool result = false;

    // Add cancel button
    if (cancel == null || cancel.isEmpty) {
      cancel = 'OK';
    }

    actionWidgets.add(
      MaterialButton(
        child: Text(
          cancel.toUpperCase(),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );

    // Add accept button
    if (accept != null && accept.isNotEmpty) {
      actionWidgets.add(
        MaterialButton(
          child: Text(
            accept.toUpperCase(),
          ),
          onPressed: () {
            result = true;
            Navigator.of(context).pop();
          },
        ),
      );
    }

    // Display alert dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          scrollable: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message),
              if (moreInformation != null)
                GestureDetector(
                  onTap: () => showMessage(
                    context,
                    'More Information',
                    moreInformation,
                  ),
                  child: const Text(
                    'More Information',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
            ],
          ),
          actions: actionWidgets,
        );
      },
    );

    return result;
  }

  Future<DialogResult<T>?> showSelectList<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    T? selectedOption,
    String Function(T)? toStringFunction,
    bool multiSelect = false,
  }) async {
    final result = await showDialog<DialogResult<T>>(
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              margin: const EdgeInsets.all(32.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 100.0,
                        maxHeight: 250.0,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: options
                            .map(
                              (e) => ListTile(
                                onTap: () {
                                  Navigator.of(context)
                                      .pop(DialogResult<T>(value: e));
                                },
                                title: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        toStringFunction?.call(e) ??
                                            e.toString(),
                                      ),
                                      const SizedBox(height: 8.0),
                                      const Divider(
                                        color: Colors.grey,
                                        height: 1,
                                        thickness: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(
                                  DialogResult<String>(),
                                );
                              },
                              child: const Text('CLEAR'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(
                                  DialogResult<String>(cancelled: true),
                                );
                              },
                              child: const Text('CANCEL'),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    return result;
  }
}
