class AppUser {
  String firstName;
  String secondName;
  String thirdName;
  String username;
  String contact;
  String password;

  AppUser({
    required this.firstName,
    required this.secondName,
    required this.thirdName,
    required this.username,
    required this.contact,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      "firstName": firstName,
      "secondName": secondName,
      "thirdName": thirdName,
      "username": username,
      "contact": contact,
    };
  }
}