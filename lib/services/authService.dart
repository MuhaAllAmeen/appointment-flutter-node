
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AuthService {
  static final AuthService instance = AuthService._();
  factory AuthService() => instance;
  AuthService._();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> initAuth() async {
    final storedRefreshToken =
        await _secureStorage.read(key: "refresh_token");
    final TokenResponse? result;
    print("refresh $storedRefreshToken");
    if (storedRefreshToken == null) {
      return false;
    }

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
        print("result $result");

      final bool setResult = await _handleAuthResult(result);
      return setResult;
    } catch (e, s) {
      print('error on Refresh Token: $e - stack: $s');
      // logOut() possibly
      return false;
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
      return await _handleAuthResult(result);
    } on PlatformException {
      print("User has cancelled or no internet!");
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> logout() async {
    await _secureStorage.delete(key: "refresh_token");
    return true;
  }

  Future<bool> _handleAuthResult(result) async {
    final bool isValidResult =
        result != null && result.accessToken != null && result.idToken != null;
    print("result ${isValidResult}");
    if (isValidResult) {
      // Storing refresh token to renew login on app restart
      if (result.refreshToken != null) {
        await _secureStorage.write(
          key: "refresh_token",
          value: result.refreshToken,
        );
      }

      final String googleAccessToken = result.accessToken;
      print("access $googleAccessToken");
      if (googleAccessToken != null) {
        await _secureStorage.write(
          key: "access_token",
          value: result.refreshToken,
        );
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
    return await _handleAuthResult(result);
    
  }
}