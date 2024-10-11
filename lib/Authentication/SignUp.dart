import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shakingpic/Home.dart';


import 'Login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool passwordvisible = true;
  var formkey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 300),
              child: Center(
                child: TextFormField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter Your Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (namecontroller.text.isEmpty) {
                      return 'Enter a valid email!';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: TextFormField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Username or Email',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (emailvalue) {
                    if (emailvalue!.isEmpty ||
                        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(emailvalue)) {
                      return 'Enter a valid email!';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Center(
                child: TextFormField(
                  obscureText: passwordvisible,
                  controller: passwordcontroller,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: passwordvisible == false
                          ? Icon(
                        Icons.visibility,
                        color: Color(0xFFA7B0BB),
                      )
                          : Icon(
                        Icons.visibility_off_outlined,
                        color: Color(0xFFA7B0BB),
                      ),
                      onPressed: () {
                        setState(() {
                          passwordvisible = !passwordvisible;
                        });
                      },
                    ),),
                  validator: (passwordvalue) {
                    if (passwordvalue!.isEmpty || passwordvalue.length < 6) {
                      return 'Enter a valid password!';
                    }

                    return null;
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                final isValid = formkey.currentState?.validate();
                if (isValid!) {
                  auth
                      .createUserWithEmailAndPassword(
                      email: emailcontroller.text, password: passwordcontroller.text)
                      .then((onValue) {
                    firestore.doc(auth.currentUser!.uid.toString()).set({
                      "name": namecontroller.text,
                      "id": auth.currentUser!.uid.toString(),
                      "email": emailcontroller.text,
                      "password": passwordcontroller.text,
                    });
                  }).then((onValue){  Navigator.of(context)
                      .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => Home()),(route)=>false);});

                }
                formkey.currentState?.save();
              },
              child: Container(
                width: 317,
                height: 55,
                decoration: ShapeDecoration(
                  color: Color(0xFFF73658),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 70),
              child:
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text(
                  'I Already Have an Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF575757),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => Login()));
                  },
                  child: Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Color(0xFFF73658),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}