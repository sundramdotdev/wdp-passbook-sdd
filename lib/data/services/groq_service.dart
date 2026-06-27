import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  final String apiKey;
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  GroqService(this.apiKey);

  Future<Map<String, dynamic>?> parseTransaction(String text) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "llama3-8b-8192", // Fast and capable model
        "messages": [
          {
            "role": "system",
            "content": """You are an AI assistant for a personal finance app. 
Your job is to parse the user's natural language input (which could be in Hindi, English, or Hinglish) into a structured JSON representing a financial transaction.

Output exactly a JSON object with these keys:
- "amount": (number) The amount of money involved.
- "merchant": (string) Who the money was paid to or received from (e.g. "Chai wala", "Amazon"). If unknown, use "Unknown".
- "isCredit": (boolean) true if the user received money, false if they spent money.
- "category": (string) Choose the best fit from: "Food", "Education", "Travel", "Medical", "Fun", "Shopping", "Hostel", "Utilities", "Others".
- "remark": (string) A short summary of the transaction (e.g. "chai aur momos").

Do NOT include any other text in your response besides the JSON.
"""
          },
          {
            "role": "user",
            "content": text
          }
        ],
        "temperature": 0.1,
        "response_format": {"type": "json_object"}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return jsonDecode(content) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to parse transaction: ${response.body}');
    }
  }
}
