import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp_game/api/crud.dart';

import 'package:http/http.dart' as http;

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  double textsize = 0.07;

  bool isReady = false;
  bool isFetch = false;

  List<ModelClass> items = [];

  get child => null;

  @override
  void initState() {
    fetchResult();
    print(items);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game title.
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02),
              child: Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * textsize,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius:
                          MediaQuery.of(context).size.height * textsize * 0.2,
                      color: Colors.white,
                      offset: const Offset(0, 0),
                    )
                  ],
                ),
              ),
            ),
            // score item
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: scoreSheet(),
            ),

            // Back button.
            Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: ElevatedButton(
                        onPressed: () {
                          fetchResult();
                        },
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget scoreSheet() {
    return Visibility(
      visible: isReady,
      replacement: const Center(
        child: CircularProgressIndicator(),
      ),
      child: isFetch
          ? ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                String recordTime = getTime(item.timestamp);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(item.name),
                  subtitle: Text('score: ${item.score}, $recordTime'),
                );
              },
            )
          : const Center(child: Text('fail to connect server')),
    );
  }

  Future<void> fetchResult() async {
    setState(() {
      items = [];
      isReady = false;
      isFetch = false;
    });

    const url = 'https://fypgame-15939-default-rtdb.firebaseio.com/result.json';
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map;
      List temp = data.entries.map((e) => (e.value)).toList();

      List<ModelClass> modelList = [];

      for (var e in temp) {
        modelList.add(ModelClass.fromJson(e));
      }

      modelList.sort((a, b) => b.score.compareTo(a.score));

      print(modelList);

      setState(() {
        items = modelList;
        isReady = true;
        isFetch = true;
      });
    } else {
      setState(() {
        isReady = true;
        isFetch = false;
      });
    }
  }

  String getTime(int timestamp) {
    DateTime recordTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return '${recordTime.hour}:${recordTime.minute}:${recordTime.second} ${recordTime.day}-${recordTime.month}-${recordTime.year}';
  }
}
