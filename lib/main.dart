import 'package:flutter/material.dart';
import 'files/home.dart';
import 'package:flutter/services.dart';

void main() {     
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spesials Fest',
        home: Home(),
      ));
    });
}
