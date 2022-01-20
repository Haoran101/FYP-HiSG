class Review {
  String? placeId;
  int? reviewSerialNo;
  String? profilePhotoURL;
  String? authorName;
  int? timeEpochSeconds;
  String? content;

  toString() {
    return """Review(placeId: $placeId, reviewSerialNo: $reviewSerialNo, profilePhotoURL: $profilePhotoURL,
    authorName: $authorName, timeEpochSeconds: $timeEpochSeconds, content: $content)""";
  }

  Review.fromJSON(placeIdInput, reviewSerialNoInput, json) {
    placeId = placeIdInput;
    reviewSerialNo = reviewSerialNoInput;
    profilePhotoURL = json["profile_photo_url"];
    authorName = json["author_name"];
    timeEpochSeconds = json["time"];
    content = json["text"];
  }
}