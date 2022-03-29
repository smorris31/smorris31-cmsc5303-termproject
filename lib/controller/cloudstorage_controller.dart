import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:termproject/model/constant.dart';
import 'package:uuid/uuid.dart';

class CloudStorageController {

  //Since we are doing an await call use Future value
  static Future<Map<ArgKey, String>> uploadPhotoFile({
    required File photo,
    String? filename,
    required String uid,
    required Function listener,  // can be called for progress function

  }) async {

    filename ??= '${Constant.photoFileFolder}/$uid/${const Uuid().v1()}';
    print('filename is: $filename');
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      //Get the progress
      int progress = (event.bytesTransferred / event.totalBytes * 100).toInt();
      //use Listener function to show the progress
      listener(progress);
     });

    TaskSnapshot snapshot = await task;
    String downloadURL = await snapshot.ref.getDownloadURL();

    return {ArgKey.downloadURL: downloadURL, 
    ArgKey.filename: filename};

  }

  static Future<void> deleteFile({
    required String filename,
  }) async {
    await FirebaseStorage.instance.ref().child(filename).delete();
  }
  
}