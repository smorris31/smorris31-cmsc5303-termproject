import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/model/photocomment.dart';
import 'package:termproject/model/photomemo.dart';
import 'package:termproject/viewscreen/view/view_util.dart';
import 'package:termproject/viewscreen/view/webimage.dart';

class AddEditDeletePhotoCommentScreen extends StatefulWidget {
  const AddEditDeletePhotoCommentScreen(
      {required this.user,
      required this.photoMemo,
      required this.photoComment,
      Key? key})
      : super(key: key);

  final PhotoMemo photoMemo;
  final PhotoComment photoComment;
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
        actions: [
          editMode
              ? IconButton(
                  onPressed: con.update,
                  icon: const Icon(
                    Icons.check,
                  ),
                )
              : IconButton(
                  onPressed: con.edit,
                  icon: const Icon(
                    Icons.edit,
                  ),
                ),
          editMode
              ? IconButton(
                  onPressed: con.delete,
                  icon: const Icon(Icons.delete),
                )
              : const SizedBox(
                  height: 1.0,
                ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //Image preview
              Stack(
                children: [
                  SizedBox(
                    //MediaQuery is the device physical height
                    height: MediaQuery.of(context).size.height * .35,
                    child: WebImage(
                      url: con.tempMemo.photoURL,
                      context: context,
                    ),
                  ),
                ],
              ),
              TextFormField(
                enabled: false,
                style: Theme.of(context).textTheme.headline6,
                decoration: const InputDecoration(
                  hintText: 'Enter Title',
                ),
                initialValue: con.tempMemo.title,
              ),
              TextFormField(
                enabled: false,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: const InputDecoration(
                  hintText: 'Enter Memo',
                ),
                initialValue: con.tempMemo.memo,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
              ),
              TextFormField(
                enabled: false,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: const InputDecoration(
                  hintText: 'Enter Shared With: email list',
                ),
                //We can seperate using any of the split items set earlier
                initialValue: con.tempMemo.sharedWith.join(' '),
                keyboardType: TextInputType.emailAddress,
                maxLines: 2,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: const InputDecoration(
                  hintText: 'Enter Comments...',
                ),
                //initialValue: con.tempComment.comment,
                initialValue: '',
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoComment.validateComment,
                onSaved: con.saveComment,
              ),
              Constant.devMode
                  ? Text('Image Labels by ML\n${con.tempMemo.imageLabels}')
                  : const SizedBox(
                      height: 1.0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _AddEditDeleteCommentState state;
  late PhotoMemo tempMemo;
  late PhotoComment tempComment;
  //The constructor
  ////Assign state object
  _Controller(this.state) {
    //use the photoMemo sent to this screen to make the clone
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
    //tempComment = PhotoComment.clone
  }

  void update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    //all onSave functions will be called
    currentState.save();

    startCircularProgress(state.context);

    try {
      Map<String, dynamic> update = {};
      //Update firestore comment
      if (update.isNotEmpty) {
        //change has been made
        tempMemo.timestamp = DateTime.now();
        update[DocKeyPhotoMemo.timestamp.name] = tempMemo.timestamp;
        await FirestoreController.updatePhotoMemo(
            docId: tempMemo.docId!, update: update);

        //We not need to update the original
        state.widget.photoMemo.copyFrom(tempMemo);
      }
      stopCircularProgress(state.context);
      state.render(() => state.editMode = false);
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('========= failed to update: $e');
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: '========= failed to update: $e');
    }
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void delete() {}

  void saveComment(String? value) {}
}
