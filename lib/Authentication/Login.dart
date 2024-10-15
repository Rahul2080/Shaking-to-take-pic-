import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shakingpic/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SignUp.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passwordVisible = true;
  bool isLoading = false; // To manage loading state
  var formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Function to display a snackbar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 300.h),
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
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: passwordVisible,
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
                              ? Icon(Icons.visibility_off_outlined)
                              : Icon(Icons.visibility),
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
                  SizedBox(height: 50.h),
                  GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true; // Start loading
                        });
                        try {
                          await auth.signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Home()));
                        } on FirebaseAuthException catch (e) {
                          String message;
                          if (e.code == 'user-not-found') {
                            message = 'No user found for that email.';
                          } else if (e.code == 'wrong-password') {
                            message = 'Incorrect password, please try again.';
                          } else {
                            message = 'Login failed: ${e.message}';
                          }
                          _showSnackBar(message);
                        } catch (e) {
                          _showSnackBar("An unexpected error occurred. Please try again.");
                        } finally {
                          setState(() {
                            isLoading = false; // End loading
                          });
                        }
                      }
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
                          'Login',
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
                          'Create an Account',
                          style: TextStyle(
                            color: Color(0xFF575757),
                            fontSize: 18.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => Signup()));
                          },
                          child: Text(
                            "Signup",
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

}
