import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

Future<Unko> fetchPost(int randomNumber) async {
  final response =
      await http.get('https://webservice.recruit.co.jp/manabi/station/v2?prefecture=13&key=3e2b4a21beb30b57&format=json&start=' + randomNumber.toString() + '&count=1');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return Unko.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Unko {
  Map results;
  String apiVersion;
  String station;

  Unko({this.results, this.apiVersion, this.station});

  factory Unko.fromJson(Map<String, dynamic> json) {
    return Unko(
      results: json['results'],
      apiVersion: json['results']['api_version'],
      station: json['results']['station'][0]['name']
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
Future<Unko> post;

  var station;

  @override
  void initState() {
    super.initState();
    int randomNumber = new math.Random().nextInt(935);
    post = fetchPost(randomNumber);
  }

  void _handlePressed() {
    setState(() {
      int randomNumber = new math.Random().nextInt(935);
      post = fetchPost(randomNumber);
    });
  }

  void copyText() {
    // コピーするとき
    Clipboard.setData(new ClipboardData(text: station));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'アンジュノ ダーツの旅',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('アンジュノ ダーツの旅'),
        ),
        body: Column(
          children: [
            Center(
              child:
                FutureBuilder<Unko>(
                  future: post,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      station = snapshot.data.station;
                      return Text('今日は' + station + '駅に行くのが良いにゃー！');
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),
            ),
            Center(
              child:
                FlatButton(
                  onPressed: _handlePressed,
                  color: Colors.blue,
                  child: Text(
                    '更新',
                    style: TextStyle(
                      color:Colors.white,
                      fontSize: 20.0
                    ),
                  ),
                ),
            ),
            Center(
              child: 
               FlatButton(
                onPressed: copyText,
                color: Colors.red,
                child: Text(
                  '駅名をコピー',
                  style: TextStyle(
                    color:Colors.white,
                    fontSize: 20.0
                  ),
                ),
               )
            )
          ]
        ),
      ),
    );
  }
}