import 'package:appointment/services/certPinnedHTTPS.dart';
import 'package:appointment/services/initKeys.dart';
import 'package:appointment/services/secureStorageService.dart';
import 'package:appointment/utils/createPrivateKey.dart';
import 'package:http/http.dart' as http;

class Apiservice{
    final http.Client _client = BaseHttpClient().client;
    final String baseurl = "https://appointment.crabdance.com";
    // final String baseurl = "http://192.168.0.144:3000";

    //all routes are verified using the google ouath id token since they contain the necessary info
    Future<http.Response> fetchData(String url) async {
      final idToken = await SecureStorage().getIdToken();
      print('id $idToken');
      try{
        final response = await _client.get(Uri.parse(baseurl+url),
          headers: {'Authorization': 'Bearer $idToken'});
        if (response.statusCode == 200) {
          return response;
        } else {
          throw Exception('Failed to load data');
        }
      }catch(e){
        print("error $e");
        rethrow;
      }   
    }

    Future<http.Response> sendData(String url, Object? body) async {
      final idToken = await SecureStorage().getIdToken();
      try{
        final response = await _client.post(Uri.parse(baseurl+url),
                headers: {
                  "Content-Type": "application/json",
                  'Authorization': 'Bearer $idToken',
                  },
                body: body
              );
        if (response.statusCode == 200) {
          return response;
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        rethrow;
      }
    }

    Future<http.Response> deleteData(String url) async {
      final idToken = await SecureStorage().getIdToken();
      try{
        final response = await _client.delete(Uri.parse(baseurl+url),
        headers: {'Authorization': 'Bearer $idToken'}
        );
        if (response.statusCode == 200) {
        return response;
        } else {
          throw Exception('Failed to load data');
        }
      }catch(e){
        rethrow;
      }   
    }  
}
Future<http.Response> fetchDataUsingJWT(String url) async {
  final String baseurl = "https://appointment.crabdance.com";
  try{
    final jwt = await SecureStorage().getJWT();
    final jwtPrivatKey = await SecureStorage().getJWTPrivateKey();
    final verified = await checkJWT(jwtPrivatKey!);
    if (verified){
      final response = await http.get(Uri.parse(baseurl+url),
      headers: {"Authorization":"Bearer $jwt"}
      );
      if (response.statusCode == 200){
        return response;
      } else {
        throw Exception("There was an error fetching data");
      }
    }else{
      throw Exception("jwt exception");
      
    }
    
  }catch(e){
    print(e);
    if (e.toString() == "jwt exception"){
      await SecureStorage().clearJWT();
      await initKeys();
      return await fetchDataUsingJWT(url);
    }
    rethrow;
  }
}