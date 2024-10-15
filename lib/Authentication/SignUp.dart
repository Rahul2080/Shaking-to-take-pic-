import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shakingpic/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passwordVisible = true;
  bool isLoading = false; // For loading state
  var formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance.collection('Users');

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Function to display a snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 300.h),
                    child: Center(
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Enter Your Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a valid name!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Username or Email',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        validator: (emailValue) {
                          if (emailValue!.isEmpty ||
                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(emailValue)) {
                            return 'Enter a valid email!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
                    child: Center(
                      child: TextFormField(
                        obscureText: passwordVisible,
                        controller: passwordController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          suffixIcon: IconButton(
                            icon: passwordVisible
                                ? Icon(
                              Icons.visibility_off_outlined,
                              color: Color(0xFFA7B0BB),
                            )
                                : Icon(
                              Icons.visibility,
                              color: Color(0xFFA7B0BB),
                            ),
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (passwordValue) {
                          if (passwordValue!.isEmpty || passwordValue.length < 6) {
                            return 'Enter a valid password!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () async {
                      final isValid = formKey.currentState?.validate();
                      if (isValid!) {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          UserCredential userCredential = await auth
                              .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text);
                          await firestore.doc(userCredential.user!.uid).set({
                            "name": nameController.text,
                            "email": emailController.text,
                            "id": userCredential.user!.uid,
                          });
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => Home()), (route) => false);
                        } on FirebaseAuthException catch (e) {
                          String errorMessage;
                          if (e.code == 'email-already-in-use') {
                            errorMessage = 'This email is already in use!';
                          } else if (e.code == 'invalid-email') {
                            errorMessage = 'Invalid email format!';
                          } else {
                            errorMessage = 'An error occurred. Please try again!';
                          }
                          _showSnackBar(errorMessage);
                        } catch (e) {
                          _showSnackBar('An unexpected error occurred!');
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                      checkLogin(nameController.text);
                    },
                    child: Container(
                      width: 317.w,
                      height: 55.h,
                      decoration: ShapeDecoration(
                        color: Color(0xFFF73658),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r)),
                      ),
                      child: Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 100.h, left: 70.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'I Already Have an Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF575757),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => Login()));
                          },
                          child: Text(
                            "Login",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFFF73658),
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(), // Loading indicator
            ),
        ],
      ),
    );
  }

  void checkLogin(String userName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
  }
}
