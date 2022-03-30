
enum DocKeyViewedPhotoMemo {
  docId,
  photoCollectionID,
  dateShared,
  sharedBy,
  viewed,
  dateViewed,
  sharedWithEmail
}

class ViewSharedPhoto{
  String? docId;
  late String photoCollectionID; 
  DateTime? dateShared;
  late String sharedBy;
  late bool viewed;
  DateTime? dateViewed; 
  late String sharedWithEmail;

   ViewSharedPhoto({
    this.docId = '',
    this.photoCollectionID = '',
    this.dateShared,
    this.sharedBy = '',
    this.viewed = false,
    this.dateViewed,
    this.sharedWithEmail = '',
  });
  void copyFrom(ViewSharedPhoto p) {
    docId = p.docId;
    photoCollectionID = p.photoCollectionID;
    dateShared = p.dateShared;
    sharedBy = p.sharedBy;
    viewed = p.viewed;
    dateViewed = p.dateViewed;
    sharedWithEmail = p.sharedWithEmail;
  }
  //serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyViewedPhotoMemo.photoCollectionID.name: photoCollectionID,
      DocKeyViewedPhotoMemo.dateShared.name: dateShared,
      DocKeyViewedPhotoMemo.sharedBy.name: sharedBy,
      DocKeyViewedPhotoMemo.viewed.name: viewed,
      DocKeyViewedPhotoMemo.dateViewed.name: dateViewed,
      DocKeyViewedPhotoMemo.sharedWithEmail.name: sharedWithEmail,
    };
  }

  // deserialization
  static ViewSharedPhoto? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return ViewSharedPhoto(
      docId: docId,
      photoCollectionID: doc[DocKeyViewedPhotoMemo.photoCollectionID.name] ??= 'N/A',
      dateShared: doc[DocKeyViewedPhotoMemo.dateShared.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyViewedPhotoMemo.dateShared.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      sharedBy: doc[DocKeyViewedPhotoMemo.sharedBy.name] ??= 'N/A',
      viewed: doc[DocKeyViewedPhotoMemo.viewed.name] ??= false,
      dateViewed: doc[DocKeyViewedPhotoMemo.dateViewed.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyViewedPhotoMemo.dateViewed.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      sharedWithEmail: doc[DocKeyViewedPhotoMemo.sharedWithEmail.name] ??= 'N/A',
    );
  }

}




