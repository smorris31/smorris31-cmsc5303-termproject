import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:termproject/controller/auth_controller.dart';
import 'package:termproject/controller/cloudstorage_controller.dart';
import 'package:termproject/controller/firestore_controller.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/model/photolikedislike.dart';
import 'package:termproject/model/photomemo.dart';
import 'package:termproject/model/viewsharedphoto.dart';
import 'package:termproject/viewscreen/addphotomemo_screen.dart';
import 'package:termproject/viewscreen/detailedview_screen.dart';
import 'package:termproject/viewscreen/sharedwith_screen.dart';
import 'package:termproject/viewscreen/view/view_util.dart';
import 'package:termproject/viewscreen/view/webimage.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen(
      {required this.user,
      required this.photoMemoList,
      required this.newShares,
      required this.likedislike,
      Key? key})
      : super(key: key);

  static const routeName = '/userHomeScreen';

  final User user;
  final List<PhotoMemo>
      photoMemoList; // These are point to the array in Firestore
  final List<ViewSharedPhoto> newShares;
  final List<PhotoLikeDislike> likedislike;

  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  late _Controller con;
  late String email; //set to late because assigned later
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    //check if email is null and if some send message
    email = widget.user.email ?? 'No Email';
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    //WillPopScope is setup for android devices
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          //title: const Text('User Home'),
          actions: [
            con.selected.isEmpty
                ? Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .70,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Search (empty for all)',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKey,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: con.cancel,
                  ),
            con.selected.isEmpty
                ? IconButton(
                    onPressed: con.search,
                    icon: const Icon(Icons.search),
                  )
                : IconButton(
                    onPressed: con.delete,
                    icon: const Icon(Icons.delete),
                  ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: const Icon(Icons.person, size: 70.0),
                accountName: const Text('no profile'),
                accountEmail: Text(email),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Shared With'),
                trailing: con.newSharedPhotos.isNotEmpty
                    ? const Icon(Icons.star)
                    : const Text(''),
                onTap: con.sharedWith,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: con.photoMemoList.isEmpty
            ? Text(
                'No PhotoMemo Found!',
                style: Theme.of(context).textTheme.headline6,
              )
            : ListView.builder(
                itemCount: con.photoMemoList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    selected: con.selected.contains(index),
                    selectedTileColor: Colors.blue[100],
                    //tileColor: Colors.grey,
                    leading: WebImage(
                      url: con.photoMemoList[index].photoURL,
                      context: context,
                    ),
                    title: Text(con.photoMemoList[index].title),
                    trailing: Column(
                      children: [
                        con.photoMemoList[index].commentsAdded
                            ? const Icon(
                                Icons.star,
                                color: Colors.red,
                              )
                            : const SizedBox(
                                height: 1.0,
                              ),
                        const Icon(Icons.arrow_right),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(con.photoMemoList[index].memo.length >= 40
                            ? con.photoMemoList[index].memo.substring(0, 40) +
                                '...'
                            : con.photoMemoList[index].memo),
                        Text(
                            'Created By: ${con.photoMemoList[index].createdBy}'),
                        Text(
                            'Shared With: ${con.photoMemoList[index].sharedWith}'),
                        Text(
                            'Timestamp: ${con.photoMemoList[index].timestamp}'),
                        Text('Likes: ${con.photoMemoList[index].like}'),
                        Text('Dislikes: ${con.photoMemoList[index].dislike}'),
                      ],
                    ),
                    onTap: () => con.detailedView(index),
                    onLongPress: () => con.onLongPress(index),
                  );
                },
              ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  late List<PhotoMemo> photoMemoList;
  late List<ViewSharedPhoto> newSharedPhotos;
  late List<PhotoLikeDislike> likedislike;
  String? searchKeyString;
  List<int> selected = [];

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
    newSharedPhotos = state.widget.newShares;
    likedislike = state.widget.likedislike;
  }

  void addButton() async {
    await Navigator.pushNamed(state.context, AddPhotoMemoScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.photomemolist: photoMemoList,
          ArgKey.newShareList: newSharedPhotos,
        });

    state.render(() {}); // render the screen even if photo memo was not added
  }

  Future<void> signOut() async {
    try {
      await AuthController.signOut();
    } catch (e) {
      if (Constant.devMode) print('=========== sign out error: $e');
      showSnackBar(context: state.context, message: 'Sign Out Error: $e');
    }
    Navigator.of(state.context).pop(); //close the drawer
    Navigator.of(state.context).pop(); //return to start screen
  }

  void detailedView(int index) async {
    if (selected.isNotEmpty) {
      onLongPress(index);
      return;
    }
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          // Use index to get COPY of actual content from Firestore array
          // Send COPY of actual object to Detailed view Page
          ArgKey.onePhotoMemo: photoMemoList[index],
        });
    state.render(() {});
  }

  void onLongPress(int index) {
    state.render(() {
      if (selected.contains(index)) {
        selected.remove(index);
      } else {
        selected.add(index);
      }
    });
  }

  void delete() async {
    //delete photo memos in PhotoMemo list memory and firestore/store
    startCircularProgress(state.context);
    selected.sort();
    for (int i = selected.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[selected[i]];
        await FirestoreController.deleteDoc(docId: p.docId!);
        await CloudStorageController.deleteFile(filename: p.photoFilename);
        state.render(() {
          photoMemoList.removeAt(selected[i]);
        });
      } catch (e) {
        if (Constant.devMode) print('=========== failed to delete: $e');
        showSnackBar(
            context: state.context,
            seconds: 20,
            message: 'Failed! Sign Out and In again to get updated list');
        break;

        ///quit further processing
      }
    }
    state.render(() => selected.clear());
    stopCircularProgress(state.context);
  }

  void cancel() {
    state.render(() => selected.clear());
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void search() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    currentState.save();

    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim().toLowerCase());
      }
    }
    startCircularProgress(state.context);
    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        results =
            await FirestoreController.getPhotoMemoList(email: state.email);
      } else {
        results = await FirestoreController.searchImages(
          email: state.email,
          searchLabel: keys,
        );
      }
      stopCircularProgress(state.context);
      state.render(() {
        photoMemoList = results;
      });
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('============ Failed to search $e');
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: '============ Failed to search $e');
    }
  }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWithMe(
              email: state.email);
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            ArgKey.photomemolist: photoMemoList,
            ArgKey.user: state.widget.user,
            ArgKey.newShareList: newSharedPhotos,
            ArgKey.likedislike: likedislike,
          });
      state.render(() {
        newSharedPhotos.clear();
      });
      Navigator.of(state.context).pop(); //push in the drawer
    } catch (e) {
      if (Constant.devMode) print('============= get Shared With Error $e');
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: '============= get Shared With Error $e',
      );
    }
  }
}
