import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/controller/auth_controller.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/model/photomemo.dart';
import 'package:termproject/model/viewsharedphoto.dart';
import 'package:termproject/viewscreen/signup_screen.dart';
import 'package:termproject/viewscreen/userhome_screen.dart';
import 'package:termproject/viewscreen/view/view_util.dart';

class StartScreen extends StatefulWidget {
  static const routeName = '/startscreen';

  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StartState();
  }
}

class _StartState extends State<StartScreen> {
  late _Controller con;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Screen'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  'PhotoMemo',
                  style: Theme.of(context).textTheme.headline3,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  autocorrect: false,
                  obscureText: true,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                ElevatedButton(
                  onPressed: con.signIn,
                  child: Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                OutlinedButton(
                  onPressed: con.signUp,
                  child: Text('Create a new account', style: Theme.of(context).textTheme.button,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _StartState state;
  String? email;
  String? password;
  _Controller(this.state);

  void signIn() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();

    startCircularProgress(state.context);

    User? user;
    try {
      if (email == null || password == null) {
        throw 'Email or Password is null';
      }      
      user = await AuthController.signIn(email: email!, password: password!);
      //Before navigating to user home get list of photos
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoList(email: email!);
      print("************** Got Photomemos ***********");

      print("************** Get ViewSharedPhotos ***********");
      List<ViewSharedPhoto> newShares = 
          await FirestoreController.getNewPhotoShares(email: email!);
      print('########## Retrived ViewSharedPhotos ##############');
      stopCircularProgress(state.context);

      Navigator.pushNamed(
        state.context,
        UserHomeScreen.routeName,
        //you can use a key value map as the arguments
        //this mapping will be held in constant.dart
        arguments: {
          ArgKey.user: user,
          ArgKey.photomemolist:
              photoMemoList, //These are just point to the array list
          ArgKey.newShareList: newShares,
        },
      );
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('*********** SignIn Error: $e');
      showSnackBar(
          context: state.context, seconds: 20, message: 'SignIn Error: $e');
    }
  }

void signUp() {
  Navigator.pushNamed(state.context, SignUpScreen.routeName);
}


  String? validateEmail(String? value) {
    if (value == null) {
      return 'No Email provided';
    } else if (!(value.contains('@') && value.contains('.'))) {
      return 'Invalid Email format';
    } else {
      return null;
    }
  }

  void saveEmail(String? value) {
    if (value != null) {
      email = value;
    }
  }

  String? validatePassword(String? value) {
    if (value == null) {
      return 'Password Not Provided';
    } else if (value.length < 6) {
      return 'Password too short';
    } else {
      return null;
    }
  }

  void savePassword(String? value) {
    if (value != null) {
      password = value;
    }
  }
}
