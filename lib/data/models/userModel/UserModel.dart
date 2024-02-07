class UserModel {
  String? uId;
  String? fullName;
  String? email;
  String? imageProfile;
  bool? isEmailVerified;
  bool? isGoogleSgnIn;
  String? deviceToken;

  UserModel(
      {this.uId,
      this.fullName,
      this.email,
      this.imageProfile,
      this.isEmailVerified,
      this.isGoogleSgnIn,
      this.deviceToken});

  UserModel.fromJson(Map<String, dynamic> json) {
    uId = json['uId'];
    fullName = json['full_name'];
    email = json['email'];
    imageProfile = json['image_profile'];
    isEmailVerified = json['is_email_verified'];
    isGoogleSgnIn = json['is_google_signin'];
    deviceToken = json['device_token'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'full_name': fullName,
      'email': email,
      'image_profile': imageProfile,
      'is_email_verified': isEmailVerified,
      'is_google_signin': isGoogleSgnIn,
      'device_token': deviceToken,
    };
  }
}
