import 'package:appointment/utils/createPrivateKey.dart';
import 'package:appointment/services/secureStorageService.dart';
import 'package:pointycastle/pointycastle.dart';
Future<void> initKeys() async {
  if (await SecureStorage().getJWT() == null){
    final AsymmetricKeyPair<RSAPublicKey,RSAPrivateKey> keyPair = await generateKeyPair();
    await sendPrivateKeyToServer(keyPair.privateKey);
    final jwt = createjwt(keyPair.privateKey);
    print("jwt $jwt");
    await SecureStorage().writeJWT(jwt);
  }else{
    return;
  }
  
}