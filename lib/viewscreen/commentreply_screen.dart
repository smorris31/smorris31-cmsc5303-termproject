import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/model/photocomment.dart';
import 'package:termproject/model/reply.dart';
import 'package:termproject/viewscreen/view/view_util.dart';

class CommentReply extends StatefulWidget {
  const CommentReply(
      {required this.user,
      required this.photoComment,
      required this.photoCommentReply,
      Key? key})
      : super(key: key);

  final PhotoComment photoComment;
  final User user;
  final List<PhotoCommentReply> photoCommentReply;

  static const routeName = '/replycomment';

  @override
  State<StatefulWidget> createState() {
    return _CommentReplyState();
  }
}

class _CommentReplyState extends State<CommentReply> {
  late _Controller con;
  bool editMode = false;
  late bool updatable;
  var formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    _textController.clear();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply to Comments'),
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
              Text(
                'Comment: ',
                style: Theme.of(context).textTheme.headline6,
              ),
              TextFormField(
                style: Theme.of(context).textTheme.headline6,
                initialValue: widget.photoComment.comment,
              ),
               Text(
                'Replies: ',
                style: Theme.of(context).textTheme.headline6,
              ),
              widget.photoCommentReply.isEmpty
                  ? const Text(
                      '\nBe the first to Reply!',
                      style: TextStyle(color: Colors.red, fontSize: 15.0),                                           
                    )
                  : Column(
                      children: [
                        for (var r in widget.photoCommentReply)
                          Card(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comment by: ${r.createdBy}',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text(r.createDate.toString()),
                                const Text(''),
                                Text(
                                  r.comment,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
              TextFormField(
                enabled: editMode,
                controller: _textController,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: const InputDecoration(
                  hintText: 'Click edit to reply to comment',
                ),                
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                onSaved: con.saveComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _CommentReplyState state;
  PhotoCommentReply tempReply = PhotoCommentReply();
  _Controller(this.state);

  void delete() {}
  void edit() {
    state.render(() => state.editMode = true);
  }

  void update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    //all onSave functions will be called
    currentState.save();
    if (tempReply.comment.isEmpty) {
      state.render(() => state.editMode = false);
      return;
    }

    startCircularProgress(state.context);
    tempReply.createDate = DateTime.now();
    tempReply.commentOwner = state.widget.photoComment.createdBy;
    tempReply.createdBy = state.widget.user.email!;
    tempReply.photoCommentID = state.widget.photoComment.docId!;
    try {

      String docId = await FirestoreController.addCommentReply(reply: tempReply);
      tempReply.docId = docId;
      state.widget.photoCommentReply.add(tempReply);
      stopCircularProgress(state.context);

     } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('=========== failed to get pic $e');
      showSnackBar(context: state.context, message: 'Failed to get pic: $e');
    }
    state._textController.clear();    
    print('######### ${tempReply.comment}');
    state.editMode = false;
    state.render(() => state._textController);
    //Navigator.of(state.context).pop(); 
  }

  void saveComment(String? value) {
    if (value != null) {
      tempReply.comment= value;
    }

  }
}
