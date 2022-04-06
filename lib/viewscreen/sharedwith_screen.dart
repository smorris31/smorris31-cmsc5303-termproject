import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/model/photocomment.dart';
import 'package:termproject/model/photolikedislike.dart';
import 'package:termproject/model/viewsharedphoto.dart';
import 'package:termproject/viewscreen/addeditdeletephotocomment_screen.dart';
import 'package:termproject/viewscreen/view/webimage.dart';
import '../model/photomemo.dart';
import '../model/constant.dart';

class SharedWithScreen extends StatefulWidget {
  const SharedWithScreen(
      {required this.photoMemoList,
      required this.user,
      required this.newShares,
      required this.likedislike,
      Key? key})
      : super(key: key);

  final List<PhotoMemo> photoMemoList;
  final List<ViewSharedPhoto> newShares;
  final List<PhotoLikeDislike> likedislike;
  final User user;

  static const routeName = '/sharedwithscreen';
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  late _Controller con;
  bool editMode = false;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    con.updateViewPhotoCollection();
  }

  void render(fn) => setState(fn);

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
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // ignore: iterable_contains_unrelated_type
                                  children: widget.likedislike
                                          .where((element) =>
                                              element.photoCollectionID ==
                                              photoMemo.docId)
                                          .isEmpty
                                      ? [
                                          IconButton(
                                            onPressed: () =>
                                                con.likePhotoMemo(photoMemo),
                                            icon: const Icon(
                                              Icons.thumb_up,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ]
                                      : [
                                          const Icon(
                                            Icons.thumb_up,
                                            color: Colors.red,
                                          ),
                                        ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  // ignore: iterable_contains_unrelated_type
                                  children: widget.likedislike
                                          .where((element) =>
                                              element.photoCollectionID ==
                                              photoMemo.docId)
                                          .isEmpty
                                      ? [
                                          IconButton(
                                            onPressed: () =>
                                                con.dislikePhotoMemo(photoMemo),
                                            icon: const Icon(
                                              Icons.thumb_down,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ]
                                      : [
                                          const Icon(
                                            Icons.thumb_down,
                                            color: Colors.red,
                                          ),
                                        ],
                                ),
                                ElevatedButton(
                                  onPressed: () => con.comment(photoMemo),
                                  child: const Text('Comment'),
                                ),
                              ],
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
  late PhotoComment tempComment;
  _Controller(this.state);

  void updateViewPhotoCollection() async {
    for (int i = state.widget.newShares.length - 1; i >= 0; i--) {
      state.widget.newShares[i].dateViewed = DateTime.now();
      state.widget.newShares[i].viewed = true;
      await FirestoreController.updateViewedPhoto(
          docId: state.widget.newShares[i].docId!,
          update: state.widget.newShares[i].toFirestoreDoc());
    }
  }

  void likePhotoMemo(PhotoMemo photoMemo) async {
    PhotoLikeDislike photoLikeDislike = PhotoLikeDislike();
    photoLikeDislike.photoCollectionID = photoMemo.docId!;
    photoLikeDislike.reviewerEmail = state.widget.user.email!;
    photoLikeDislike.like = 1;
    photoLikeDislike.dateReviewed = DateTime.now();
    String docId = await FirestoreController.addPhotoLikesDislikes(
        photoLikeDislike: photoLikeDislike);
    photoLikeDislike.docId = docId;
    state.widget.likedislike.add(photoLikeDislike);
    state.render(() {});
  }

  void dislikePhotoMemo(PhotoMemo photoMemo) async {
    PhotoLikeDislike photoLikeDislike = PhotoLikeDislike();
    photoLikeDislike.photoCollectionID = photoMemo.docId!;
    photoLikeDislike.reviewerEmail = state.widget.user.email!;
    photoLikeDislike.dislike = 1;
    photoLikeDislike.dateReviewed = DateTime.now();
    String docId = await FirestoreController.addPhotoLikesDislikes(
        photoLikeDislike: photoLikeDislike);
    photoLikeDislike.docId = docId;
    state.widget.likedislike.add(photoLikeDislike);
    state.render(() {});
  }

  void comment(PhotoMemo photoMemo) async {
    //Navigate to photocomment
    tempComment = await FirestoreController.getPhotoCommentByUser(
        email: state.widget.user.email!, photoCollectionID: photoMemo.docId!);
    await Navigator.pushNamed(
        state.context, AddEditDeletePhotoCommentScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.onePhotoMemo: photoMemo,
          ArgKey.onePhotoComment: tempComment,
        });

    state.render(() {}); // render the screen even if photo memo was not added
  }
}
