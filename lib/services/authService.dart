
import 'dart:convert';

import 'package:appointment/services/firestoreService.dart';
import 'package:appointment/services/localAuthService.dart';
import 'package:appointment/services/secureStorageService.dart';
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

    if (storedRefreshToken == null) {
      //if no refresh token then user has to log in
      return false;
    }

    final storedExpiryTime = await SecureStorage().getExpiryTime() ?? 0;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (currentTimestamp>storedExpiryTime){
      //google oauth idtoken has an expiry time which needs to be checked so that new id token can be retrieved.
      //best to check this before every request to server
      await logout();
      return false;
      //this would give us fresh set of tokens even the refresh token. Google tokens are only supposed to last a day
    }

    final storedAccessToken = await SecureStorage().getAccessToken();
    final storedIdToken = await SecureStorage().getIdToken();
    //if there is no access token or id token then retrieve them from google oauth
    //or else biometrics can be used for a simple login
    if (storedAccessToken==null || storedIdToken==null)
    {
      try {
      // Obtaining token response from refresh token
      final client_id = await SecureStorage().getAndroidGoogleClientId() ?? "";
      final redirect_uri = await SecureStorage().getGooglRedirectUri() ?? "";
      final issuer = await SecureStorage().getGoogleIssuer() ?? "";
      result = await _appAuth.token(
          TokenRequest(
            client_id,
            redirect_uri,
            issuer: issuer,
            refreshToken: storedRefreshToken,
          ),
        );

        final bool setResult = await _handleAuthResult(result);
        return setResult;
      } catch (e, s) {
        print('error on Refresh Token: $e - stack: $s');
        // logOut() possibly
        return false;
      }

    }else{
      //biometric auth
      final authenticatedLocally = await LocalAuthService().authenticateLocally();
      return authenticatedLocally;
    }
  }

  Future<bool> login() async {
    final AuthorizationTokenRequest authorizationTokenRequest;

    try {
      final client_id = await SecureStorage().getAndroidGoogleClientId() ?? "";
      final redirect_uri = await SecureStorage().getGooglRedirectUri() ?? "";
      final issuer = await SecureStorage().getGoogleIssuer() ?? "";

      authorizationTokenRequest = AuthorizationTokenRequest(
          client_id,
          redirect_uri,
          issuer: issuer,
          scopes: ['email', 'profile'],
        );
      // Requesting the auth token and waiting for the response
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        authorizationTokenRequest,
      );
      // Taking the obtained result and processing it
      final handled = await _handleAuthResult(result);
      if (handled){
        final idToken = await SecureStorage().getIdToken();
        if(idToken!=null){
          //send idtoken to backend and save the user from backend
          final userSavedResponse = await addUserUsingIdToken(idToken);
          final userDetails = jsonDecode(userSavedResponse.body);
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
    //write the tokens to safe storage
    final bool isValidResult =
        result != null && result.accessToken != null && result.idToken != null;

    if (isValidResult) {
      // Storing refresh token to renew login on app restart
      if (result.refreshToken != null) {
        await SecureStorage().writeRefreshToken(result.refreshToken);
      }

      if (result.idToken!=null){
        await SecureStorage().writeIdToken(result.idToken);
      }

      final String googleAccessToken = result.accessToken;
      if (googleAccessToken != null) {
        await SecureStorage().writeAccessToken(googleAccessToken);
      }
      
      return true;
    } else {
      return false;
    }
  }

  Future<bool> loginUsingGooglePackage() async {
    // this is only an experiment: another way to sign in usign gogole
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