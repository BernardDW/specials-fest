import 'package:flutter/material.dart';
import 'configure_new_password.dart';

class EnterSecretCode extends StatefulWidget {
  final String sSecret;
  final String sEmail;

  const EnterSecretCode({Key key, this.sSecret, this.sEmail}) : super(key: key);

  @override
  _EnterSecretCode createState() => _EnterSecretCode();
}

class _EnterSecretCode extends State<EnterSecretCode> {
  final _contSecret = TextEditingController();
  bool _validateSecret = false;
  final FocusNode _secretFocus = FocusNode();

  String sSecretErr = '';

  bool bSecretPressed = false;
  bool bError = false;
  String sError;

  @override
  void dispose() {
    _contSecret.dispose();
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
                'Enter the code that was sent to you',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 10.0),
              TextField(
                textInputAction: TextInputAction.next,
                focusNode: _secretFocus,
                onSubmitted: (term) {
                  _secretFocus.unfocus();
                  pressSecret();
                },
                decoration: InputDecoration(
                    hintText: 'Enter Code',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    errorText: _validateSecret ? sSecretErr : null),
                controller: _contSecret,
                keyboardType: TextInputType.emailAddress,
              ),
              bSecretPressed || bError ? Center() : SizedBox(height: 15.0),
              bSecretPressed ? SizedBox(height: 10.0) : Center(),
              bError ? SizedBox(height: 10.0) : Center(),
              bSecretPressed
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(),
              bError
                  ? Center(
                      child: Text(sError, style: TextStyle(color: Colors.red)),
                    )
                  : Center(),
              bSecretPressed ? SizedBox(height: 10.0) : Center(),
              bError ? SizedBox(height: 10.0) : Center(),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.all(12),
                color: Colors.lightBlueAccent,
                child: Text('Send Code',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                textColor: Colors.white,
                elevation: 7.0,
                onPressed: () {
                  pressSecret();
                },
              ),
            ],
          )),
    ));
  }

  void pressSecret() {
    _validateSecret = false;
    if (_contSecret.text.isEmpty) {
      setState(() {
        sSecretErr = 'Must at least have 1 character';
        _validateSecret = true;
      });
    }
    if (_contSecret.text.isNotEmpty) {
      if (widget.sSecret == _contSecret.text) {
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    new ConfigurePassword(sEmailConfirm: widget.sEmail)));
      } else {
        setState(() {
          sError = 'Code is wrong';
          bError = true;
          bSecretPressed = false;
        });
      }
    }
  }
}
