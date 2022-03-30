import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/model/viewsharedphoto.dart';
import 'package:termproject/viewscreen/view/view_util.dart';
import 'package:termproject/viewscreen/view/webimage.dart';
import '../model/photomemo.dart';
import '../model/constant.dart';

class SharedWithScreen extends StatefulWidget {
  const SharedWithScreen(
      {required this.photoMemoList, required this.user, required this.newShares,
      Key? key})
      : super(key: key);

  final List<PhotoMemo> photoMemoList;
  final List<ViewSharedPhoto> newShares;
  final User user;

  static const routeName = '/sharedwithscreen';
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    con.updateViewPhotoCollection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With: ${widget.user.email}'),
      ),
      body: SingleChildScrollView(
        child: widget.photoMemoList.isEmpty
            ? Text(
                'No PhotoMemo Shared with me',
                style: Theme.of(context).textTheme.headline6,
              )
            : Column(
                children: [
                  for (var photoMemo in widget.photoMemoList)
                    Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: WebImage(
                                url: photoMemo.photoURL,
                                context: context,
                                height: MediaQuery.of(context).size.height * .3,
                              ),
                            ),
                            Text(
                              photoMemo.title,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Text(photoMemo.memo),
                            Text('Created By: ${photoMemo.createdBy}'),
                            Text('Created at: ${photoMemo.timestamp}'),
                            Text('Shared With: ${photoMemo.sharedWith}'),
                            Constant.devMode
                                ? Text('Image labels: ${photoMemo.imageLabels}')
                                : const SizedBox(
                                    height: 1.0,
                                  ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Controller {
  _SharedWithState state;
  _Controller(this.state);

  void updateViewPhotoCollection() async {
    startCircularProgress(state.context);
    for (int i = state.widget.newShares.length - 1; i >= 0; i--) {
      state.widget.newShares[i].dateViewed = DateTime.now();
      state.widget.newShares[i].viewed = true;
      await FirestoreController.updateViewedPhoto(
          docId: state.widget.newShares[i].docId!,
          update: state.widget.newShares[i].toFirestoreDoc());
    }
    stopCircularProgress(state.context);
  }
}
