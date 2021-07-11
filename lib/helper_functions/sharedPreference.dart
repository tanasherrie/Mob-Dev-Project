import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper{
  static String userIDKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "USERDISPLAYNAMEKEY";
  static String emailKey = "EMAILKEY";
  static String profilePicKey = "PROFILEPICKEY";

  Future<bool> saveUserName(String getUserName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userNameKey, getUserName);
  }

  Future<bool> saveEmail(String getUserEmail) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(emailKey, getUserEmail);
  }

  Future<bool> saveUserID(String getID) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userIDKey, getID);
  }

  Future<bool> saveDisplayName(String getDisplayName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(displayNameKey, getDisplayName);
  }

  Future<bool> saveProfilePic(String getProfilePic) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(profilePicKey, getProfilePic);
  }

  //get data
  Future<String> getUserName() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userNameKey);
  }

  Future<String> getEmail() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(emailKey);
  }

  Future<String> getUserID() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userIDKey);
  }

  Future<String> getDisplayName() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(displayNameKey);
  }

  Future<String> getProfilePic() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(profilePicKey);
  }
}