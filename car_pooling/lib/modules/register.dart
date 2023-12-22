import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        )
            .then((userCredential) async {
          User? user = userCredential.user;

          // Set the user's profile picture URL
          await user?.updatePhotoURL(
              'https://png.pngtree.com/element_our/20190528/ourmid/pngtree-small-url-icon-opened-on-the-computer-image_1132275.jpg');
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the home page
        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The email address is already in use.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Register',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
                height: 25.h,
              ),
              CircleAvatar(
                radius: 100.r, // Adjust the radius as needed
                backgroundImage: AssetImage(
                    'assets/photos/register.png'), // Replace with your image asset
              ),
              SizedBox(
                height: 20.h,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!value.contains('@') ||
                                !value.endsWith('.eng.asu.edu.eg')) {
                              return 'Please enter a valid email address ending with .eng.asu.edu.eg';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock), // Use lock icon
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                // Toggle the visibility of the password
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          obscureText:
                              _obscureText, // Set the obscureText property
                          validator: (value) {
                            // Password validation
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            // Password must include alphabets and numbers and be at least 8 characters long
                            RegExp regex =
                                RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$');
                            if (!regex.hasMatch(value)) {
                              return 'Password must include alphabets and numbers, and be at least 8 characters long';
                            }
                            return null; // Return null if validation succeeds
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 25.sp),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () {
                              // Navigate to the login page
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
