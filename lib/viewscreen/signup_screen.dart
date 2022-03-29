import 'package:flutter/material.dart';
import 'package:termproject/controller/auth_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/viewscreen/view/view_util.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signupscreen';

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  late _Controller con;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Text(
                  'Create a new account',
                  style: Theme.of(context).textTheme.headline5,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Passord',
                  ),
                  autocorrect: false,
                  obscureText: true,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Confirm Passord',
                  ),
                  autocorrect: false,
                  obscureText: true,
                  validator: con.validatePassword,
                  onSaved: con.saveConfirmPassword,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  onPressed: con.signUp,
                  child: Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.button,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignUpState state;
  _Controller(this.state);

  String? email;
  String? password;
  String? confirmPassword;

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('@') && value.contains('.'))) {
      return 'Invalid Email';
    } else {
      return null;
    }
  }

  void saveEmail(String? value) {
    email = value;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password too short (min 6 chars)';
    } else {
      return null;
    }
  }

  void savePassword(String? value) {
    password = value;
  }

  void saveConfirmPassword(String? value) {
    confirmPassword = value;
  }

  void signUp() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    if (password != confirmPassword) {
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'Passords do not match');
      return;
    }

    try {
      await AuthController.createAccount(email: email!, password: password!);
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: 'Account Created! Sign In and use the app!',
      );
    } catch (e) {
      if (Constant.devMode) print('========= Sign up Failed: $e');
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: '========= Sign up Failed: $e',
      );
    }
  }
}
