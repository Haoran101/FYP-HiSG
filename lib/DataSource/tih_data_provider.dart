import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/DataSource/google_maps_platform.dart';
import 'package:wikitude_flutter_app/Models/poi_model.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/Models/tih_model.dart';

import 'api_key.dart' as tih_api;
import 'package:http/http.dart';

// ignore: non_constant_identifier_names
final API_KEY = tih_api.tih_authentication_key;

class TIHDataProvider {
  final httpClient = Client();

  Future<List<Map<String, dynamic>>?> getTIHSearchResult(text) async {
    //%2C%20walking_trail
    String requestURL =
        "https://tih-api.stb.gov.sg/content/v1/search/all?dataset=event%2C%20precincts%2C%20tour&keyword=$text&language=en&distinct=Yes&apikey=$API_KEY";
    final Uri request = Uri.parse(requestURL);

    print(request.toString());
    final response = await httpClient.get(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status']['message'] == 'OK') {
        final list = result['data']['results'];
        print(list);
        final jsonPlaceList = List.generate(
            list.length, (index) => list[index] as Map<String, dynamic>);
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

  Future<List<Map<String, dynamic>>?> getPrecinctItemsByUUID(
      String uuid, int pageNumber) async {
    String requestURL =
        "https://tih-api.stb.gov.sg/content/v1/search/precinct?uuid=$uuid&language=en&apikey=$API_KEY&page=$pageNumber&pageSize=10";
    List<String> selectedDataSet = ["event", "tour", ]; //"walking_trail"
    List<Map<String, dynamic>> searchResultList = [];
    final Uri request = Uri.parse(requestURL);

    print(request.toString());
    final response = await httpClient.get(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status']['message'] == 'OK') {
        final list = result['data'];
        final pageMax = result['totalPages'];
        for (final jsonItem in list) {
          if (selectedDataSet.contains(jsonItem["dataset"])) {
            //data is fetched from TIH dataset
            var tihData = await getJSONDetailsByUUID(
                jsonItem["uuid"], jsonItem["dataset"]);
            if (tihData == null) {
              print(
                  "Failed to fetch TIH data details: uuid: ${jsonItem["uuid"]}, dataset: ${jsonItem["dataset"]}");
              continue;
            } else {
              Map<String, dynamic> innerMap = Map();
              SearchResult tihSearchResult = SearchResult.fromTIH(tihData);
              innerMap["searchResult"] = tihSearchResult;
              if (jsonItem["dataset"] == "event") {
                innerMap["resultModel"] = TIHDetails.fromEventJSON(jsonItem);
              } else if (jsonItem["tour"] == "tour") {
                innerMap["resultModel"] = TIHDetails.fromTourJSON(jsonItem);
              } else {
                //TODO: walking trail
              }
              searchResultList.add(innerMap);
            }
          } else {
            //Get Google Details From CID
            String? cid =
                await getGoogleCIDForTIHSearchResult(jsonItem["uuid"]);
            if (StringUtils.isNullOrEmpty(cid)) {
              print("Failed to fetch CID from uuid: ${jsonItem["uuid"]}");
              continue;
            } else {
              SearchResult googleSearchResult = SearchResult.fromTIH(jsonItem);
              Map<String, dynamic> innerMap = Map();
              innerMap["searchResult"] = googleSearchResult;
              innerMap["resultModel"] = cid;
              searchResultList.add(innerMap);
            }
          }
        }
        searchResultList[0]["maximumPages"] = pageMax;
        return searchResultList;
      } else {
        print("Error fetching data: precinct details from TIH API!");
        return null;
      }
    }
  }

  Future<Map<String, dynamic>?> getJSONDetailsByUUID(
      String uuid, String datasetName) async {
    String datasetParse = datasetName.replaceAll("_", "-");
    String requestURL =
        "https://tih-api.stb.gov.sg/content/v1/$datasetParse?uuid=$uuid&language=en&apikey=$API_KEY";

    final Uri request = Uri.parse(requestURL);

    print(request.toString());
    final response = await httpClient.get(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status']['message'] == 'OK') {
        final data = result['data'][0] as Map<String, dynamic>;
        return data;
      } else {
        print("Error fetching data: precinct details from TIH API!");
        return null;
      }
    }
  }

