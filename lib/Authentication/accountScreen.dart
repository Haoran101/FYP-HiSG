import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInScreen extends StatefulWidget {
  final String title = "My Account";
  const SignInScreen({ Key? key }) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool justRegistered = false;

  
  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
//5       
          if (user != null) {
            return TextButton(
              child: const Text('Sign out', 
                style: TextStyle(
                  color: Colors.white,
                ), 
            ),
              onPressed: () async {
                if (user == null) {
//6
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No one has signed in.'),
                  ));
                  return;
                }
                await _auth.signOut();
                final String uid = user.uid;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(uid + ' has successfully signed out.'),
                ));
              },
            );
          }
          else {
            return Text("");
          }})
        ],
      ),
      body: Builder(builder: (BuildContext context) {
//7
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(user == null? "No User" : user.email.toString()),
                new _SignInEmailSection(),
              ],
            ),
          )
        );
      }),
    );
  }
}

class LoginSection extends StatelessWidget {
  const LoginSection({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
        SizedBox(height: 150),
        RichText(
            text: TextSpan(
              text: 'Welcome to ',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color:Colors.black),
              children: <TextSpan>[
                TextSpan(text: 'HiSG', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
          SizedBox(height: 50),
          TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email'
          ),
        ),
        SizedBox(height: 30),
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password'
          ),
        ),
        SizedBox(height: 50),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
            foregroundColor: MaterialStateProperty.all<Color> (Colors.white)),
          child: Text("Sign in", style: TextStyle(fontSize: 20),), 
          onPressed: null,)),
          SizedBox(height: 20),
          InkWell(
              child: new Text('Forgot password?', style: TextStyle(color: Colors.blue[900], fontSize: 17, fontWeight: FontWeight.bold,),),
              onTap: null),
          SizedBox(height: 40),
          Align(
          alignment: Alignment.center,
          child: 
          Text("or", 
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black45),
          textAlign: TextAlign.center,
          )),
          SizedBox(height: 40),
          SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor,),
            foregroundColor: MaterialStateProperty.all<Color> (Colors.white)),
          child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'Login with Google ', style: TextStyle(color: Colors.white, fontSize: 20)),
              WidgetSpan(
                  alignment: PlaceholderAlignment.middle, 
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Image.asset("assets/icons/google.png", width: 30,)
                  ),
                ),
      ]
      ),), ),)
      ],
      )
    );
  }
}

class _SignInEmailSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInEmailSectionState();
}

class _SignInEmailSectionState extends State<_SignInEmailSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _popupWindow = false;
  bool _success = false;
  dynamic _userEmail = "";


  void _showLoginStatusDialog() {

    var _dialogContent = _success ? 'Successfully signed in ' + _userEmail: 
    'Email or password entered is incorrect. Please try again.';

    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 12.0,
          content: Container(
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(_dialogContent),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => {
                Navigator.of(context).pop(context)
              }
            )
          ]
        );
    },
  );

  setState(() {
    _popupWindow = false;
  });
}

  void _signInWithEmailAndPassword() async {

  try {
    UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
    email: _emailController.text,
    password: _passwordController.text,
  );

  if (_userCredential.user != null) {
    setState(() {
      _success = true;
      _userEmail = _userCredential.user?.email;
    });
  } else {
    setState(() {
      _success = false;
    });
  }

} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No user found for that email.'))
    );
  } else if (e.code == 'wrong-password') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Wrong password provided for that user.'))
    );
  }
}
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
        Text(
          "popupwindow   " + _popupWindow.toString() + "\n"
          + "success   " + _success.toString() + '\n'
          + "useremail" + _userEmail
        ),
        SizedBox(height: 150),
        RichText(
            text: TextSpan(
              text: 'Welcome to ',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color:Colors.black),
              children: <TextSpan>[
                TextSpan(text: 'HiSG', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
          SizedBox(height: 50),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Email'
            ),
            validator: (String? value) {
              if (value !=null && value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
        ),
        SizedBox(height: 30),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password'
          ),
          validator: (String? value) {
              if (value !=null && value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
        ),
        SizedBox(height: 50),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
            foregroundColor: MaterialStateProperty.all<Color> (Colors.white)),
          child: Text("Sign in", style: TextStyle(fontSize: 20),), 
          onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _signInWithEmailAndPassword();
                }
              },)),
          SizedBox(height: 20),
          InkWell(
              child: new Text('Forgot password?', style: TextStyle(color: Colors.blue[900], fontSize: 17, fontWeight: FontWeight.bold,),),
              onTap: null),
      ],
      )
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}