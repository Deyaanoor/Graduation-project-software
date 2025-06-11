import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void _showWelcomeMessage([Map<String, dynamic>? lang]) {
    messages.add({
      'text': lang?['chatWelcome'] ??
          'Welcome to CarAI\nHow can I help you with your problem today?',
      'isBot': 'true',
    });
    setState(() {});
  }

  void _addUserMessage(
    String field,
    String value,
    Map<String, dynamic> lang,
  ) {
    setState(() {
      userInput[field] = value;
      messages.add({
        'text': '${_getFieldName(field, lang)}: $value',
        'isBot': 'false',
      });
      currentStep++;
      _controller.clear();
    });
  }

  String _getFieldName(String field, Map<String, dynamic> lang) {
    switch (field) {
      case 'Make':
        return lang['make'] ?? 'Make';
      case 'Model':
        return lang['model'] ?? 'Model';
      case 'Problem':
        return lang['problem'] ?? 'Problem';
      case 'Symptoms':
        return lang['symptoms'] ?? 'Symptoms';
      case 'Year':
        return lang['year'] ?? 'Year';
      default:
        return field;
    }
  }

  Future<void> _sendDataToAPI(
    Map<String, dynamic> lang,
  ) async {
    final url = '${dotenv.env['car_API_URL']}/predict';

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
          'text': lang['serverError'] ?? 'A server error occurred.',
          'isBot': 'true',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final lang = ref.watch(languageProvider);
      final theme = Theme.of(context);
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(messages[index], theme, lang);
                },
              ),
            ),
            if (currentStep < messageOrder.length)
              _buildTextInputField(theme, lang),
            if (currentStep >= messageOrder.length) _buildGoButton(theme, lang),
          ],
        ),
      );
    });
  }

  Widget _buildMessageItem(
      Map<String, String> message, ThemeData theme, Map<String, dynamic> lang) {
    final isBot = message['isBot'] == 'true';
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBot
              ? theme.colorScheme.primary.withOpacity(0.08)
              : theme.cardColor,
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
            color: isBot
                ? theme.colorScheme.primary
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputField(ThemeData theme, Map<String, dynamic> lang) {
    String currentField = messageOrder[currentStep];
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: _getFieldName(currentField, lang),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                filled: true,
                fillColor: theme.cardColor,
              ),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              if (_controller.text.isNotEmpty) {
                _addUserMessage(currentField, _controller.text, lang);
              }
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
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

  Widget _buildGoButton(ThemeData theme, Map<String, dynamic> lang) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: InkWell(
        onTap: () => _sendDataToAPI(lang),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8)
              ],
            ),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
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
                lang['startAnalysis'] ?? 'ابدأ التحليل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
