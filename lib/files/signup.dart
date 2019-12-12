import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:rflutter_alert/rflutter_alert.dart";


class SignUp extends StatefulWidget {
  SignUp({Key key1}) : super(key: key1);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _contEmail = TextEditingController();
  bool _validateEmail = false;
  final _contPass = TextEditingController();
  bool _validatePass = false;
  final _contMobile = TextEditingController();
  bool _validateMobile = false;
  final _contRest = TextEditingController();
  bool _validateRest = false;
  final _contOwner = TextEditingController();
  bool _validateOwner = false;
  final _contRef = TextEditingController();
  bool _bpassconfirm = false;
  final _contpassConfirm = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _ownerFocus = FocusNode();
  final FocusNode _numFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _passFocus2 = FocusNode();
  final FocusNode _refFocus = FocusNode();

  bool bSignUpPressed = false;
  bool bError = false;
  String sError,sEmailErr;

  @override
  void dispose() {
    _contEmail.dispose();
    _contPass.dispose();
    _contMobile.dispose();
    _contRest.dispose();
    _contOwner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              child: FormUI(),
            ),),),),);}
// Here is our Form UI
  Widget FormUI() {
    return new Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        new TextField(
          decoration: InputDecoration(
              labelText: 'Restaurant Name',
              errorText: _validateRest
                  ? 'Restaurant must be more than 1 charater'
                  : null),
          keyboardType: TextInputType.text,
          maxLength: 100,
          controller: _contRest,
          focusNode: _nameFocus,
          onSubmitted: (term) {
            _nameFocus.unfocus();
            FocusScope.of(context).requestFocus(_ownerFocus);
          },
        ),
        new TextField(
          decoration: InputDecoration(
              labelText: 'Owner name and surname',
              errorText:
                  _validateOwner ? 'Name must be more than 1 charater' : null),
          keyboardType: TextInputType.text,
          maxLength: 50,
          controller: _contOwner,
          focusNode: _ownerFocus,
          onSubmitted: (term) {
            _ownerFocus.unfocus();
            FocusScope.of(context).requestFocus(_numFocus);
          },
        ),
        new TextField(
          decoration: InputDecoration(
              labelText: "Restaurant's phone number for bookings",
              errorText: _validateMobile ? 'Number must be 10 digits' : null),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          controller: _contMobile,
          focusNode: _numFocus,
          onSubmitted: (term) {
            _numFocus.unfocus();
            FocusScope.of(context).requestFocus(_emailFocus);
          },
        ),
        new TextField(
          decoration: InputDecoration(
              labelText: 'Email',
              errorText: _validateEmail
                  ? 'Email is not valid'
                  : null),
          keyboardType: TextInputType.emailAddress,
          controller: _contEmail,
          maxLength: 100,
          focusNode: _emailFocus,
          onSubmitted: (term) {
            _emailFocus.unfocus();
            FocusScope.of(context).requestFocus(_passFocus);
          },
        ),
        new TextField(
          decoration: InputDecoration(
              labelText: 'Password',
              errorText: _validatePass
                  ? 'Password must be at least 6 characters'
                  : null),
          keyboardType: TextInputType.text,
          controller: _contPass,
          maxLength: 50,
          obscureText: true,
          focusNode: _passFocus,
          onSubmitted: (term) {
            _passFocus.unfocus();
            FocusScope.of(context).requestFocus(_passFocus2);
          },
        ),
        new TextField(
          decoration: InputDecoration(
              labelText: 'Confirm Password',
              errorText: _bpassconfirm
                  ? 'Password does not match'
                  : null),
          keyboardType: TextInputType.text,
          controller: _contpassConfirm,
          maxLength: 50,
          obscureText: true,
          focusNode: _passFocus2,
          onSubmitted: (term) {
            _passFocus2.unfocus();
            FocusScope.of(context).requestFocus(_refFocus);
          },
        ),
        new TextField(
          decoration: InputDecoration(labelText: 'Reference code (if applicable)'),
          keyboardType: TextInputType.text,
          maxLength: 20,
          focusNode: _refFocus,
        ),
        new SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () {
              setState(() {
                _validateEmail = validateEmail(_contEmail.text);
                _validatePass = validatePass(_contPass.text);
                _validateMobile = validateMobile(_contMobile.text);
                _validateRest = validateRest(_contRest.text);
                _validateOwner = validateOwner(_contOwner.text);
                _bpassconfirm = validatePass2(_contpassConfirm.text);
                print(_contRest.text);
                if(_validateEmail==false && _validateMobile==false && _validateOwner==false && _validatePass==false && _validateRest==false && _bpassconfirm==false) {
                  print('Posting');
                  post();
                  _sendMail();
                }

              });
              
            },
            padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
            color: Colors.redAccent,
            child: Text('Sign up',
                style: TextStyle(color: Colors.white, fontSize: 25)),
          ),
        ),
      ],
    );
  }

  bool validateRest(String value) {
    if (value.length < 2)
      return true;
    else
      return false;
  }

  bool validateOwner(String value) {
    if (value.length < 2)
      return true;
    else
      return false;
  }

  bool validateMobile(String value) {
    if (value.length != 10)
      return true;
    else
      return false;
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (regex.hasMatch(value))
      return false;
    else
      return true;
  }

  bool validatePass(String value) {
    if (value.length < 6)
      return true;
    else
      return false;
  }

  bool validatePass2(String value) {
    if (_contpassConfirm.text != _contPass.text)
      return true;
    else
      return false;
  }

  void post() async {
    var result = await http.post(
        "http://specials-fest.com/PHP/insertUser.php",
        body: {
          "value": "I am cool!",
          "useremail": _contEmail.text,
          "userpassword": _contPass.text,
          "businessname": _contRest.text,
          "phonenumber": _contMobile.text,
          "reference": _contRef.text,
        }
    );
    print(result.body);
    if (result.body == "Failed") {
      _contEmail.clear();
      Alert(
        context: context,
        type: AlertType.error,
        title: "ERROR",
        desc: "This email is already registered!",
        buttons: [
          DialogButton(
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    }
    else if (result.body == "Success"){
      Alert(
        context: context,
        type: AlertType.success,
        title: "Registered!",
        desc: "You have succesfully registered, we will call you within a few business days to be verified!",
        buttons: [
          DialogButton(
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: (){Navigator.pop(context);
            Navigator.pop(context);},
            width: 120,
          )
        ],
      ).show();
    }
  }

  void _sendMail() async {
    await http.post("http://specials-fest.com/PHP/emailNewUser.php", body: {
      "owner": _contOwner.text,
      "rest": _contRest.text,
      "number": _contMobile.text,
      "email": _contEmail.text,
      "ref": _contRef.text,
    }).then((e){print(e);}).catchError((e){print(e);});
  }
}
