import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  String tittle;
  String description;
  MyAlertDialog({super.key,required this.tittle,required this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tittle),
      content: Text(description),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}