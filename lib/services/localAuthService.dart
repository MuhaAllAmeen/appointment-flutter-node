import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService{
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
      //check is device can use biometrics
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      final List<BiometricType> biometrics = await auth.getAvailableBiometrics();
      return canAuthenticate && biometrics.isNotEmpty;
    }

    Future<bool> authenticateLocally() async {
      final bool canAuthenticateLocally = await canLocalAuthenticate();
      print("${await auth.getAvailableBiometrics() },$canAuthenticateLocally");
      if (canAuthenticateLocally) {
        //if it can then authenticate 
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
        // Handle the case where local authentication is not possible and force user to login using google
      }
    }
          // ...
}
    
