import 'package:flutter/material.dart';
const pinkRedColor = Color.fromRGBO(255, 0, 117, 1);

class SignInScreen extends StatelessWidget {
  const SignInScreen({ Key? key }) : super(key: key);

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
              children: const <TextSpan>[
                TextSpan(text: 'HiSG', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: pinkRedColor)),
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
            backgroundColor: MaterialStateProperty.all<Color>(pinkRedColor),
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
            backgroundColor: MaterialStateProperty.all<Color>(pinkRedColor),
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