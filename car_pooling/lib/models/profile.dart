// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProfileModel {
  String? email;
  String? address;
  String? phone;
  String? password;
  String? image;

  ProfileModel(
      {this.email, this.address, this.phone, this.image, this.password});
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'address': address,
      'phone': phone,
      'password': password,
      'image': image,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      email: map['email'],
      address: map['address'],
      phone: map['phone'],
      password: map['password'],
      image: map['image'],
    );
  }
}
