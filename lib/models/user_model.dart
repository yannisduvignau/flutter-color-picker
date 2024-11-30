class UserModel {
  final String uid;
  final String email;

  UserModel({required this.uid, required this.email});

  // Convertir un utilisateur Firebase en UserModel
  factory UserModel.fromFirebaseUser(user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
    );
  }
}
