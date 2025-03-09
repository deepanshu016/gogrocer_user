import 'package:flutter/material.dart';
import 'package:user/models/businessLayer/place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion?> {
  final String sessionToken;

  late PlaceApiProvider apiClient;

  AddressSearch(this.sessionToken): super(searchFieldDecorationTheme: const InputDecorationTheme(
    border: UnderlineInputBorder(borderSide: BorderSide.none),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
    hintStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
    ),
  )) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isNotEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == "" ? null : apiClient.fetchSuggestions(query, Localizations.localeOf(context).languageCode),
      builder: (context, AsyncSnapshot<List<Suggestion>?> snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text((snapshot.data![index]).description!),
                    onTap: () {
                      close(context, snapshot.data![index]);
                    },
                  ),
                  itemCount: snapshot.data!.length,
                )
              : const Text(
              'Loading...',
                              ),
    );
  }
}
