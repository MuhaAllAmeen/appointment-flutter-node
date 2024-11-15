import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage{
    static final SecureStorage instance = SecureStorage._();
    factory SecureStorage() => instance;
    SecureStorage._();

    late final FlutterSecureStorage _secureStorage;
    //retrieve and write all the tokens using flutter_secure_storage
    void init(){
      _secureStorage = const FlutterSecureStorage();
    }
    
    Future<String?> getAccessToken() async{
      final access = await _secureStorage.read(key: "access_token");
      return access;
    }

    Future<String?> getRefreshToken() async{
      final refresh = await _secureStorage.read(key: "refresh_token");
      return refresh;
    }

    Future<String?> getIdToken() async{
      final id = await _secureStorage.read(key: "id_token");
      return id;
    }

    Future<int?> getExpiryTime() async{
      final time = await _secureStorage.read(key: "expiry_time");
      return int.parse(time ?? "0");
    }

    Future<String?> getAndroidGoogleClientId() async{
      final clientId = await _secureStorage.read(key: "google_client_id");
      return clientId;
    }

    Future<String?> getGooglRedirectUri() async{
      final redirectUri = await _secureStorage.read(key: "redirect_uri");
      return redirectUri;
    }

    Future<String?> getGoogleIssuer() async{
      final googleIssuer = await _secureStorage.read(key: "google_issuer");
      return googleIssuer;
    }

    Future<String?> getIOSClientId() async{
      final IOSClientId = await _secureStorage.read(key: "ios_client_id");
      return IOSClientId;
    }

    Future<String?> getCert() async{
      final cert = await _secureStorage.read(key: "cert");
      return cert;
    }


    Future<void> writeAccessToken(String token) async{
      await _secureStorage.write(key: "access_token",value: token);
      
    }

    Future<void> writeRefreshToken(String token) async{
      await _secureStorage.write(key: "refresh_token",value: token);
    }

    Future<void> writeIdToken(String token) async{
      await _secureStorage.write(key: "id_token", value: token);
    }

    Future<void> writeExpiryTime(int time) async{
      await _secureStorage.write(key: "expiry_time", value: time.toString());
    }

    Future<void> writeAndroidGoogleClientId(String clientId) async {
    await _secureStorage.write(key: "google_client_id", value: clientId);
    }

    Future<void> writeGoogleRedirectUri(String redirectUri) async {
        await _secureStorage.write(key: "redirect_uri", value: redirectUri);
    }

    Future<void> writeGoogleIssuer(String googleIssuer) async {
        await _secureStorage.write(key: "google_issuer", value: googleIssuer);
    }

    Future<void> writeIOSClientId(String iosClientId) async {
        await _secureStorage.write(key: "ios_client_id", value: iosClientId);
    }

    Future<void> writeCert(String cert) async{
      await _secureStorage.write(key: "cert", value: cert);
    }

    Future<void> clearTokens() async{
      await _secureStorage.delete(key: "access_token");
      await _secureStorage.delete(key: "refresh_token");
      await _secureStorage.delete(key: "id_token");
      await _secureStorage.delete(key: "expiry_time");
    }

}

