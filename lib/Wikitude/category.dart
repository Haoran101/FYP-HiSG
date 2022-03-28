import 'sample.dart';

class Category {
  
  List<Sample> samples;

  Category({required this.samples});

  factory Category.fromJson(Map<String, dynamic> jsonMap){
    List<dynamic> samplesFromJson = jsonMap["samples"];
    List<Sample> samples = [];
    //remove -1 to show badges
    for(int i = 0; i < samplesFromJson.length -1; i++) {
      samples.add(new Sample.fromJson(samplesFromJson[i]));
    }

    return Category(
      samples: samples
    );
  }
}