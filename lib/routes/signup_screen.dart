import 'package:flutter/material.dart';

import '../widgets/auth/signup_steps_widget.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: const SignupStepsWidget(),
    );
  }
}
