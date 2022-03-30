import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:termproject/model/viewsharedphoto.dart';
import 'package:termproject/model/constant.dart';
import 'package:termproject/model/photomemo.dart';

class FirestoreController {

  static Future<String> addPhotoMemo({
    required PhotoMemo photoMemo,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .add(photoMemo.toFirestoreDoc());
    return ref.id;
  }

  static Future<String> addNewShareEntry({
    required ViewSharedPhoto newShare,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.viewedSharedPhotoCollection)
        .add(newShare.toFirestoreDoc());
    return ref.id;
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .where(DocKeyPhotoMemo.createdBy.name, isEqualTo: email)
        .orderBy(DocKeyPhotoMemo.timestamp.name, descending: true)
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = PhotoMemo.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null) result.add(p);
      }
    }
    return result;
  }

  static Future<List<ViewSharedPhoto>> getNewPhotoShares({
    required String email,
  }) async {
    print('**********Query Viewed Shared ***********');
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.viewedSharedPhotoCollection)
        .where(DocKeyViewedPhotoMemo.sharedWithEmail.name, isEqualTo: email)
        .where(DocKeyViewedPhotoMemo.viewed.name, isEqualTo: false)
        .orderBy(DocKeyViewedPhotoMemo.dateShared.name, descending: true)
        .get();

    var result = <ViewSharedPhoto>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = ViewSharedPhoto.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null) result.add(p);
      }
    }
    print('******* found results **********');
    return result;
  }

  static Future<void> updatePhotoMemo({
    required String docId,
    required Map<String, dynamic> update,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .doc(docId)
        .update(update);
  }

  static Future<List<PhotoMemo>> searchImages({
    required String email,
    required List<String> searchLabel, //OR search
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .where(DocKeyPhotoMemo.createdBy.name, isEqualTo: email)
        .where(DocKeyPhotoMemo.imageLabels.name, arrayContainsAny: searchLabel)
        .orderBy(DocKeyPhotoMemo.timestamp.name, descending: true)
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      var p = PhotoMemo.fromFirestoreDoc(
        doc: doc.data() as Map<String, dynamic>,
        docId: doc.id,
      );
      if (p != null) result.add(p);
    }
    return result;
  }

  static Future<void> deleteDoc({
    required String docId,
  }) async {
    await FirebaseFirestore.instance.collection(Constant.photoMemoCollection)
                .doc(docId).delete();
  }

  static Future<List<PhotoMemo>> getPhotoMemoListSharedWithMe({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .where(DocKeyPhotoMemo.sharedWith.name, arrayContains: email)
        .orderBy(DocKeyPhotoMemo.timestamp.name, descending: true)
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = PhotoMemo.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null) result.add(p);
      }
    }
    return result;
  }
}
