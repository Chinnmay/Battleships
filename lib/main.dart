import 'package:battleships/views/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      title: 'Battleship Galactica!',
      home: const LoginScreen()));
}