  Future<String?> getGoogleCIDForTIHSearchResult(String uuid,
      {bool test = false}) async {
    String requestURL =
        "https://tih-api.stb.gov.sg/map/v1/place/$uuid?apikey=$API_KEY";
    final Uri request = Uri.parse(requestURL);
    final response = await httpClient.get(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status']['message'] == 'OK') {
        final data = result['data'] as Map<String, dynamic>;
        var cid = data["url"].replaceAll("https://maps.google.com/?cid=", "");
        return cid;
      } else {
        print("Error fetching data: precinct details from TIH API!");
        return null;
      }
    }
  }
}

class RecommendationEngine {
  final httpClient = Client();

  Future<String?> getAccessToken() async {
    var headers = {
      'authorization': 'Basic ${tih_api.tih_test_base64}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    var params = {
      'apikey': tih_api.tih_test_api_key,
    };
    var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');

    var data = 'grant_type=client_credentials';
    var uri = Uri.parse('https://api-test.stb.gov.sg/oauth/accesstoken?$query');

    var res = await httpClient.post(uri, headers: headers, body: data);
    if (res.statusCode != 200) {
      print('http.post error - accessToken: statusCode= ${res.statusCode}');
      return null;
    }
    final result = json.decode(res.body) as Map<String, dynamic>;
    print(result.toString());
    return result["access_token"];
  }

  Future<List?> getRecommendationInitaryDataTIH(
    List<String> interests,
    String startDate,
  ) async {
    var accessToken = await getAccessToken();

    if (accessToken == null) {
      print("Access Token failed to retrieve. Use Backup Dataset instead.");
      return null;
    }

    String url =
        "https://api-test.stb.gov.sg/service/v1/itineraries/recommendations?startDate=$startDate&endDate=$startDate&interest=${interests.join(',')}";

    var headers = {
      'authorization': 'BearerToken $accessToken',
    };

    var uri = Uri.parse(url);
    var res = await httpClient.get(uri, headers: headers);
    if (res.statusCode != 200) {
      print('http.get error - TIH Initary: statusCode= ${res.statusCode}');
      return null;
    }
    final result = json.decode(res.body) as Map<String, dynamic>;
    var schedule = result["data"]["schedule"][0]["items"];

    return schedule;
  }

  Future<List<SearchResult>> getRecommendationFromBackUpDatabase(List<String> interests) async{
    List<SearchResult> items = await TIHBackupProvider().getBackupSearchResultList(interests);
    return items;
  }

  int _compareScores(String a, String b, name) {
    if (_getScore(a, name) < _getScore(b, name)) {
      return -1;
    }
    if (_getScore(a, name) > _getScore(b, name)) {
      return 1;
    }
    return 0;
  }

  int _getScore(term, name) {
    return -tokenSetPartialRatio(name.toString().toLowerCase(),
            term.toString().toLowerCase())
        .toInt();
  }

  Future<List<SearchResult>> getRecommendResult(
    List<String> interests,
    String startDate,
  ) async {
    var schedule = await getRecommendationInitaryDataTIH(interests, startDate);
    var searchResultList = <SearchResult>[];
    if (schedule != null){
      //process schedule data
      for (var item in schedule){
        
        try {
          item = item["data"];
          var loc = item["location"]["latitude"].toString() + "," + item["location"]["longitude"].toString();
          var googleJSONList = await PlaceApiProvider().getGooglePlaceListByTextSearch(item["name"], location: loc);
          //fuzzywuzzy sort
          googleJSONList?.sort((a, b) => _compareScores(a["name"], b["name"], item["name"]));
          searchResultList.add(SearchResult.fromGoogle(googleJSONList![0]));
        } catch (e, stackTrace) {
          print(e);
          print(stackTrace);
          continue;
        }
      }

    } else {
      searchResultList = await getRecommendationFromBackUpDatabase(interests);
    }

    return searchResultList;
  }
}
