enum DocKeyLikeDislikePhoto {
  docId,
  photoCollectionID,
  reviewerEmail,
  like,
  dislike,
  dateReviewed,
}

class PhotoLikeDislike {
  String? docId;
  late String photoCollectionID; 
  late String reviewerEmail;
  late int like;
  late int dislike;
  DateTime? dateReviewed; 

   PhotoLikeDislike({
    this.docId = '',
    this.photoCollectionID = '',
    this.reviewerEmail = '',
    this.like = 0,
    this.dislike = 0,
    this.dateReviewed,
  });
  void copyFrom(PhotoLikeDislike p) {
    docId = p.docId;
    photoCollectionID = p.photoCollectionID;
    reviewerEmail = p.reviewerEmail;
    like = p.like;
    dislike = p.dislike;
    dateReviewed = p.dateReviewed;
  }
  //serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyLikeDislikePhoto.photoCollectionID.name: photoCollectionID,
      DocKeyLikeDislikePhoto.reviewerEmail.name: reviewerEmail,
      DocKeyLikeDislikePhoto.like.name: like,
      DocKeyLikeDislikePhoto.dislike.name: dislike,
      DocKeyLikeDislikePhoto.dateReviewed.name: dateReviewed,
    };
  }

  // deserialization
  static PhotoLikeDislike? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return PhotoLikeDislike(
      docId: docId,
      photoCollectionID: doc[DocKeyLikeDislikePhoto.photoCollectionID.name] ??= 'N/A',
      reviewerEmail: doc[DocKeyLikeDislikePhoto.reviewerEmail.name] ??= 'N/A',
      like: doc[DocKeyLikeDislikePhoto.like.name] ??= 0,
      dislike: doc[DocKeyLikeDislikePhoto.dislike.name] ??= 0,
      dateReviewed: doc[DocKeyLikeDislikePhoto.dateReviewed.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyLikeDislikePhoto.dateReviewed.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }
}
