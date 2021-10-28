import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'emptySearch.dart';

class searchPage extends StatefulWidget {
  const searchPage({ Key? key }) : super(key: key);

  @override
  _searchPageState createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> with TickerProviderStateMixin {
  static const historyLength = 3;
  List<String> _searchHistory = ["NTU", "NUS", "SMU"];
  String selectedTerm = "";
  List<String> filteredSearchHistory = [];
  
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

  Widget _getSearchbody(selectedTerm){
    if (selectedTerm.isEmpty){
      return EmptySearchScreen();
    } else {
      return SearchResultsListView(
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
      isScrollControlled: true,
      onSubmitted: (query) {
          setState(() {
            addSearchTerm(query);
            selectedTerm = query;
          });
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
      });
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
              });
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
        child: _getSearchbody(selectedTerm)
  ),
    ),
    );
  }
}

class SearchResultsListView extends StatelessWidget {
  const SearchResultsListView({ Key? key, @required this.searchTerm}) : super(key: key);
  final searchTerm;
  @override
  Widget build(BuildContext context) {
    final fsb = FloatingSearchBar.of(context);
    return ListView(
      padding: EdgeInsets.only(top: fsb.height + fsb.margins.vertical),
      children: List.generate(
        10,
        (index) => 
           searchResultCard(title: "$searchTerm $index"),
        
      ),
    );
  }
}

class searchResultCard extends StatelessWidget {
  final title;
  const searchResultCard({ Key? key , @required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Image.asset("assets/img/placeholder.png"),
              title: Text(this.title),
              subtitle: Text('subtitle'),
       )]))
    );
  }
}

