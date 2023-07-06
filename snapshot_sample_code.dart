import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void main() async {
  snapshotIfNeeded();
}

bool isNeed = true;

StreamController<Either<Error, Uint8List>> dataController =
    StreamController<Either<Error, Uint8List>>();
const screenshotApiDuration = Duration(seconds: 1);
const ip = 'IP FOUND';
dynamic cert = 'CERT HAS BEEN AUTHED';

Future<void> snapshotIfNeeded() async {
  if (isNeed) {
    snapshot();
  }
}

Future<void> snapshot() async {
  final url = Uri(
    scheme: 'https',
    host: ip,
    port: 8443,
    path: 'system/controls/screen_shot2',
  );

  var dio = Dio(BaseOptions());
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
    client.badCertificateCallback =
        (X509Certificate x509, String host, int port) =>
            x509.pem == utf8.decode(cert);
    return client;
  };

  try {
    final response = await dio.get(url.toString(),
        options: Options(
          responseType: ResponseType.bytes,
          sendTimeout: 1000,
          receiveTimeout: 1000,
        ));
    final value = Uint8List.fromList(response.data);
    dataController.add(Right(value));
    Future.delayed(screenshotApiDuration).then((_) async {
      snapshotIfNeeded();
    });
  } catch (e) {
    snapshotErrorHandler(e);
  }
}

void snapshotErrorHandler(error) {
  dataController.add(Left(error));
}
