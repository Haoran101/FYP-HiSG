import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:wikitude_flutter_app/DataSource/google_maps_platform.dart';
import '../DataSource/cloud_firestore.dart';
import '../DataSource/tih_data_provider.dart';
import '../Models/search_result_model.dart';
import 'emptySearch.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  static const historyLength = 3;
  List<String> _searchHistory = ["NTU", "NUS", "SMU"];
  String selectedTerm = "";
  List<String> filteredSearchHistory = [];
  List<SearchResult> searchResult = [];

  List<String> filterSearchTerms({
    @required var filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      // Reversed because we want the last added items to appear first in the UI
      return _searchHistory.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      // This method will be implemented soon
      putSearchTermFirst(term);
      return;
    }
    _searchHistory.add(term);
    if (_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }
    // Changes in _searchHistory mean that we have to update the filteredSearchHistory
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((t) => t == term);
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  late FloatingSearchBarController controller;
  @override
  void initState() {
    super.initState();
    controller = FloatingSearchBarController();
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  search() {
    fetchGooglePlacesResultsList(); //Google places search
    fetchTIHResultsList(); //TIH database search
    fetchImage360ResultsList(); //Image 360 search (cloud storage)
    fetchVideo360YoutubeResultsList(); //Video 360 Youtube
    fetchVideo360StorageResultsList(); //Video 360 Storage
    fetchMRTResultsList(); //MRT dataset implemented with places
    fetchHotelResultsList(); //hotel dataset
  }

  fetchGooglePlacesResultsList() async {
    List<Map<String, dynamic>>? placeResult =
        await PlaceApiProvider().getGooglePlaceListByTextSearch(selectedTerm);

    if (placeResult == null) {
      print("No results from Google Places");
    } else {
      var len = placeResult.length;
      print("Place results: $len");
      placeResult.forEach((place) {
        
        if (place["types"].contains("subway_station")) {
          print(place["name"]);
        } else {
          setState(() {
            searchResult.add(SearchResult.fromGoogle(place));
          });
        }
      });
    }
  }

  fetchTIHResultsList() async {
    List<Map<String, dynamic>>? TIHResult =
        await TIHDataProvider().getTIHSearchResult(selectedTerm);
    if (TIHResult == null) {
      print("No results from TIH");
    } else {
      var len = TIHResult.length;
      print("TIHResult results: $len");
      TIHResult.forEach((tih) {
        setState(() {
          searchResult.add(SearchResult.fromTIH(tih));
        });
      });
    }
  }

  fetchArticlesResultsList() async {
    //TODO: fetch articles results list
  }

  fetchImage360ResultsList() async {
    List<Map<String, dynamic>>? Image360Result =
        await Image360Provider().queryImage360ByTitle(selectedTerm);
    if (Image360Result == null) {
      print("No results from Image 360");
    } else {
      var len = Image360Result.length;
      print("Image360Result results: $len");
      Image360Result.forEach((image) {
        setState(() {
          searchResult.add(SearchResult.from360ImageDataset(image));
        });
      });
    }
  }

  fetchVideo360YoutubeResultsList() async {
    List<Map<String, dynamic>>? VideoYoutube360Result =
        await Video360Provider().queryYoutubeVideo360ByTitle(selectedTerm);
    if (VideoYoutube360Result == null) {
      print("No results from Youtube video 360");
    } else {
      var len = VideoYoutube360Result.length;
      print("VideoYoutube360Result results: $len");
      VideoYoutube360Result.forEach((video) {
        setState(() {
          searchResult.add(SearchResult.from360VideoYouTube(video));
        });
      });
    }
  }

  fetchVideo360StorageResultsList() async {
    List<Map<String, dynamic>>? VideoStorage360Result =
        await Video360Provider().queryStorageVideo360ByTitle(selectedTerm);
    if (VideoStorage360Result == null) {
      print("No results from Storage video 360");
    } else {
      var len = VideoStorage360Result.length;
      print("VideoYoutube360Result results: $len");
      VideoStorage360Result.forEach((video) {
        setState(() {
          searchResult.add(SearchResult.from360VideoStorage(video));
        });
      });
    }
  }

  fetchMRTResultsList() async {
    List<Map<String, dynamic>>? mrtResult =
        await MRTProvider().queryMRT(selectedTerm);
    if (mrtResult == null) {
      print("No results from MRT dataset");
    } else {
      var len = mrtResult.length;
      print("mrtResult results: $len");
      mrtResult.forEach((mrt) {
        setState(() {
          searchResult.add(SearchResult.fromMRTdataset(mrt));
        });
      });
    }
  }

  fetchHotelResultsList() async {
    List<Map<String, dynamic>>? hotelResult =
        await HotelProvider().queryHotelByName(selectedTerm);
    if (hotelResult == null) {
      print("No results from Hotels dataset");
    } else {
      var len = hotelResult.length;
      print("hotelResult results: $len");
      hotelResult.forEach((hotel) {
        setState(() {
          searchResult.add(SearchResult.fromHotelsDataset(hotel));
        });
      });
    }
  }

  Widget _getSearchbody(selectedTerm) {
    if (selectedTerm.isEmpty) {
      return EmptySearchScreen();
    } else {
      return SearchResultsListView(
        searchResult: searchResult,
        searchTerm: selectedTerm,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: (EdgeInsets.only(top: 10)),
      child: FloatingSearchBar(
        transition: CircularFloatingSearchBarTransition(),
        physics: BouncingScrollPhysics(),
        actions: [
          FloatingSearchBarAction.searchToClear(),
        ],
        onQueryChanged: (query) {
          setState(() {
            filteredSearchHistory = filterSearchTerms(filter: query);
          });
        },
        isScrollControlled: false,
        onSubmitted: (query) {
          setState(() {
            addSearchTerm(query);
            selectedTerm = query;
            searchResult = [];
          });
          search();
          controller.close();
        },
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.white,
              elevation: 5,
              child: Builder(
                builder: (context) {
                  if (filteredSearchHistory.isEmpty &&
                      controller.query.isEmpty) {
                    return Container(
                      height: 56,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'Start searching',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  } else if (filteredSearchHistory.isEmpty) {
                    return ListTile(
                      title: Text(controller.query),
                      leading: const Icon(Icons.search),
                      onTap: () {
                        setState(() {
                          addSearchTerm(controller.query);
                          selectedTerm = controller.query;
                          searchResult = [];
                        });
                        search();
                        controller.close();
                      },
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: filteredSearchHistory
                          .map(
                            (term) => ListTile(
                              title: Text(
                                term,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(Icons.history),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    deleteSearchTerm(term);
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  putSearchTermFirst(term);
                                  selectedTerm = term;
                                  searchResult = [];
                                });
                                search();
                                controller.close();
                              },
                            ),
                          )
                          .toList(),
                    );
                  }
                },
              ),
            ),
          );
        },
        controller: controller,
        body: FloatingSearchBarScrollNotifier(
            child: _getSearchbody(selectedTerm)),
      ),
    );
  }
}

class SearchResultsListView extends StatelessWidget {
  final searchResult;
  final searchTerm;

  const SearchResultsListView({Key? key, @required this.searchResult, @required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //sort search result on fuzzywuzzy score
    searchResult.sort((a,b) => (-ratio(a.title, searchTerm)).toInt().compareTo(-ratio(b.title, searchTerm)).toInt());
    final fsb = FloatingSearchBar.of(context);
    return ListView(
      padding: EdgeInsets.only(top: fsb.height + fsb.margins.vertical),
      children: List.generate(searchResult.length, (index) {
        var resultItem = searchResult[index];
        print(resultItem.title + ratio(searchTerm, resultItem.title).toString());
        return SearchResultCard(item: resultItem);
      }),
    );
  }
}

class SearchResultCard extends StatelessWidget {
  final item;
  const SearchResultCard({Key? key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ListTile(
          leading: this.item.icon,
          title: Text(this.item.title),
          subtitle: Text(this.item.subtitle))
    ])));
  }
}
