import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:termproject/viewscreen/addeditdeletephotocomment_screen.dart';
import 'package:termproject/viewscreen/addphotomemo_screen.dart';
import 'package:termproject/viewscreen/detailedview_screen.dart';
import 'package:termproject/viewscreen/error_screen.dart';
import 'package:termproject/viewscreen/sharedwith_screen.dart';
import 'package:termproject/viewscreen/signup_screen.dart';
import 'package:termproject/viewscreen/start_screen.dart';
import 'package:termproject/viewscreen/userhome_screen.dart';

import 'model/constant.dart';

void main() async {
  // this error :No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
  //At the start of the app i.e. main() you have to initialize once to use library
  //The next two statements are needed to use firebase library
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TermProject());
}

class TermProject extends StatelessWidget {
  const TermProject({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.devMode,
      initialRoute: StartScreen.routeName,
      routes: {
        StartScreen.routeName: (context) => const StartScreen(),
        UserHomeScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null is for UserHomeScreen');
          } else {
            //We need to convert args to a map to add the user object
            var arguments = args as Map;
            var user = arguments[ArgKey.user];
            var photoMemoList = arguments[ArgKey.photomemolist];
            var newShareList = arguments[ArgKey.newShareList];
            var likedislike = arguments[ArgKey.likedislike];
            return UserHomeScreen(
              user: user,
              photoMemoList: photoMemoList,
              newShares: newShareList,
              likedislike: likedislike,
            );
          }
        },
        AddPhotoMemoScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null is for AddPhotoMemoScreen');
          } else {
            //We need to convert args to a map to add the user object
            var arguments = args as Map;
            var user = arguments[ArgKey.user];
            var photoMemoList = arguments[ArgKey.photomemolist];
            var newShareList = arguments[ArgKey.newShareList];
            return AddPhotoMemoScreen(
              user: user,
              photoMemoList: photoMemoList,
              newShareList: newShareList,
            );
          }
        },
        DetailedViewScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen(
                'args is null is for Detailed View Screen');
          } else {
            //We need to convert args to a map to add the user object
            var arguments = args as Map;
            var user = arguments[ArgKey.user];
            var photoMemo = arguments[ArgKey.onePhotoMemo];
            return DetailedViewScreen(
              user: user,
              photoMemo: photoMemo,
            );
          }
        },
        AddEditDeletePhotoCommentScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null is for Add/Edit/Delete Screen');
          } else {
            var arguments = args as Map;
            var user = arguments[ArgKey.user];
            var photoMemo = arguments[ArgKey.onePhotoMemo];
            var onePhotoComment = arguments[ArgKey.onePhotoComment];
            return AddEditDeletePhotoCommentScreen(
              user: user,
              photoMemo: photoMemo,
              photoComment: onePhotoComment,
            );
          }
        },
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        SharedWithScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null is for Shared With Screen');
          } else {
            //We need to convert args to a map to add the user object
            var arguments = args as Map;
            var user = arguments[ArgKey.user];
            var photoMemoList = arguments[ArgKey.photomemolist];
            var newShareList = arguments[ArgKey.newShareList];
            var likedislike = arguments[ArgKey.likedislike]; 
            return SharedWithScreen(
              user: user,
              photoMemoList: photoMemoList,
              newShares: newShareList,
              likedislike: likedislike,
            );
          }
        }
      },
    );
  }
}
