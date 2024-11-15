import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:appointment/services/apiService.dart';
import 'package:appointment/services/secureStorageService.dart';

Future<void> getAPIKeysandSave() async{
  try{
    if (await SecureStorage().getAndroidGoogleClientId() == null){
      final response = await Apiservice().fetchData('/api/keys');
      final apiKeys = jsonDecode(response.body);
      print(apiKeys);
      await SecureStorage().writeAndroidGoogleClientId(apiKeys["googleClientId"]);
      await SecureStorage().writeIOSClientId(apiKeys["IOSgoogleClientId"]);
      await SecureStorage().writeGoogleIssuer(apiKeys["googleIssuer"]);
      await SecureStorage().writeGoogleRedirectUri(apiKeys["redirectURI"]);  
    }
    
  }catch(e){
    print(e);
    // rethrow;
  }
}

Future<void> getCertFromServer() async {
  try{
    final response = await http.get(Uri.parse("https://appointment.crabdance.com/cert"));
    final cert = jsonDecode(response.body);
    print(cert);
    await SecureStorage().writeCert(base64Encode(cert["cert"]["data"]));

  }catch(e){
    print(e);
  }
}