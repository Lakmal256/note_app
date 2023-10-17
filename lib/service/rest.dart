import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert' as convert;

import 'service.dart';

class RestService {
  String authority;

  RestService({
    required this.authority,
  });

  Future<List<QuotesDto>?> fetchQuotes() async {
    final response = await http.get(
      Uri.https(authority, "/api/quotes"),
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<QuotesDto> quotes = [];
      for (var userJson in jsonBody ?? []) {
        QuotesDto quotesDto = QuotesDto.fromJson(userJson);
        quotes.add(quotesDto);
      }
      return quotes;
    }
    return [];
  }
}