import 'dart:convert';
import 'dart:typed_data';
import 'package:appointment/services/secureStorageService.dart';
import 'package:pointycastle/export.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' as jwt;

Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> generateKeyPair() async {
final secureRandom = FortunaRandom();

// Seed the random generator (you can add more entropy to make it stronger)
final seed = Uint8List.fromList(List.generate(32, (i) => i + 1));
secureRandom.seed(KeyParameter(seed));

final keyGen = RSAKeyGenerator()
  ..init(ParametersWithRandom(
    RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
    secureRandom));

  final pair = keyGen.generateKeyPair();
  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey, pair.privateKey as RSAPrivateKey);
}

Future<void> sendPrivateKeyToServer(RSAPrivateKey privateKey) async {
  // Convert the private key to PEM format (or serialized as JSON)
  final privateKeyPem = encodePrivateKeyToPem(privateKey);
  await SecureStorage().writeJWTPrivateKey(privateKeyPem);
  // Send the private key to the server
  final response = await http.post(
    Uri.parse('https://appointment.crabdance.com/save-key'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'privateKey': privateKeyPem}),
  );

  if (response.statusCode == 200) {
    print('Private key successfully sent and saved on server');
  } else {
    print('Failed to send private key: ${response.body}');
  }
}

String encodePrivateKeyToPem(RSAPrivateKey privateKey) {
  // Convert the private key to PEM format
  final keyBytes = privateKey.privateExponent!.toRadixString(16).codeUnits;
  final pem = base64.encode(keyBytes);
  return '-----BEGIN PRIVATE KEY-----\n$pem\n-----END PRIVATE KEY-----';
}


String createjwt(RSAPrivateKey key){
  // Generate a JSON Web Token
// You can provide the payload as a key-value map or a string
final jwtoken = jwt.JWT(
  // Payload
  {
    'id': 123,
    'server': {
      'id': '3e4fc296',
      'loc': 'euw-2',
    }
  },
  
  issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
);

// Sign it (default with HS256 algorithm)
final token = jwtoken.sign(jwt.SecretKey(encodePrivateKeyToPem(key)),expiresIn: const Duration(days: 2));

return token;
}

Future<bool> checkJWT(String privateKey) async {
  try {
  // Verify a token (SecretKey for HMAC & PublicKey for all the others)
  final token = await SecureStorage().getJWT();
  final jwtoken = jwt.JWT.verify(token!, jwt.SecretKey(privateKey));
  return true;

} on jwt.JWTExpiredException {
  return false;
} on jwt.JWTException catch (ex) {
  print(ex.message); // ex: invalid signature
  return false;
} 
}
