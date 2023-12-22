import 'package:car_pooling/components/profileDB.dart';
import 'package:car_pooling/models/profile.dart';
import 'package:car_pooling/modules/avalaible.dart';
import 'package:car_pooling/modules/history.dart';
import 'package:car_pooling/modules/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;
  ProfileModel retrievedProfile = ProfileModel();
  File? _image;
  final picker = ImagePicker();
  final dbHelper = ProfileDBHelper();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
  }

  getProfile() async {
    await dbHelper.initDatabase();

    ProfileModel? profile =
        await dbHelper.getProfileByEmail(user!.email.toString());

    if (profile != null) {
      setState(() {
        retrievedProfile = profile;
      });
    } else {
      print("Profile not found");
      // Handle the case where the profile is not found
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
    });
    print("IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + _image!.path.toString());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("image", "${_image!.path.toString()}");

    final profile = ProfileModel(
      email: user!.email,
      address: '123 Main Street',
      phone: '123-456-7890',
      password: user!.uid,
      image: _image!.path.toString(),
    );
    await dbHelper.insertOrUpdateProfile(profile);
  }

  final oldpassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmNewPassword = TextEditingController();
  bool isVisiableOldPass = true;
  bool isVisiableNewPass = true;
  bool isVisiableConfirmNewPass = true;

  getSavedImg() {
    getProfile();
    File imageFile = File((retrievedProfile.image.toString()));

    //   setState(() {});
    return imageFile;
  }

  void showPassword(bool obsecureText) {
    setState(() {
      obsecureText = !obsecureText;
    });
  }

  // var profile =
  // ProfileModel(email: 'email', address: 'address', phone: 'phone');
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully.');
    } catch (e) {
      print('Error signing out: $e');
      // Handle errors here
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('email');
    await preferences.remove('password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          width: 200.w,
          child: ListView(
            children: [
              Divider(),
              InkWell(
                onTap: () async {
                  final currentContext = context;
                  await signOut();

                  Navigator.pushAndRemoveUntil(
                    currentContext,
                    MaterialPageRoute(builder: (_) => MyHomePage()),
                    (route) => false,
                  );
                  ;
                },
                child: ListTile(
                  leading: Icon(
                    Icons.exit_to_app, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "Logout",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  final currentContext = context;

                  Navigator.pushReplacement(
                    currentContext,
                    MaterialPageRoute(builder: (_) => OrderHistoryPage()),
                  );
                  ;
                },
                child: ListTile(
                  leading: Icon(
                    Icons.history, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "History",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () async {
                  final currentContext = context;

                  Navigator.pushReplacement(
                    currentContext,
                    MaterialPageRoute(builder: (_) => Avalaible()),
                  );
                  ;
                },
                child: ListTile(
                  leading: Icon(
                    Icons.car_rental, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "Trips",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
            ],
          )),
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Profile"),
        actions: [
          // Badge(
          //   position: BadgePosition.topEnd(top: 10, end: 10),
          //   badgeContent: const Text("1"),
          //   child: IconButton(
          //     onPressed: () {},
          //     icon: const Icon(Icons.add_alert_outlined),
          //   ),
          // ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: <Color>[Colors.purple, Colors.blue]),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/photos/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 320,
                child: Stack(
                  children: [
                    Positioned(
                      left: MediaQuery.of(context).size.width / 8,
                      top: MediaQuery.of(context).size.width / 1.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [],
                      ),
                    ),
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: <Color>[Colors.purple, Colors.blue]),
                      ),
                    ),
                    Positioned(
                      right: MediaQuery.of(context).size.width / 8,
                      top: 30,
                      child: Container(
                        height: 150,
                        width: 300,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      retrievedProfile.image!.isNotEmpty
                                          ? Image.file(
                                              getSavedImg(),
                                              fit: BoxFit.cover,
                                            ).image
                                          : _image != null
                                              ? Image.file(
                                                  _image!,
                                                  fit: BoxFit.cover,
                                                ).image
                                              : const AssetImage(
                                                  'assets/photos/860454.png'),
                                ),
                                Positioned(
                                  right: -10,
                                  bottom: -7,
                                  child: IconButton(
                                      onPressed: () async {
                                        await getImage();
                                      },
                                      icon: const Icon(Icons.camera_enhance)),
                                )
                              ],
                            ),
                            // const SizedBox(
                            //   height: 5,
                            // ),
                            // Text(user!.email.toString()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              const Text('Basic Information',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: SizedBox(
                  height: 50,
                  width: 300,
                  child: Opacity(
                    opacity: 0.5,
                    child: ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(
                        retrievedProfile!.email.toString(),
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: SizedBox(
                  height: 50,
                  width: 300,
                  child: Opacity(
                    opacity: 0.5,
                    child: ListTile(
                      leading: const Icon(Icons.location_pin),
                      title: Text(retrievedProfile!.address.toString()),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: SizedBox(
                  height: 50,
                  width: 300,
                  child: Opacity(
                    opacity: 1,
                    child: ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(retrievedProfile!.phone.toString()),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Privacy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              SizedBox(
                height: 100,
                width: 300,
                child: ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('My Password'),
                  trailing: InkWell(
                      onTap: () {
                        newMethod(context);
                      },
                      child: const Icon(Icons.edit)),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
                onPressed: () {},
                icon: const Icon(Icons.lock, color: Colors.white),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void newMethod(BuildContext context) {
    final oldpassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmNewPassword = TextEditingController();
    bool isVisiableOldPass = true;
    bool isVisiableNewPass = true;
    bool isVisiableConfirmNewPass = true;
    bool passCorrect = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Update Password"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Visibility(
                        visible: passCorrect,
                        child: const Text(
                          'New Password not same',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        obscureText: isVisiableOldPass,
                        controller: oldpassword,
                        decoration: InputDecoration(
                          hintText: 'Current Password',
                          suffixIcon: IconButton(
                            icon: isVisiableOldPass
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                isVisiableOldPass = !isVisiableOldPass;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        obscureText: isVisiableNewPass,
                        controller: newPassword,
                        decoration: InputDecoration(
                          hintText: 'New Password',
                          suffixIcon: IconButton(
                            icon: isVisiableNewPass
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                isVisiableNewPass = !isVisiableNewPass;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        obscureText: isVisiableConfirmNewPass,
                        controller: confirmNewPassword,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: isVisiableConfirmNewPass
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                isVisiableConfirmNewPass =
                                    !isVisiableConfirmNewPass;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (newPassword == confirmNewPassword) {
                      updatePassword(newPassword.toString());
                      print('Correct');

                      setState(() {
                        passCorrect = false;
                      });
                    } else {
                      print('Not Same');
                      setState(() {
                        passCorrect = true;
                      });
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('Update Password'),
    //       content: SingleChildScrollView(
    //         child: ListBody(
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: TextFormField(
    //                 obscureText: isVisiableOldPass,
    //                 controller: oldpassword,
    //                 decoration: InputDecoration(
    //                   hintText: 'Current Password',
    //                   suffixIcon: IconButton(
    //                     icon: isVisiableOldPass
    //                         ? Icon(Icons.visibility_off)
    //                         : Icon(Icons.visibility),
    //                     onPressed: () {
    //                       showPassword(isVisiableOldPass);
    //                     },
    //                   ),
    //                   border: OutlineInputBorder(
    //                     borderRadius: BorderRadius.all(
    //                       Radius.circular(20),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: TextFormField(
    //                 controller: newPassword,
    //                 decoration: InputDecoration(
    //                   hintText: 'New Password',
    //                   suffixIcon: Icon(Icons.visibility_off),
    //                   border: OutlineInputBorder(
    //                     borderRadius: BorderRadius.all(
    //                       Radius.circular(20),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: TextFormField(
    //                 controller: confirmNewPassword,
    //                 decoration: InputDecoration(
    //                   hintText: 'Confirm Password',
    //                   suffixIcon: Icon(Icons.visibility_off),
    //                   border: OutlineInputBorder(
    //                     borderRadius: BorderRadius.all(
    //                       Radius.circular(20),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       actions: [
    //         ElevatedButton(
    //           child: new Text('Reset'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         ElevatedButton(
    //           child: new Text('Ok'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
        print('Password updated successfully.');
      } else {
        print('User not signed in.');
      }
    } catch (e) {
      print('Error updating password: $e');
      // Handle errors here
    }
  }
}
