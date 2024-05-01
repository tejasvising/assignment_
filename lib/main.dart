import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenAI Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _textController = TextEditingController();
  List<Map<String, String>> _chat = [];

  Future<String> getOpenAIResponse(String query) async {
    String apiKey = 'your-api-key';
    String endpoint = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": query}
      ],
      'prompt': query,
      'max_tokens': 50,
    };

    var response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: json.encode(body),
    );
    print(json.decode(response.body));
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['choices'][0]['text'];
    } else {
      return "sorry!!! some network issue..try again later";
      throw Exception('Failed to fetch response from OpenAI API');
    }
  }

  void _handleSubmit(String query) async {
    String response = await getOpenAIResponse(query);
    setState(() {
      _chat.add({'User': query});
      _chat.add({'AI': response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenAI Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  text: _chat[index].values.first,
                  isUser: _chat[index].keys.first == 'User',
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your query here...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _handleSubmit(_textController.text);
                      _textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
