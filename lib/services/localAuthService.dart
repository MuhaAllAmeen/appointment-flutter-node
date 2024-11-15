import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService{
      // Private static instance
    static final LocalAuthService _instance = LocalAuthService._internal();

    // Private constructor
    LocalAuthService._internal();

    // Factory constructor to return the same instance
    factory LocalAuthService() {
        return _instance;
    }

    late final LocalAuthentication auth;

    void init(){
      auth = LocalAuthentication();
    }

    Future<bool> canLocalAuthenticate() async{
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      return canAuthenticate;
    }

    Future<bool> authenticateLocally() async {
      print(await auth.getAvailableBiometrics());
      final bool canAuthenticateLocally = await canLocalAuthenticate();
      if (canAuthenticateLocally) {
        try {
          final bool didAuthenticate = await auth.authenticate(
              localizedReason: 'Please authenticate to access the app');
          return didAuthenticate;
        } on PlatformException catch(e){
          print('local authenticate error:$e');
          // Handle the exception
          return false;
        }
      } else {
        return false;
        // Handle the case where local authentication is not possible
      }
    }
          // ...
}
    
    // final List<BiometricType> availableBiometrics =
    // await auth.getAvailableBiometrics();
    // print("auth $canAuthenticate,$canAuthenticateWithBiometrics,$availableBiometrics");
