import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

Future<void> submitResult({name = 'anonymous', score=0}) async {

  Map<String, dynamic> body = {
    "name": name,
    "score": score,
    "timestamp": DateTime.now().millisecondsSinceEpoch,
  };

  final encoding = Encoding.getByName('utf-8');

  const url = 'https://fypgame-15939-default-rtdb.firebaseio.com/result.json';
  final uri = Uri.parse(url);

  final response = await http.post(
    uri,
    body: jsonEncode(body),
    headers: {'Content-Type': 'application/json'},
    encoding: encoding,
  );

  print(response.statusCode);
  print(response.body);
}

Future<void> fetchResultTest() async {
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

  } else {}
}

class ModelClass {
  ModelClass({
    this.name = '',
    this.score = 0,
    this.timestamp = 0,
  });

  String name;
  int score;
  int timestamp;

  factory ModelClass.fromJson(Map<String, dynamic> json) => ModelClass(
        name: json['name'],
        score: json['score'],
        timestamp: json['timestamp'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
        'timestamp': timestamp,
      };
}
