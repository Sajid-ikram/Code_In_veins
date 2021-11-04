import 'package:flutter/material.dart';

Future onError(BuildContext context,String massage) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('An error occurred'),
      content: Text(massage),
      actions: <Widget>[
        TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    ),
  );
}



