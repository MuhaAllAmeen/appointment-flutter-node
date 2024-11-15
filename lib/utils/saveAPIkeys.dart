import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appointment/services/apiService.dart';
import 'package:appointment/services/secureStorageService.dart';

Future<void> getAPIKeysandSave() async{
  try{
    if (await SecureStorage().getAndroidGoogleClientId() == null){
      print('get api keys');
      final response = await Apiservice().fetchData('/api/keys');
      final apiKeys = jsonDecode(response.body);
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
  //only if the app does not have the certificate so that it does not fetch everytime
  try{
    if (await SecureStorage().getCert() == null){
        //get the ssl certificate
      final response = await http.get(Uri.parse("https://appointment.crabdance.com/cert"));
      final cert = jsonDecode(response.body);
      List<int> certData = List<int>.from(cert["cert"]["data"]);
      await SecureStorage().writeCert(base64Encode(certData));
    }
    
  }catch(e){
    print(e);
  }
}