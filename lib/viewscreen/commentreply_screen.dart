import 'package:flutter/material.dart';

class CommentReply extends StatefulWidget {
  const CommentReply({Key? key}) : super(key: key);


  static const routeName = '/replycomment';
  
  @override
  State<StatefulWidget> createState() {
    return _CommentReplyState();
  }

}

class _CommentReplyState extends State <CommentReply>{
  
  late _Controller con;
  bool editMode = false;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }
  
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
    );
  }

}

class _Controller {
  _CommentReplyState state;

  _Controller(this.state);

  void delete() {}
  void edit() {}
  void update() {}

}
