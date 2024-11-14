import 'package:appointment/services/certPinnedHTTPS.dart';
import 'package:http/http.dart' as http;

class Apiservice{
    final http.Client _client = BaseHttpClient().client;
    
    
    Future<http.Response> fetchData(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load data');
    }
  }
}