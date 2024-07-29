import 'package:flutter/material.dart';

//kullaniciya hata mesaji goster
void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message),
    ),
  );
}

