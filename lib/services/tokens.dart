import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage{
    static final SecureStorage instance = SecureStorage._();
    factory SecureStorage() => instance;
    SecureStorage._();

    late final FlutterSecureStorage _secureStorage;

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

    Future<void> clearTokens() async{
      await _secureStorage.delete(key: "access_token");
      await _secureStorage.delete(key: "refresh_token");
      await _secureStorage.delete(key: "id_token");
      await _secureStorage.delete(key: "expiry_time");
    }

}

