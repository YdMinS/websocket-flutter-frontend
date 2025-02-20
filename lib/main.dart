import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));
  var cnt = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Thru WebSocket'),
        ),
        body: Column(
          children: [
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print('Waiting');
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error : ' + snapshot.error.toString());
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  print('Received Data : ' + snapshot.data);
                  cnt++;
                  return Center(child: Text('${snapshot.data}'));
                } else {
                  print('No Data');
                  return Center(child: Text('No data'));
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                channel.sink.add(cnt.toString());
              },
              child: Text('SEND'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }
}
