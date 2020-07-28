import 'package:flutter/material.dart';

class SignUpTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;

  SignUpTextField({
    this.hintText,
    this.isPassword,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      child: TextField(
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        obscureText: isPassword ? true : false,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
