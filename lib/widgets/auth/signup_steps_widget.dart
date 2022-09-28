import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/providers.dart';

import '../../routes.dart';

// ? Not sure if FocusNodes are working. Need to test on an emulator.

class SignupStepsWidget extends ConsumerStatefulWidget {
  const SignupStepsWidget({super.key});

  @override
  SignupStepsWidgetState createState() => SignupStepsWidgetState();
}

class SignupStepsWidgetState extends ConsumerState<SignupStepsWidget> {
  int _index = 0;

  bool isForm1Valid = false;
  bool isForm2Valid = false;

  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();

  final usernameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  final nameFocusNode = FocusNode();
  final bioFocusNode = FocusNode();
  final locationFocusNode = FocusNode();
  final websiteFocusNode = FocusNode();

  // Credential Existance Check variables
  bool emailExists = false;
  bool usernameExists = false;

  // Controllers of Form 1
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  // Controllers of Form 2
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();
  final websiteController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    nameController.dispose();
    bioController.dispose();
    locationController.dispose();
    websiteController.dispose();

    usernameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    nameFocusNode.dispose();
    bioFocusNode.dispose();
    locationFocusNode.dispose();
    websiteFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRegisterer = ref.watch(userRegisterProvider.notifier);
    final userRegistererState = ref.watch(userRegisterProvider);

    return Stepper(
      currentStep: _index,
      onStepCancel: () {
        if (_index == 0) {
          Navigator.of(context).pushNamed(RouteGenerator.login);
        }
        if (_index > 0) {
          setState(() {
            _index--;
          });
        }
      },
      onStepContinue: () async {
        if (_index == 0) {
          await form1Submit(userRegisterer, userRegistererState);
        }
        if (_index == 1) {
          if (!mounted) return;
          await form2Submit(userRegistererState, userRegisterer, context);
        }
      },
      steps: [
        Step(
          title: const Text('Credentials'),
          isActive: _index == 0,
          state: _index == 0
              ? StepState.editing
              : (isForm1Valid ? StepState.complete : StepState.indexed),
          content: Form(
            key: step1FormKey,
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  focusNode: usernameFocusNode,
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    if (usernameExists) {
                      return 'Username already exists';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    usernameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(emailFocusNode);
                  },
                ),
                TextFormField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    if (emailExists) {
                      return 'Email already exists';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    emailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(passwordFocusNode);
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) async {
                    passwordFocusNode.unfocus();
                    await form1Submit(userRegisterer, userRegistererState);
                    nameFocusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),
        ),
        Step(
          title: const Text('Profile Info'),
          isActive: _index == 1,
          state: _index == 1
              ? StepState.editing
              : (isForm2Valid ? StepState.complete : StepState.indexed),
          content: Form(
            key: step2FormKey,
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  focusNode: nameFocusNode,
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    nameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(bioFocusNode);
                  },
                ),
                TextFormField(
                  focusNode: bioFocusNode,
                  controller: bioController,
                  maxLength: 240,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                  ),
                  onFieldSubmitted: (value) {
                    bioFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(locationFocusNode);
                  },
                ),
                TextFormField(
                  focusNode: locationFocusNode,
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                  ),
                  onFieldSubmitted: (value) {
                    locationFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(websiteFocusNode);
                  },
                ),
                TextFormField(
                  focusNode: websiteFocusNode,
                  controller: websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                  ),
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      // check if website is valid with regex
                      final r = RegExp(
                          r'^(http(s)?:\/\/)?((w){3}.)?([A-Za-z0-9-]+\.)+[A-Za-z]{2,64}\/?$');
                      if (!r.hasMatch(value)) {
                        return 'Please enter a valid website';
                      }
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) async {
                    await form2Submit(
                        userRegistererState, userRegisterer, context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> form2Submit(Map<String, String> userRegistererState,
      UserRegister userRegisterer, BuildContext context) async {
    if (step2FormKey.currentState!.validate()) {
      isForm2Valid = true;
      userRegistererState['name'] = nameController.text;
      userRegistererState['bio'] = bioController.text;
      userRegistererState['location'] = locationController.text;
      userRegistererState['website'] = websiteController.text;
      if (await userRegisterer.tryRegister()) {
        Navigator.of(context).pushReplacementNamed(RouteGenerator.home);
      }
    }
  }

  Future<void> form1Submit(UserRegister userRegisterer,
      Map<String, String> userRegistererState) async {
    emailExists =
        await userRegisterer.checkEmailExists(emailController.text.trim());
    usernameExists = await userRegisterer
        .checkUsernameExists(usernameController.text.trim());
    if (step1FormKey.currentState!.validate()) {
      isForm1Valid = true;
      userRegistererState['email'] = emailController.text;
      userRegistererState['password'] = passwordController.text;
      userRegistererState['username'] = usernameController.text;
      setState(() {
        _index++;
        nameFocusNode.requestFocus();
      });
    }
  }
}
