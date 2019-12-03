import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' as prefix0;
import 'files/clocation.dart';
import 'files/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// List<String> TypesFood = List();

void main() {      
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spesials Fest',
      home: Home(),
    ));
  });
}
