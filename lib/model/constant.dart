class Constant {
  static const devMode = true;
  static const photoFileFolder = 'photo_files';
  static const photoMemoCollection = 'photomemo_collection';
  static const viewedSharedPhotoCollection = 'viewedphoto_collection';
  static const photoLikeDislike = 'photoLikesDislikes_collection';
  static const photoComments = 'photocomments_collection';  
  static const pageLimit = 4;
}

enum ArgKey {
  user,
  downloadURL,
  filename,
  photomemolist,
  onePhotoMemo,
  newShareList,
  likedislike,
  photoComments,
  onePhotoComment,
}
