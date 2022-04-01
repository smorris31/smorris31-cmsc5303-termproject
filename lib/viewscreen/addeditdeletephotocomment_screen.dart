import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/model/photomemo.dart';

class AddEditDeletePhotoCommentScreen extends StatefulWidget {
  const AddEditDeletePhotoCommentScreen(
      {required this.user, 
      required this.photoMemo, Key? key})
      : super(key: key);

  final PhotoMemo photoMemo;
  final User user;

  static const routeName = '/addeditdeletephotocomment';
  @override
  State<StatefulWidget> createState() {
    return _AddEditDeleteCommentState();
  }
}

class _AddEditDeleteCommentState
    extends State<AddEditDeletePhotoCommentScreen> {
  late _Controller con;
  bool editMode = false;
  var formKey = GlobalKey<FormState>();

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
        title: const Text('Add/Edit/Delete Comments'),
      ),
      body: const Text('Add/Edit/Delete Comments'),
    );
  }
}

class _Controller {
  _AddEditDeleteCommentState state;
  late PhotoMemo photoMemo;
  _Controller(this.state);
}
