enum DocKeyPhotoComments {
  docId,
  createdBy,
  photoCollectionID,
  commment,
  createDate,
  dateRead,
  read
}

class PhotoComment {
  String? docId;
  late String createdBy;
  late String photoCollectionID;
  late String comment;
  DateTime? createDate;
  DateTime? dateRead;
  late bool read;

  PhotoComment({
    this.docId = '',
    this.createdBy = '',
    this.photoCollectionID = '',
    this.comment = '',
    this.createDate,
    this.dateRead,
    this.read = false,
  });

  void copyFrom(PhotoComment c) {
    docId = c.docId;
    createdBy = c.createdBy;
    photoCollectionID = c.photoCollectionID;
    comment = c.comment;
    createDate = c.createDate;
    dateRead = c.dateRead;
    read = c.read;
  }

  //serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPhotoComments.createdBy.name: createdBy,
      DocKeyPhotoComments.photoCollectionID.name: photoCollectionID,
      DocKeyPhotoComments.commment.name: comment,
      DocKeyPhotoComments.createDate.name: createDate,
      DocKeyPhotoComments.dateRead.name: dateRead,
      DocKeyPhotoComments.read.name: read,
    };
  }

  // deserialization
  static PhotoComment? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return PhotoComment(
      docId: docId,
      createdBy: doc[DocKeyPhotoComments.createdBy.name] ??= 'N/A',
      photoCollectionID: doc[DocKeyPhotoComments.photoCollectionID.name] ??=
          'N/A',
      comment: doc[DocKeyPhotoComments.commment.name] ??='N/A',
      createDate: doc[DocKeyPhotoComments.createDate.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyPhotoComments.createDate.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      dateRead: doc[DocKeyPhotoComments.dateRead.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyPhotoComments.dateRead.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      read: doc[DocKeyPhotoComments.read.name] ??= false,
    );
  }

  static String? validateComment(String? value) {
    return (value == null || value.trim().length < 3) ? 'Comment is too short' : null;
  }
}
