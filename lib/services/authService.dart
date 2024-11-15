
import 'dart:convert';

import 'package:appointment/services/firestoreService.dart';
import 'package:appointment/services/localAuthService.dart';
import 'package:appointment/services/tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AuthService {
  static final AuthService instance = AuthService._();
  factory AuthService() => instance;
  AuthService._();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Future<bool> initAuth() async {
    final storedRefreshToken = await SecureStorage().getRefreshToken();
    final TokenResponse? result;
    print("refresh $storedRefreshToken");
    if (storedRefreshToken == null) {
      return false;
    }

    final storedExpiryTime = await SecureStorage().getExpiryTime() ?? 0;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (currentTimestamp>storedExpiryTime){
      await logout();
      return false;
      //this would give us fresh set of tokens even the refresh token. Google tokens are only supposed to last a day
    }

    final storedAccessToken = await SecureStorage().getAccessToken();
    final storedIdToken = await SecureStorage().getIdToken();
    
    if (storedAccessToken==null || storedIdToken==null)
    {
      try {
      // Obtaining token response from refresh token
      result = await _appAuth.token(
          TokenRequest(
            dotenv.get("CLIENT_ID"),
            dotenv.get("GOOGLE_REDIRECT_URI"),
            issuer: dotenv.get("GOOGLE_ISSUER"),
            refreshToken: storedRefreshToken,
          ),
        );
        print("result ${result.toString()}");

        final bool setResult = await _handleAuthResult(result);
        return setResult;
      } catch (e, s) {
        print('error on Refresh Token: $e - stack: $s');
        // logOut() possibly
        return false;
      }

    }else{
      final authenticatedLocally = await LocalAuthService().authenticateLocally();
      return authenticatedLocally;
    }
  }

  Future<bool> login() async {
    final AuthorizationTokenRequest authorizationTokenRequest;
    print("uei ${dotenv.get("GOOGLE_REDIRECT_URI")}");

    try {
      authorizationTokenRequest = AuthorizationTokenRequest(
          dotenv.get("CLIENT_ID"),
          dotenv.get("GOOGLE_REDIRECT_URI"),
          issuer: dotenv.get("GOOGLE_ISSUER"),
          scopes: ['email', 'profile'],
        );
      // Requesting the auth token and waiting for the response
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        authorizationTokenRequest,
      );
      print(result?.accessToken);
      // Taking the obtained result and processing it
      final handled = await _handleAuthResult(result);
      if (handled){
        final idToken = await SecureStorage().getIdToken();
        if(idToken!=null){
          final userSavedResponse = await addUserUsingIdToken(idToken);
          final userDetails = jsonDecode(userSavedResponse.body);
          print(userDetails);
          SecureStorage().writeExpiryTime(userDetails["expiryTime"]);
        } 
      }
      return handled;
    } on PlatformException {
      print("User has cancelled or no internet!");
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> logout() async {
    await SecureStorage().clearTokens();
    return true;
  }

  Future<bool> _handleAuthResult(result) async {
    final bool isValidResult =
        result != null && result.accessToken != null && result.idToken != null;
    print("result ${result.idToken}");
    String tt = result.idToken;
    while (tt.length > 0) {
      
    int initLength = (tt.length >= 500 ? 500 : tt.length);
    print(tt.substring(0, initLength));
    int endLength = tt.length;
    tt = tt.substring(initLength, endLength);
}
    if (isValidResult) {
      // Storing refresh token to renew login on app restart
      if (result.refreshToken != null) {
        await SecureStorage().writeRefreshToken(result.refreshToken);
      }

      if (result.idToken!=null){
        await SecureStorage().writeIdToken(result.idToken);
      }

      final String googleAccessToken = result.accessToken;
      print("access $googleAccessToken");
      if (googleAccessToken != null) {
        await SecureStorage().writeAccessToken(googleAccessToken);
      }

      // Send request to backend with access token
      // final url = Uri.https(
      //   'api.your-server.com',
      //   '/v1/social-authentication',
      //   {
      //     'access_token': googleAccessToken,
      //   },
      // );
      // final response = await http.get(url);
      // final backendToken = response.token

      // Let's assume it has been successful and a valid token has been returned
      // const String backendToken = 'TOKEN';
      // if (backendToken != null) {
      //   await _secureStorage.write(
      //     key: "backend_token",
      //     value: backendToken,
      //   );
      // }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> loginUsingGooglePackage() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    // UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
    final result = TokenResponse(googleAuth?.accessToken, null,null, googleAuth?.idToken,null,null,null);
    if (googleAuth!=null && googleAuth.accessToken!=null && googleAuth.idToken!=null){
      await SecureStorage().writeAccessToken(googleAuth.accessToken!);
      await SecureStorage().writeIdToken(googleAuth.idToken!);
      final userSavedResponse = await addUserUsingIdToken(googleAuth.idToken!);
      return true;
    }
    return await _handleAuthResult(result);
    
  }
}