import 'package:flutter/material.dart';
import 'package:battleships/utils/http_service.dart';

class RegistrationPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  HttpService httpService = HttpService();

  RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Add padding here
        child: Form(
          child: Column(
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
              ),
              TextButton(
                onPressed: () {
                  httpService
                      .registerUser(usernameController.text,
                          passwordController.text, context)
                      .then((response) {
                    if (response['statusCode'] == 200) {
                      httpService.showAlertDialog(context,
                          'Registration Successful', 'You can now login');
                    } else {
                      httpService.showAlertDialog(
                          context, 'Registration Failed', response['message']);
                    }
                  });
                },
                child: const Text(
                  'Register New Account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
