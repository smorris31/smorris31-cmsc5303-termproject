import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:termproject/controller/cloudstorage_controller.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/controller/ml_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/model/photocomment.dart';
import 'package:termproject/model/reply.dart';
import 'package:termproject/model/viewsharedphoto.dart';
import 'package:termproject/viewscreen/commentreply_screen.dart';
import 'package:termproject/viewscreen/view/view_util.dart';
import 'package:termproject/viewscreen/view/webimage.dart';
import '../model/photomemo.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';

  final User user;

  // ignore: slash_for_doc_comments
  /** If we make changes to the COPY of photoMemo object in this page
   * we still need to get the COPY back to the original in Firestore
   * We will have to define a clone() to temporarily hold the changes
   * and then copy contents back to the original using a copy from
   */
  final PhotoMemo photoMemo;
  final List<PhotoComment> photoComments;

  const DetailedViewScreen(
      {required this.user,
      required this.photoMemo,
      required this.photoComments,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  late _Controller con;
  bool editMode = false;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    con.updatePhotoCommentsCollection();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail View Screen'),
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
                      child: con.photo == null
                          ? WebImage(
                              url: con.tempMemo.photoURL,
                              context: context,
                            )
                          : Image.file(con.photo!)),
                  editMode
                      ? Positioned(
                          right: 0.0,
                          bottom: 0.0,
                          child: Container(
                            color: Colors.blue[200],
                            child: PopupMenuButton(
                              onSelected: con.getPhoto,
                              //context will be provided
                              itemBuilder: (context) => [
                                for (var source in PhotoSource.values)
                                  PopupMenuItem(
                                    value: source,
                                    child: Text(source.name),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(
                          height: 1.0,
                        ),
                  Positioned(
                    left: 0.0,
                    bottom: 0.0,
                    child: con.progressMessage == null
                        ? const SizedBox(
                            height: 1.0,
                          )
                        : Container(
                            color: Colors.blue[200],
                            child: Text(
                              con.progressMessage!,
                              style: Theme.of(context).textTheme.headline6,
                            )),
                  ),
                ],
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: const InputDecoration(
                  hintText: 'Enter Title',
                ),
                initialValue: con.tempMemo.title,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: const InputDecoration(
                  hintText: 'Enter Memo',
                ),
                initialValue: con.tempMemo.memo,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: const InputDecoration(
                  hintText: 'Enter Shared With: email list',
                ),
                //We can seperate using any of the split items set earlier
                initialValue: con.tempMemo.sharedWith.join(' '),
                keyboardType: TextInputType.emailAddress,
                maxLines: 2,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
              Constant.devMode
                  ? Text('Image Labels by ML\n${con.tempMemo.imageLabels}')
                  : const SizedBox(
                      height: 1.0,
                    ),
              widget.photoComments.isEmpty
                  ? Text(
                      'No Comments have been added!',
                      style: Theme.of(context).textTheme.headline6,
                    )
                  : Column(
                      children: [
                        for (var comment in widget.photoComments)
                          Card(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Comment by: ${comment.createdBy}',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text(comment.createDate.toString()),
                                const Text(''),
                                Text(
                                  comment.comment,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                ElevatedButton(
                                  onPressed: () => con.replyToComment(comment),
                                  child: const Text('Reply'),
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _DetailedViewState state; //State object
  //Set to late to set the value later
  late PhotoMemo tempMemo;
  late PhotoComment tempComment;
  //define reference photo object
  File? photo;
  String? progressMessage;

  //The constructor
  ////Assign state object
  _Controller(this.state) {
    //use the photoMemo sent to this screen to make the clone
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  }

  void updatePhotoCommentsCollection() async {
    for (int i = state.widget.photoComments.length - 1; i >= 0; i--) {
      state.widget.photoComments[i].dateRead = DateTime.now();
      state.widget.photoComments[i].read = true;
      await FirestoreController.updatePhotoComment(
        docId: state.widget.photoComments[i].docId!,
        update: state.widget.photoComments[i].toFirestoreDoc(),
      );
    }
    Map<String, dynamic> update = {};
    update[DocKeyPhotoMemo.commentsAdded.name] = false;
    await FirestoreController.updatePhotoMemo(
        docId: tempMemo.docId!, update: update);
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
      if (photo != null) {
        Map result = await CloudStorageController.uploadPhotoFile(
          photo: photo!,
          filename: tempMemo.photoFilename,
          uid: state.widget.user.uid,
          listener: (int progress) {
            state.render(() {
              progressMessage =
                  progress == 100 ? null : 'Uploading: $progress %';
            });
          },
        );
        //once image is done load get URL
        tempMemo.photoURL = result[ArgKey.downloadURL];
        update[DocKeyPhotoMemo.photoURL.name] = tempMemo.photoURL;
        tempMemo.imageLabels =
            await GoogleMLController.getImageLables(photo: photo!);
        update[DocKeyPhotoMemo.imageLabels.name] = tempMemo.imageLabels;
        tempMemo.imageText = await GoogleMLController.getImageText(photo: photo!);
        update[DocKeyPhotoMemo.imageText.name] = tempMemo.imageText;
      }

      //Update firestore doc
      if (tempMemo.title != state.widget.photoMemo.title) {
        update[DocKeyPhotoMemo.title.name] = tempMemo.title;
      }
      if (tempMemo.memo != state.widget.photoMemo.memo) {
        update[DocKeyPhotoMemo.memo.name] = tempMemo.memo;
      }
      if (!listEquals(tempMemo.sharedWith, state.widget.photoMemo.sharedWith)) {
        update[DocKeyPhotoMemo.sharedWith.name] = tempMemo.sharedWith;
        for (int i = 0; i <= tempMemo.sharedWith.length - 1; i++) {
          ViewSharedPhoto sharedWith = ViewSharedPhoto();
          sharedWith.dateShared = DateTime.now();
          sharedWith.photoCollectionID = tempMemo.docId!;
          sharedWith.sharedWithEmail = tempMemo.sharedWith[i];
          sharedWith.sharedBy = tempMemo.createdBy;
          String shareDocID =
              await FirestoreController.addNewShareEntry(newShare: sharedWith);
          sharedWith.docId = shareDocID;
          //state.widget.newShareList.insert(0, sharedWith);
        }
      }

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

  void replyToComment(PhotoComment p) async {
    List<PhotoCommentReply> commentReplies;

    commentReplies =
        await FirestoreController.getCommentReplies(commentId: p.docId!);

    await Navigator.pushNamed(state.context, CommentReply.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.photoComments: p,
          ArgKey.photoCommentReply: commentReplies});
  }

  void getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return;
      state.render(() => photo = File(image.path));
    } catch (e) {
      if (Constant.devMode) print('====== Failed to get a pic: $e');
      showSnackBar(
          context: state.context, message: '====== Failed to get a pic: $e');
    }
  }

  void saveTitle(String? value) {
    if (value != null) {
      tempMemo.title = value;
    }
  }

  void saveMemo(String? value) {
    if (value != null) {
      tempMemo.memo = value;
    }
  }

  void saveSharedWith(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      var emailList =
          value.trim().split(RegExp('(,|;| )+')).map((e) => e.trim()).toList();
      tempMemo.sharedWith = emailList;
    } else {
      tempMemo.sharedWith = [];
    }
  }
}
