import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

Future<SecurityContext> get globalContext async {
  final sslCert = await rootBundle.load('lib/certi.pem');
  SecurityContext securityContext = SecurityContext(withTrustedRoots: false);
  securityContext.setTrustedCertificatesBytes(sslCert.buffer.asInt8List());
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