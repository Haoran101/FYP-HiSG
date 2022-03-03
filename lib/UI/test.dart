import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/DataSource/tih_data_provider.dart';
import 'package:wikitude_flutter_app/UI/paintLine.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

import '../DataSource/cloud_firestore.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test>{

  var accesstoken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: RecommendationEngine().getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.hasError){
          print("error capture accesstoken");
        }
        if (snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          body: Text(snapshot.data.toString())
        );
      }
    );
  }
}

// class _TestState extends State<Test> {
//   final UserService _user = UserService();
//   final List<String> lines = ["EWL", "NSL", "NEL", "CCL", "DTL", "TEL", "BP", "SK", "PG"];
//   @override
//   void initState() {
//     super.initState();
//   }

//   getView(String line) async{
//     var data = await MRTProvider().queryMRTLine(line);
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => MRTGraphicsGenerator(data: data!)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(50.0),
//       child: Column(
//         children: List.generate(lines.length, (index) {
//           String line = lines[index];
//           return TextButton(onPressed: 
//           () => getView(line), child: Text(line));
//         })
//       ),
//     );
//   }
// }
