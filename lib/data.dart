class UserData {
  final String email;
  final String password;
  final String name;

  UserData(this.email, this.password, this.name);
}

List<UserData> users = [
  UserData('user1@gmail.com', 'password123', 'Ahmed'),
  UserData('user2@gmail.com', 'securepassword', 'Ali'),
  // Add more user data as needed
];
