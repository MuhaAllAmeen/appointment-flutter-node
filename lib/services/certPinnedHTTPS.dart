
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:appointment/services/secureStorageService.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

Future<SecurityContext> get globalContext async {
  // final sslCertfromlib = await rootBundle.load('lib/certi.pem');
  final base64Cert = await SecureStorage().getCert();
  Int8List sslCert = Int8List.fromList(base64Decode(base64Cert!));
  SecurityContext securityContext = SecurityContext(withTrustedRoots: false);
  securityContext.setTrustedCertificatesBytes(sslCert);
  return securityContext;
}


Future<http.Client> getSSLPinningClient() async {
  HttpClient client = HttpClient(context: await globalContext);
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => false;
  IOClient ioClient = IOClient(client);
  return ioClient;
}

class BaseHttpClient{
  //this creates an https client that is verified by ssl through the certificate of the server domain
  BaseHttpClient._internal();
  static final BaseHttpClient _instance = BaseHttpClient._internal();

  static BaseHttpClient get instance => _instance;

  late final http.Client client;

  factory BaseHttpClient() {
    return _instance;
  }
  Future<void> init() async {
    client = await getSSLPinningClient();
  }
}