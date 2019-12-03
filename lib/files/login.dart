import 'dart:async';
import 'package:flutter/material.dart';
import 'package:specials_fest/files/statmonitor.dart';
import 'restuarants.dart';
import 'signup.dart';
import 'forgotpassword_enter_email.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String sEmail;

  final _contEmail = TextEditingController();
  final _contPass = TextEditingController();
  bool _validateEmail = false;
  bool _validatePass = false;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  String sEmailErr = '';
  String sPassErr = '';

  bool bLoginPressed = false;
  bool bError = false;
  String sError;

  @override
  void dispose() {
    _contEmail.dispose();
    _contPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Center(
      child: Container(
          padding: EdgeInsets.only(left: 25.0, right: 25.0),
          child: ListView(
            children: <Widget>[
              Image.asset(
                'Fotos/logo.png',
                height: 230,
              ),
              TextField(
                textInputAction: TextInputAction.next,
                focusNode: _emailFocus,
                onSubmitted: (term) {
                  _emailFocus.unfocus();
                  FocusScope.of(context).requestFocus(_passFocus);
                },
                decoration: InputDecoration(
                    hintText: 'Email',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    errorText: _validateEmail ? sEmailErr : null),
                controller: _contEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15.0),
              TextField(
                textInputAction: TextInputAction.done,
                focusNode: _passFocus,
                onSubmitted: (term) {
                  _passFocus.unfocus();
                  setState(() {
                    bLoginPressed = true;
                  });
                  pressLogin();
                },
                decoration: InputDecoration(
                    hintText: 'Password',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    errorText: _validatePass ? sPassErr : null),
                controller: _contPass,
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              bLoginPressed ? SizedBox(height: 20.0) : Center(),
              bError ? SizedBox(height: 20.0) : Center(),
              bLoginPressed
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(),
              bError
                  ? Center(
                      child: Text(sError, style: TextStyle(color: Colors.red)),
                    )
                  : Center(),
              SizedBox(height: 20.0),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.all(12),
                color: Colors.lightBlueAccent,
                child: Text('Login',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                textColor: Colors.white,
                elevation: 7.0,
                onPressed: () {
                  pressLogin();
                },
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: () => Navigator.push(context,
                    new MaterialPageRoute(builder: (context) => new SignUp())),
                padding: EdgeInsets.all(12),
                color: Colors.redAccent,
                child: Text('Sign up',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                textColor: Colors.white,
                elevation: 7.0,
              ),
              FlatButton(
                child: Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () {
                  Navigator.push(context,
                    new MaterialPageRoute(builder: (context) => new ForgotPasswordEnterEmail()));
                },
              ),
            ],
          )),
    ));
  }

  Future postLogin() async {
    final response =
        await http.post("http://specials-fest.com/PHP/login.php", body: {
      "useremail": _contEmail.text,
      "userpassword": _contPass.text,
    }).catchError((e) {
      setState(() {
        sError = "Connection Failed";
        bError = true;
        bLoginPressed = false;
      });
    }).timeout(new Duration(seconds: 3), onTimeout: () {
      setState(() {
        sError = "Connection Timeout";
        bError = true;
        bLoginPressed = false;
      });
    });

    var datauser = json.decode(response.body);
    print(datauser);

    if (datauser.length == 0) {
      setState(() {
        sError = 'Email and/or Password is incorrect';
        bError = true;
        bLoginPressed = false;
      });
    } else {
      bLoginPressed = false;
      bError = false;
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new StatMonitor(
                    sEmail: _contEmail.text,
                    sBusinessName: datauser[0]['businessname'],
                    sPhoneNumber: datauser[0]['phonenumber'],
                    sUserID: datauser[0]['userid'],
                    sSpecialCount: datauser[0]['specialcount'],
                    iValidUntil: datauser[0]['valid_until'],
                    iLimit: datauser[0]['specialcountlimit']
                  )));
      _contPass.clear();
    }
  }

  void pressLogin() {
    _validateEmail = false;
    _validatePass = false;
    if (_contEmail.text.isEmpty) {
      setState(() {
        sEmailErr = 'Must at least have 1 character';
        _validateEmail = true;
      });
    }
    if (_contPass.text.isEmpty) {
      setState(() {
        sPassErr = 'Must at least have 1 character';
        _validatePass = true;
      });
    }
    if (_contEmail.text.isNotEmpty && _contPass.text.isNotEmpty) {
      setState(() {
        bError = false;
        bLoginPressed = true;
      });
      postLogin();
    }
  }
}
