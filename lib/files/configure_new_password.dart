import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import "package:rflutter_alert/rflutter_alert.dart";
import 'package:http/http.dart' as http;

class ConfigurePassword extends StatefulWidget {
  final String sEmailConfirm;

  const ConfigurePassword({Key key, this.sEmailConfirm}) : super(key: key);

  @override
  _ConfigurePassword createState() => _ConfigurePassword();
}

class _ConfigurePassword extends State<ConfigurePassword> {
  final _contEnterPassword = TextEditingController();
  bool _validateEnterPassword = false;
  final FocusNode _enterpassFocus = FocusNode();

  final _contConfigurePassword = TextEditingController();
  bool _validateConfigurePassword = false;
  final FocusNode _configurepassFocus = FocusNode();

  String sEnterPasswordErr = '';
  String sConfigurePasswordErr = '';

  bool bConfigurePasswordPressed = false;
  bool bError = false;
  String sError;

  @override
  void dispose() {
    _contEnterPassword.dispose();
    _contConfigurePassword.dispose();
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
              Image.asset(
                'Fotos/logo.png',
                height: 230,
              ),
              Text(
                'New Password',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 10.0),
              TextField(
                textInputAction: TextInputAction.next,
                focusNode: _enterpassFocus,
                onSubmitted: (term) {
                  _enterpassFocus.unfocus();
                  FocusScope.of(context).requestFocus(_configurepassFocus);
                },
                decoration: InputDecoration(
                    hintText: 'Enter Password',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    errorText:
                        _validateEnterPassword ? sEnterPasswordErr : null),
                controller: _contEnterPassword,
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              SizedBox(height: 10.0),
              TextField(
                textInputAction: TextInputAction.next,
                focusNode: _configurepassFocus,
                onSubmitted: (term) {
                  _configurepassFocus.unfocus();
                  pressConfigure();
                },
                decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    errorText: _validateConfigurePassword
                        ? sConfigurePasswordErr
                        : null),
                controller: _contConfigurePassword,
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              bConfigurePasswordPressed || bError
                  ? Center()
                  : SizedBox(height: 15.0),
              bConfigurePasswordPressed ? SizedBox(height: 10.0) : Center(),
              bError ? SizedBox(height: 10.0) : Center(),
              bConfigurePasswordPressed
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(),
              bError
                  ? Center(
                      child: Text(sError, style: TextStyle(color: Colors.red)),
                    )
                  : Center(),
              bConfigurePasswordPressed ? SizedBox(height: 10.0) : Center(),
              bError ? SizedBox(height: 10.0) : Center(),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.all(12),
                color: Colors.lightBlueAccent,
                child: Text('Change password',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                textColor: Colors.white,
                elevation: 7.0,
                onPressed: () {
                  pressConfigure();
                },
              ),
            ],
          )),
    ));
  }

  void pressConfigure() {
    print(widget.sEmailConfirm);
    _validateEnterPassword = false;
    _validateConfigurePassword = false;
    if (_contEnterPassword.text.isEmpty) {
      setState(() {
        sEnterPasswordErr = 'Must at least have 1 character';
        _validateEnterPassword = true;
      });
    }
    if (_contConfigurePassword.text.isEmpty) {
      setState(() {
        sConfigurePasswordErr = 'Must at least have 1 character';
        _validateConfigurePassword = true;
      });
    }
    if (_contEnterPassword.text.isNotEmpty &&
        _contConfigurePassword.text.isNotEmpty) {
      if (_contConfigurePassword.text == _contEnterPassword.text) {
        if (_contConfigurePassword.text.length < 6) {
          setState(() {
            sError = 'Password must be at least 6 characters';
            bError = true;
            bConfigurePasswordPressed = false;
          });
        } else {
          setState(() {
            bError = false;
            bConfigurePasswordPressed = true;
          });
          postConfigurePassword();
        }
      } else {
        setState(() {
          sError = 'Does not match one another';
          bError = true;
          bConfigurePasswordPressed = false;
        });
      }
    }
  }

  Future postConfigurePassword() async {
    print(widget.sEmailConfirm);
    print(_contConfigurePassword.text);
    final response = await http
        .post("http://specials-fest.com/PHP/configureNewPassword.php", body: {
      "useremail": widget.sEmailConfirm,
      "newpass": _contConfigurePassword.text,
    }).catchError((e) {
      setState(() {
        sError = "Connection Failed";
        bError = true;
        bConfigurePasswordPressed = false;
      });
    }).timeout(new Duration(seconds: 3), onTimeout: () {
      setState(() {
        sError = "Connection Timeout";
        bError = true;
        bConfigurePasswordPressed = false;
      });
    });

    if (response.body != null) {
      bConfigurePasswordPressed = false;
      bError = false;
      await Alert(
        context: context,
        type: AlertType.success,
        title: 'Success',
        desc: 'Password has been changed successfully',
        buttons: [
          DialogButton(
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            width: 120,
          )
        ],
      ).show().then((val) {
        Navigator.pop(context);
      });
    } else {
      setState(() {
        sError = 'Email does not exist in system';
        bError = true;
        bConfigurePasswordPressed = false;
      });
      /*Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) => new EnterSecretCode(
                    sSecret: sSec,
                  )));*/
      //_contEmail.clear();
    }
  }
}
