import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
import 'enter_secret_code.dart';

class ForgotPasswordEnterEmail extends StatefulWidget {
  @override
  _ForgotPasswordEnterEmail createState() => _ForgotPasswordEnterEmail();
}

class _ForgotPasswordEnterEmail extends State<ForgotPasswordEnterEmail> {
  final _contEmail = TextEditingController();
  bool _validateEmail = false;
  final FocusNode _emailFocus = FocusNode();

  String sEmailErr = '';

  bool bEmailPressed = false;
  bool bError = false;
  String sError;

  String sSec;

  @override
  void dispose() {
    _contEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        body: Center(
      child: Container(
          padding: EdgeInsets.only(left: 25.0, right: 25.0),
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        )),
                    width: 55,
                  ),
                  Image.asset(
                    'Fotos/logo.png',
                    height: 230,
                  )
                ],
              ),
              Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10.0),
              TextField(
                textInputAction: TextInputAction.next,
                focusNode: _emailFocus,
                onSubmitted: (term) {
                  _emailFocus.unfocus();
                  setState(() {
                    _validateEmail = validateEmail(_contEmail.text);
                  });
                },
                decoration: InputDecoration(
                    hintText: 'Enter Email Address',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    errorText: _validateEmail ? sEmailErr : null),
                controller: _contEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              bEmailPressed || bError ? Center() : SizedBox(height: 15.0),
              bEmailPressed ? SizedBox(height: 10.0) : Center(),
              bError ? SizedBox(height: 10.0) : Center(),
              bEmailPressed
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(),
              bError
                  ? Center(
                      child: Text(sError, style: TextStyle(color: Colors.red)),
                    )
                  : Center(),
              bEmailPressed ? SizedBox(height: 10.0) : Center(),
              bError ? SizedBox(height: 10.0) : Center(),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.all(12),
                color: Colors.lightBlueAccent,
                child: Text('Reset Password',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                textColor: Colors.white,
                elevation: 7.0,
                onPressed: () {
                  //pressEmail();
                  setState(() {
                    _validateEmail = validateEmail(_contEmail.text);
                  });
                },
              ),
            ],
          )),
    ));
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (regex.hasMatch(value)) {
      if (_contEmail.text.isEmpty) {
        sEmailErr = 'Must at least have 1 character';
        return true;
      } else {
        setState(() {
          bError = false;
          bEmailPressed = true;
        });
        sSec = randomAlphaNumeric(5);
        postForgotPassword(sSec);
        return false;
      }
    } else {
      sEmailErr = 'Invalid Email Address';
      return true;
    }
  }

  Future postForgotPassword(String sSecret) async {
    final response = await http
        .post("https://specials-fest.com/PHP/forgotPassword.php", body: {
      "useremail": _contEmail.text,
      "secret": sSecret,
    }).catchError((e) {
      setState(() {
        sError = "Connection Failed";
        bError = true;
        bEmailPressed = false;
      });
    }).timeout(new Duration(seconds: 3), onTimeout: () {
      setState(() {
        sError = "Connection Timeout";
        bError = true;
        bEmailPressed = false;
      });
    });
    print(response.body);

    var datauser = json.decode(response.body);

    if (datauser.length == 0) {
      setState(() {
        sError = 'Email does not exist in system';
        bError = true;
        bEmailPressed = false;
      });
    } else {
      bEmailPressed = false;
      bError = false;
      Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) =>
                  new EnterSecretCode(sSecret: sSec, 
                  sEmail: _contEmail.text)));
    }
  }
}
