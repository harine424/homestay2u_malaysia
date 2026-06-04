import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/homestay.dart';
import 'homestay_card.dart';

class HomestayListScreen extends StatefulWidget {
  const HomestayListScreen({super.key});

  @override
  State<HomestayListScreen> createState() => _HomestayListScreenState();
}

class _HomestayListScreenState extends State<HomestayListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Homestay> _homestays = [];
  List<String> _searchHistory = [];

  bool _isLoading = true;
  String _errorMessage = "";

  String _filterState = "";
  String _filterDistrict = "";
  int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _fetchHomestays(); // Load default list

    // Trigger pagination when scrolling to the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          _limit += 20;
        });
        _fetchHomestays(_searchController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 5) {
        _searchHistory.removeLast();
      }
      await prefs.setStringList('searchHistory', _searchHistory);
      setState(() {});
    }
  }

  Future<void> _fetchHomestays([String keyword = ""]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      var uri = Uri.parse("http://slum78.myddns.me/homestay2u/api/homestays");
      Map<String, String> params = {};

      // Build API Parameters
      if (keyword.isNotEmpty) {
        params['search'] = keyword;
      } else {
        if (_filterState.isNotEmpty) {
          params['state'] = _filterState;
        }
        if (_filterDistrict.isNotEmpty) {
          params['district'] = _filterDistrict;
        }
      }

      params['limit'] = _limit.toString();

      if (params.isNotEmpty) {
        uri = uri.replace(queryParameters: params);
      }

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        List dynamicList = [];

        if (decodedData is List) {
          dynamicList = decodedData;
        } else if (decodedData is Map) {
          dynamicList = decodedData['data'] ?? decodedData['homestays'] ?? [];
        }

        if (dynamicList.isEmpty) {
          setState(() {
            _errorMessage = "No homestay found.";
            _homestays = [];
          });
        } else {
          setState(() {
            _homestays = dynamicList
                .map(
                  (json) => Homestay.fromJson(Map<String, dynamic>.from(json)),
                )
                .toList();
          });
        }
      } else {
        setState(() {
          _errorMessage = "Unable to load data from server.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Please check your internet connection.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    FocusScope.of(context).unfocus();

    // Clear filters when running a direct search
    _filterState = "";
    _filterDistrict = "";
    _limit = 20;

    final query = _searchController.text.trim();
    _saveSearchHistory(query);
    _fetchHomestays(query);
  }

  void _showFilterDialog() {
    TextEditingController stateController = TextEditingController(
      text: _filterState,
    );
    TextEditingController districtController = TextEditingController(
      text: _filterDistrict,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filter Homestays"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stateController,
                decoration: const InputDecoration(
                  labelText: "State (e.g. Sabah, Johor)",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: districtController,
                decoration: const InputDecoration(
                  labelText: "District (e.g. Pontian)",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _filterState = "";
                _filterDistrict = "";
                _limit = 20;
                _searchController.clear();
                Navigator.pop(context);
                _fetchHomestays();
              },
              child: const Text("Clear"),
            ),
            ElevatedButton(
              onPressed: () {
                _filterState = stateController.text.trim();
                _filterDistrict = districtController.text.trim();
                _limit = 20;
                _searchController.clear();
                Navigator.pop(context);
                _fetchHomestays();
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Homestay2U Malaysia"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search homestays...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Search"),
                ),
              ],
            ),
          ),
          if (_searchHistory.isNotEmpty && _searchController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(_searchHistory[index]),
                        onPressed: () {
                          _searchController.text = _searchHistory[index];
                          _onSearch();
                        },
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading && _homestays.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                  )
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      _limit = 20;
                      await _fetchHomestays(_searchController.text.trim());
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _homestays.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _homestays.length) {
                          return _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        return HomestayCard(homestay: _homestays[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
