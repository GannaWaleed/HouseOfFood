import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_of_food/HomePage2.dart';
import 'HomePage2.dart';
import 'chooser.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus =
      FocusNode(); // Add a FocusNode for the password field
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor:Color(0xFFFFFFFF),
      body:SingleChildScrollView( 
        child: Padding(
        padding: const EdgeInsets.only(top: 170.0,bottom: 200.00,left: 16.0,right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/chef logo.jpg', // Replace with the actual path to your image
              width: 430, // Adjust the width as needed
              height: 270, // Adjust the height as needed
            ),
            SizedBox(height: 16),
            Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  // If the field is focused, change the text color to black
                  emailController
                    ..text = '' // Clear the text if needed
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: emailController.text.length));
                }
              },
              child: TextField(
                controller: emailController,
                focusNode: _emailFocus,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: _emailFocus.hasFocus ? Colors.black : Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black), // Border color when focused
                    borderRadius:
                        BorderRadius.circular(30), // Adjust the corner radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey), // Border color when not focused
                    borderRadius:
                        BorderRadius.circular(30), // Adjust the corner radius
                  ),
                ),
                style: TextStyle(
                  color: Colors.black, // Text color
                ),
                cursorColor: Colors.black, // Text cursor color
              ),
            ),
            SizedBox(height: 16),

            // Password field with visibility toggle
            TextField(
              controller: passwordController,
              focusNode: _passwordFocus,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                labelStyle: TextStyle(
                  color: _passwordFocus.hasFocus ? Colors.black : Colors.grey,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Border color when focused
                  borderRadius:
                      BorderRadius.circular(30), // Adjust the corner radius
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey), // Border color when not focused
                  borderRadius:
                      BorderRadius.circular(30), // Adjust the corner radius
                ),
              ),
              obscureText: !_isPasswordVisible,
              style: TextStyle(
                color: Colors.black, // Text color
              ),
              cursorColor: Colors.black, // Text cursor color
            ),

            SizedBox(height: 16),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 113, 21, 15)),
                onPressed: () {
                  _signInWithEmailAndPassword();
                  checkCredentials(
                      emailController.text, passwordController.text);
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                )),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Navigate to the chooser page when the user wants to register
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => chooser(),
                  ),
                );
              },
              child: Text(
                'Don\'t have an account ? Register now',
                style: TextStyle(color: Color.fromARGB(255, 113, 21, 15)),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Future<bool> checkCredentials(String email, String password) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot usersQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();
    return usersQuery.docs.isNotEmpty;
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // After successful login, get the user ID
      String userId = userCredential.user?.uid ?? '';

      // Check if the user exists in the users collection
      bool userExists = await _checkUserExists(userId);

      if (userExists) {
        // Navigate to the home page with the user ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage2(userId: userId),
          ),
        );

        // Show success message using a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message using a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email is incorrect '),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message using a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User does not exists'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _checkUserExists(String userId) async {
    // Check if the user exists in the users collection
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    return userDoc.exists;
  }
}
  
