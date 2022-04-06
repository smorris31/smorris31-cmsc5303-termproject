
enum PhotoSource { camera, gallery }

enum DocKeyPhotoMemo {
  createdBy,
  title,
  memo,
  photoFilename,
  photoURL,
  timestamp,
  imageLabels,
  sharedWith,
  like,
  dislike,
  commentsAdded,
  comments,
}

class PhotoMemo {
  //Set docId to nullable so that we can set its value later.
  String? docId; // like the primary key in SQL; generated by Firestore
  late String createdBy; // email = user id
  late String title;
  late String memo;
  late String photoFilename; // image/photo name file at Cloud Storage
  late String photoURL; //URL of the image
  DateTime? timestamp;
  late List<dynamic>
      imageLabels; //ML generated image lables; use dynamic and let firestore determine the type
  late List<dynamic> sharedWith;
  late int like;
  late int dislike;
  late bool commentsAdded;
  late List<dynamic> comments;

  //Constructor
  PhotoMemo({
    this.docId,
    this.createdBy = '',
    this.title = '',
    this.memo = '',
    this.photoFilename = '',
    this.photoURL = '',
    this.timestamp,
    List<dynamic>? imageLabels,
    List<dynamic>? sharedWith,
    this.like = 0,
    this.dislike = 0,
    this.commentsAdded = false,
    List<dynamic>? comments,
  }) {
    this.imageLabels = imageLabels == null ? [] : [...imageLabels];
    this.sharedWith = sharedWith == null ? [] : [...sharedWith];
    this.comments = comments == null ? [] : [...comments];
  }

  //Method to return a cloned copy of the object
  PhotoMemo.clone(PhotoMemo p) {
    docId = p.docId;
    createdBy = p.createdBy;
    title = p.title;
    memo = p.memo;
    photoFilename = p.photoFilename;
    photoURL = p.photoURL;
    timestamp = p.timestamp;
    // create a list, copy the content with spread operator
    sharedWith = [...p.sharedWith];
    imageLabels = [...p.imageLabels];
    like = p.like;
    dislike = p.dislike;
    commentsAdded = p.commentsAdded;
    comments = [...p.comments];
  }

  //Copy form a.copyFrom(b) ==> a = b
  void copyFrom(PhotoMemo p) {
    docId = p.docId;
    createdBy = p.createdBy;
    title = p.title;
    memo = p.memo;
    photoFilename = p.photoFilename;
    photoURL = p.photoURL;
    timestamp = p.timestamp;
    //In the copy function we must first clear the original list
    sharedWith.clear();
    //Then add all the changes back to the object
    sharedWith.addAll(p.sharedWith);
    imageLabels.clear();
    imageLabels.addAll(p.imageLabels);
    like = p.like;
    dislike = p.dislike;
    commentsAdded = p.commentsAdded;
    comments.clear();
    comments.addAll(p.comments);
  }

  //serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPhotoMemo.title.name: title,
      DocKeyPhotoMemo.createdBy.name: createdBy,
      DocKeyPhotoMemo.memo.name: memo,
      DocKeyPhotoMemo.photoFilename.name: photoFilename,
      DocKeyPhotoMemo.photoURL.name: photoURL,
      DocKeyPhotoMemo.timestamp.name: timestamp,
      DocKeyPhotoMemo.sharedWith.name: sharedWith,
      DocKeyPhotoMemo.imageLabels.name: imageLabels,
      DocKeyPhotoMemo.like.name: like,
      DocKeyPhotoMemo.dislike.name: dislike,
      DocKeyPhotoMemo.commentsAdded.name: commentsAdded,
      DocKeyPhotoMemo.comments.name: comments,
    };
  }

  // deserialization
  static PhotoMemo? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return PhotoMemo(
      docId: docId,
      createdBy: doc[DocKeyPhotoMemo.createdBy.name] ??= 'N/A',
      title: doc[DocKeyPhotoMemo.title.name] ??= 'N/A',
      memo: doc[DocKeyPhotoMemo.memo.name] ??= 'N/A',
      photoFilename: doc[DocKeyPhotoMemo.photoFilename.name] ??= 'N/A',
      photoURL: doc[DocKeyPhotoMemo.photoURL.name] ??= 'N/A',
      sharedWith: doc[DocKeyPhotoMemo.sharedWith.name] ??= [],
      imageLabels: doc[DocKeyPhotoMemo.imageLabels.name] ??= [],
      timestamp: doc[DocKeyPhotoMemo.timestamp.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyPhotoMemo.timestamp.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      like: doc[DocKeyPhotoMemo.like.name] ??= 0,
      dislike: doc[DocKeyPhotoMemo.dislike.name] ??= 0,
      commentsAdded: doc[DocKeyPhotoMemo.commentsAdded.name] ??= false,
      comments: doc[DocKeyPhotoMemo.comments.name] ??= [],
    );
  }

  static String? validateTitle(String? value) {
    return (value == null || value.trim().length < 3)
        ? 'Title too short'
        : null;
  }

  void addLike(int? value) {
    value != null ? like += value : like += 0;
  }

  void addDislike(int? value) {
    value != null ? dislike += value : dislike += 0;
  }

  static String? validateMemo(String? value) {
    return (value == null || value.trim().length < 5) ? 'Memo too short' : null;
  }

  static String? validateSharedWith(String? value) {
    //We need to split the string by the tokens , ; or space
    if (value == null || value.trim().isEmpty) return null;
    List<String> emailList =
        value.trim().split(RegExp('(,|;| )+')).map((e) => e.trim()).toList();
    for (String e in emailList) {
      if (e.contains('@') && e.contains('.')) {
        continue;
      } else {
        return 'Invalid Email Address found: comma, semicolon, space seperated list';
      }
    }
    return null;
  }
}
