import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Models/review_model.dart';

// ignore: must_be_immutable
class ReviewDetailsPage extends StatelessWidget {
  Review review;
  ReviewDetailsPage({required this.review});

  @override
  Widget build(BuildContext context) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(review.timeEpochSeconds! * 1000);
    var formattedDate = formatDate(date, [d, ' ', M, ' ', yyyy]);
    return Scaffold(
        appBar: AppBar(
          title: Text("Review Details"),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 15,),
                  Image.network(review.profilePhotoURL!),
                  SizedBox(height: 15,),
                  Container(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(review.authorName!,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Commented on: " + formattedDate,
                    style: TextStyle(color: Colors.grey),),
                  ),
                  SizedBox(height: 30,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(review.content!, 
                    style: TextStyle(fontSize: 16, height: 1.5),),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
