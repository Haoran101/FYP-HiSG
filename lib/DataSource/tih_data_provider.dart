import 'dart:convert';

import 'api_key.dart' as tih_api;
import 'package:http/http.dart';

// ignore: non_constant_identifier_names
final API_KEY = tih_api.tih_authentication_key;

class TIHDataProvider {
  final httpClient = Client();

  Future<List<Map<String, dynamic>>?> getTIHSearchResult(text) async {
    String requestURL =
        "https://tih-api.stb.gov.sg/content/v1/search/all?dataset=event%2C%20precincts%2C%20tour%2C%20walking_trail&keyword=$text&language=en&distinct=Yes&apikey=$API_KEY";
    final Uri request = Uri.parse(requestURL);

    print(request.toString());
    final response = await httpClient.get(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status']['message'] == 'OK') {
        final list = result['data']['results'];
        print(list);
        final jsonPlaceList = List.generate(
          list.length,
          (index) => list[index] as  Map<String, dynamic>
        );
        return jsonPlaceList;
      } else {
        print("Error fetching data from TIH API!");
        return null;
      }
    }
  }

  static String getImageURLByImageUUID(String uuid) {
    String imageURL = 
      "https://tih-api.stb.gov.sg/media/v1/download/uuid/$uuid/?apikey=$API_KEY";
    return imageURL;
  }
}
