import 'dart:convert';

import 'package:appointment/services/apiService.dart';
import 'package:appointment/services/secureStorageService.dart';

Future<void> getAPIKeysandSave() async{
  try{
    final response = await Apiservice().fetchData('/api/keys');
    final apiKeys = jsonDecode(response.body);
    print(apiKeys);
    await SecureStorage().writeAndroidGoogleClientId(apiKeys["googleClientId"]);
    await SecureStorage().writeIOSClientId(apiKeys["IOSgoogleClientId"]);
    await SecureStorage().writeGoogleIssuer(apiKeys["googleIssuer"]);
    await SecureStorage().writeGoogleRedirectUri(apiKeys["redirectURI"]);
  }catch(e){
    print(e);
    // rethrow;
  }
}