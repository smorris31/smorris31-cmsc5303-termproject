enum DocKeyReplyComments {
  docId,
  createdBy,
  photoCommentID,
  commentOwner,
  comment,
  createDate,
  dateRead,
  read
}

class PhotoCommentReply {
  String? docId;
  late String createdBy;
  late String photoCommentID;
  late String commentOwner;
  late String comment;
  DateTime? createDate;
  DateTime? dateRead;
  late bool read;

  PhotoCommentReply({
    this.docId = '',
    this.createdBy = '',
    this.photoCommentID = '',
    this.commentOwner = '',
    this.comment = '',
    this.createDate,
    this.dateRead,
    this.read = false,

  });

  PhotoCommentReply.clone(PhotoCommentReply c) {
    docId = c.docId;
    createdBy = c.createdBy;
    photoCommentID = c.photoCommentID;
    commentOwner = c.commentOwner;
    comment = c.comment;
    createDate = c.createDate;
    dateRead = c.dateRead;
    read = c.read;
  }

  void copyFrom(PhotoCommentReply c) {
    docId = c.docId;
    createdBy = c.createdBy;
    photoCommentID = c.photoCommentID;
    commentOwner = c.commentOwner;
    comment = c.comment;
    createDate = c.createDate;
    dateRead = c.dateRead;
    read = c.read;
  }

  //serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyReplyComments.createdBy.name: createdBy,
      DocKeyReplyComments.photoCommentID.name: photoCommentID,
      DocKeyReplyComments.commentOwner.name: commentOwner,
      DocKeyReplyComments.comment.name: comment,
      DocKeyReplyComments.createDate.name: createDate,
      DocKeyReplyComments.dateRead.name: dateRead,
      DocKeyReplyComments.read.name: read,
    };
  }

  // deserialization
  static PhotoCommentReply? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return PhotoCommentReply(
      docId: docId,
      createdBy: doc[DocKeyReplyComments.createdBy.name] ??= 'N/A',
      photoCommentID: doc[DocKeyReplyComments.photoCommentID.name] ??=
          'N/A',
      commentOwner: doc[DocKeyReplyComments.commentOwner.name] ??= 'N/A',
      comment: doc[DocKeyReplyComments.comment.name] ??='N/A',
      createDate: doc[DocKeyReplyComments.createDate.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyReplyComments.createDate.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      dateRead: doc[DocKeyReplyComments.dateRead.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyReplyComments.dateRead.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      read: doc[DocKeyReplyComments.read.name] ??= false,
    );
  }

  static String? validateComment(String? value) {
    return (value == null || value.trim().length < 3) ? 'Comment is too short' : null;
  }
}
