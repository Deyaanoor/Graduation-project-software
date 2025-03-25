import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<Map<String, String>> messages = [];
  final List<String> messageOrder = [
    'Make',
    'Model',
    'Problem',
    'Symptoms',
    'Year'
  ];
  final Map<String, String> userInput = {};
  int currentStep = 0;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showWelcomeMessage();
  }

  void _showWelcomeMessage() {
    messages.add({
      'text': 'مرحبًا بك في CarAI\nكيف يمكنني مساعدتك في حل مشكلتك اليوم؟',
      'isBot': 'true',
    });
    setState(() {});
  }

  void _addUserMessage(String field, String value) {
    setState(() {
      userInput[field] = value;
      messages.add({
        'text': '${_getFieldName(field)}: $value',
        'isBot': 'false',
      });
      currentStep++;
      _controller.clear();
    });
  }

  String _getFieldName(String field) {
    switch (field) {
      case 'Make':
        return 'Make';
      case 'Model':
        return 'Model';
      case 'Problem':
        return 'Problem';
      case 'Symptoms':
        return 'Symptoms';
      case 'Year':
        return 'Year';
      default:
        return field;
    }
  }

  Future<void> _sendDataToAPI() async {
    final url = 'https://1f17-35-226-214-73.ngrok-free.app/predict';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'Make': userInput['Make'],
        'Model': userInput['Model'],
        'Problem': userInput['Problem'],
        'Symptoms': userInput['Symptoms'],
        'Year': int.parse(userInput['Year'] ?? '0'),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final solution = responseData['Solution'];

      setState(() {
        messages.add({
          'text': 'Solution: $solution',
          'isBot': 'true',
        });
      });
    } else {
      setState(() {
        messages.add({
          'text': 'حدث خطأ أثناء الاتصال بالسيرفر.',
          'isBot': 'true',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200]!,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(messages[index]);
              },
            ),
          ),
          if (currentStep < messageOrder.length) _buildTextInputField(),
          if (currentStep >= messageOrder.length) _buildGoButton(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('CarAI Assistant',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, String> message) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message['isBot'] == 'true'
              ? Colors.orange.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Text(
          message['text']!,
          style: TextStyle(
              fontSize: 16,
              color:
                  message['isBot'] == 'true' ? Colors.orange : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTextInputField() {
    String currentField = messageOrder[currentStep];

    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: _getFieldName(currentField),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              if (_controller.text.isNotEmpty) {
                _addUserMessage(currentField, _controller.text);
              }
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoButton() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: InkWell(
        onTap: () => _sendDataToAPI(),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            ),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_motion, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'ابدأ التحليل',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
