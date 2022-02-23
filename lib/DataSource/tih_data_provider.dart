import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
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
    List<String> selectedDataSet = ["event", "tour", "walking_trail"];
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

  Future<String?> getGoogleCIDForTIHSearchResult(String uuid) async {
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

  Future<String?> getAccessToken() async {
    var headers = {
      'authorization':
          'Basic M2lnWUJFOUJJV0FIZjhPSEJrakFSeU5WNm1NZ0c2aU46SWN3YzZjYmkyNHYwS0lDZQ==',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    var params = {
      'apikey': '3igYBE9BIWAHf8OHBkjARyNV6mMgG6iN',
    };
    var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');

    var data = 'grant_type=client_credentials';
    var uri = Uri.parse('https://api-test.stb.gov.sg/oauth/accesstoken?$query');

    var res = await httpClient.post(uri, headers: headers, body: data);
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    final result = json.decode(res.body) as Map<String, dynamic>;
    print(result.toString());
    return result["access_token"];
  }

  
}
