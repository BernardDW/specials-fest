import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:flip_card/flip_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:rflutter_alert/rflutter_alert.dart";

double screen_width;

//LOG IN PAGE
class Restaurants extends StatefulWidget {
  final String sEmail;
  final String sBusinessName;
  final String sPhoneNumber;
  final String sUserID;
  final String sSpecialCount;
  final String iValidUntil;
  final String iLimit;

  const Restaurants(
      {Key key,
      this.sEmail,
      this.sBusinessName,
      this.sPhoneNumber,
      this.sUserID,
      this.sSpecialCount,
      this.iValidUntil,
      this.iLimit})
      : super(key: key);

  @override
  _RestaurantsState createState() => _RestaurantsState();
}

class _RestaurantsState extends State<Restaurants> {
  @override
  void initState() {
    super.initState();
    refreshCount();
    _firstPress = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _contSpecialName.dispose();
    _contDescription.dispose();
  }

//  _formKey and _autoValidate
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _contSpecialName = TextEditingController();
  bool _validateSpecialName = false;
  final _contDescription = TextEditingController();
  bool _validateDescription = false;
  bool _autoValidate = false;
  bool _showError = false;
  String sShowError;
  String _special = 'Preview';
  String sDae = '';
  String sType = '';

  Color currentColor = Colors.white;
  Color current02Color = Colors.white;

  bool bMon = false;
  bool bTue = false;
  bool bWed = false;
  bool bThu = false;
  bool bFri = false;
  bool bSat = false;
  bool bSun = false;
  bool bFood = false;
  bool bDrinks = false;
  bool _firstPress = true;

  String iSpecialCount;

  void refreshCount() async {
    final response =
    await http.post("http://specials-fest.com/PHP/refreshCount.php", body: {
      "userID": widget.sUserID,
    }).catchError((e) {
      setState(() {});
    });

    var datauser = json.decode(response.body);
    print(datauser[0]['specialcount']);
    if (datauser.length != 0) {
      setState(() {
        iSpecialCount = datauser[0]['specialcount'];
        print(iSpecialCount);
      });
    }

  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(width: 1.0),
      borderRadius: BorderRadius.all(
          Radius.circular(30.0) //         <--- border radius here
          ),
    );
  }

  ValueChanged<Color> onColorChanged;

  changeSimpleColor(Color color) => setState(() => currentColor = color);

  changeMaterialColor(Color color) => setState(() {
        currentColor = color;
        Navigator.of(context).pop();
      });

  changeMaterial02Color(Color color) => setState(() {
        current02Color = color;
        Navigator.of(context).pop();
      });

  void _showDialogError(String stitle, String sConext) {
    // flutter defined function
    Alert(
      context: context,
      type: AlertType.error,
      title: stitle,
      desc: sConext,
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

  void _showDialogSpecial() {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Active Specials:",
      desc: "Your currently have " + iSpecialCount + " active specials!",
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

  Widget checkbox(String title, bool boolValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title),
        Checkbox(
          value: boolValue,
          onChanged: (bool value) {
            /// manage the state of each value
            setState(() {
              switch (title) {
                case "Monday":
                  bMon = value;
                  break;
                case "Tuesday":
                  bTue = value;
                  break;
                case "Wednesday":
                  bWed = value;
                  break;
                case "Thursday":
                  bThu = value;
                  break;
                case "Friday":
                  bFri = value;
                  break;
                case "Saturday":
                  bSat = value;
                  break;
                case "Sunday":
                  bSun = value;
                  break;
                case "Food":
                  bFood = value;
                  break;
                case "Drinks":
                  bDrinks = value;
                  break;
              }
            });
          },
        )
      ],
    );
  }

  //Toets Image
  File image;
  String URLq = 'Download URL';

  Future _getImage() async {
    var tempImage = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400.0, maxWidth: 600.0);

    setState(() {
      image = tempImage;
    });
  }

  void _upload() {
    if (image == null) return;
    String base64Image = base64Encode(image.readAsBytesSync());
    String naam = widget.sBusinessName.replaceAll(new RegExp(' '), '_');

    String fileName = naam + iSpecialCount + '.jpg';
    http.post("http://specials-fest.com/photos/upload.php", body: {
      "image": base64Image,
      "name": fileName,
    }).then((res) {
      print(res.statusCode);
    }).catchError((err) {
      print(err);
    });
  }

  void post(String filename2) async {
    var result =
        await http.post("http://specials-fest.com/PHP/addSpecial.php", body: {
      "userid": widget.sUserID,
      "specialname": _contSpecialName.text,
      "description": _contDescription.text,
      "start": _specialBeginDatumYYMMDD,
      "end": _specialEndDatumYYMMDD,
      "types": sType,
      "days": sDae,
      "name": filename2,
      "userlimit": widget.iLimit
    });
    print(result.body);
    if (result.body == "Failed") {
      _showDialogError("ERROR",
          "Failed to add. Please contact us at support@specials-fest.com");
    } else if (result.body == "Success") {
      Alert(
        context: context,
        type: AlertType.success,
        title: "Special added!",
        desc: "Your special has been added!",
        buttons: [
          DialogButton(
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              sType = "";
              sDae = "";
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            width: 120,
          )
        ],
      ).show();
    } else if (result.body == "Limit") {
      _showDialogError(
          "ERROR",
          "You already have " +
              widget.iLimit.toString() +
              " specials running. If this is wrong, please contact us at support@specials-fest.com!");
      Alert(
        context: context,
        type: AlertType.error,
        title: "Limit Reached",
        desc: "You already have " +
            widget.iLimit.toString() +
            " specials running. If this is wrong, please contact us at support@specials-fest.com!",
        buttons: [
          DialogButton(
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              sType = "";
              sDae = "";
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            width: 120,
          )
        ],
      ).show();
    }
  }

  String _description = 'Description ';
  String _specialBeginDatumYYMMDD = " ";
  String _specialEndDatumYYMMDD = " ";
  DateTime eerste, tweede;

  Future<void> _beginDatum(BuildContext context) async {
    /*DateTime date = new DateTime.fromMillisecondsSinceEpoch(
        int.parse(widget.iValidUntil) * 1000);*/
    DateTime picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        initialDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 10));
    if (picked != null) {
      setState(() {
        setState(() {
          eerste = picked;
          _showError = false;
        });
        _specialBeginDatumYYMMDD = picked.year.toString() +
            "-" +
            picked.month.toString() +
            "-" +
            picked.day.toString();
      });
    }
  }

  Future<void> _endDatum(BuildContext context) async {
    /*DateTime date = new DateTime.fromMillisecondsSinceEpoch(
        int.parse(widget.iValidUntil) * 1000);*/
    DateTime picked = await showDatePicker(
        context: context,
        firstDate: eerste,
        initialDate: eerste,
        lastDate: DateTime(DateTime.now().year + 10));
    if (picked != null) {
      setState(() {
        setState(() {
          tweede = picked;
          _showError = false;
        });
        _specialEndDatumYYMMDD = picked.year.toString() +
            "-" +
            picked.month.toString() +
            "-" +
            picked.day.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.sBusinessName);
    final media = MediaQuery.of(context);
    screen_width = media.size.width;
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: formUI(),
            ),
          ),
        ),
      ),
    );
  }

// Here is our Form UI
  Widget formUI() {
    return new Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(0.0, 0, 0, 20),
              child: FlatButton(
                  onPressed: () => Navigator.pop(context),
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
            errorText: _validateSpecialName
                ? 'Special Name must be more than 1 charater'
                : null,
            labelText: 'Special Name',
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
          ),
          controller: _contSpecialName,
          keyboardType: TextInputType.text,
          maxLength: 35,
          onChanged: (String val) {
            setState(() {
              _showError = false;
              _special = val;
            });
          },
        ),
        new SizedBox(
          height: 20.0,
        ),
        new TextField(
          decoration: InputDecoration(
            errorText: _validateDescription
                ? 'Description must be more than 1 charater'
                : null,
            labelText: 'Description',
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          controller: _contDescription,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          maxLength: 255,
          onChanged: (String val) {
            setState(() {
              _showError = false;
              _description = val;
            });
          },
        ),
        new SizedBox(
          height: 20.0,
        ),
        new Text(
          "Choose the day(s) a special must run on",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        new SizedBox(
          height: 10.0,
        ),
        new Container(
          decoration: myBoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      checkbox("Monday", bMon),
                      checkbox("Thursday", bThu),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      checkbox("Tuesday", bTue),
                      checkbox("Friday", bFri),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      checkbox("Wednesday", bWed),
                      checkbox("Saturday", bSat),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 134.0)),
                  checkbox("Sunday", bSun),
                ],
              ),
            ],
          ),
        ),
        new SizedBox(
          height: 30.0,
        ),
        new Text(
          "Special type:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        new SizedBox(
          height: 10.0,
        ),
        new Container(
          decoration: myBoxDecoration(),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    checkbox("Food", bFood),
                    checkbox("Drinks", bDrinks),
                  ]),
            ],
          ),
        ),
        new SizedBox(
          height: 10.0,
        ),
        Center(
          child: image == null ? disableUpload() : enableUpload(),
        ),
        FlatButton(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Upload picture for special',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
          onPressed: _getImage,
        ),
        IconButton(
          onPressed: () {
            _beginDatum(context);
          },
          icon: Icon(Icons.date_range),
          iconSize: 40.0,
          color: Colors.green,
        ),
        Text('Special STARTS: $_specialBeginDatumYYMMDD',
            style: TextStyle(color: Colors.black, fontSize: 23)),
        new SizedBox(
          height: 25.0,
        ),
        IconButton(
          onPressed: () {
            _endDatum(context);
          },
          icon: Icon(Icons.date_range),
          iconSize: 40.0,
          color: Colors.red,
        ),
        Text('Special ENDS: $_specialEndDatumYYMMDD',
            style: TextStyle(color: Colors.black, fontSize: 23)),
        _showError
            ? SizedBox(
                height: 10.0,
              )
            : Text(''),
        _showError
            ? Center(
                child: Text(
                  sShowError,
                  style: TextStyle(color: Colors.red),
                ),
              )
            : Text(''),
        _showError
            ? SizedBox(
                height: 10.0,
              )
            : Text(''),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () {
              setState(() {
                _validateSpecialName =
                    validateSpecialName(_contSpecialName.text);
                _validateDescription =
                    validateDescription(_contDescription.text);
                if (_validateDescription || _validateSpecialName) {
                  sShowError = 'Please enter a description and special name';
                  _showError = true;
                } else if (image == null) {
                  sShowError = 'Please choose a image from your gallery';
                  _showError = true;
                } else if (eerste == null) {
                  sShowError = 'Start Date not entered';
                  _showError = true;
                } else if (tweede == null) {
                  sShowError = 'End Date not entered';
                  _showError = true;
                } else if (bFood == false && bDrinks == false) {
                  sShowError = 'No Type selected';
                  _showError = true;
                } else if (bMon == false &&
                    bTue == false &&
                    bWed == false &&
                    bThu == false &&
                    bFri == false &&
                    bSat == false &&
                    bSun == false) {
                  sShowError = 'No days selected';
                  _showError = true;
                } else {
                  if (bMon) {
                    sDae += "Monday";
                  }
                  if (bTue) {
                    sDae += "Tuesday";
                  }
                  if (bWed) {
                    sDae += "Wednesday";
                  }
                  if (bThu) {
                    sDae += "Thursday";
                  }
                  if (bFri) {
                    sDae += "Friday";
                  }
                  if (bSat) {
                    sDae += "Saturday";
                  }
                  if (bSun) {
                    sDae += "Sunday";
                  }
                  if (bFood) {
                    sType += "Food";
                  }
                  if (bDrinks) {
                    sType += "Drinks";
                  }
                  String naam =
                      widget.sBusinessName.replaceAll(new RegExp(' '), '_');

                  String fileName2 = naam + iSpecialCount + '.jpg';
                  Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Confrim special detail",
                    desc:
                        "Do you agree that all information is correct?\nA special cannot be edited or removed!",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Agree",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          if(_firstPress) {
                            _firstPress = false;
                            _upload();
                            post(fileName2);
                          }
                        },
                        color: Color.fromRGBO(0, 179, 134, 1.0),
                      ),
                      DialogButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: Color.fromRGBO(255, 85, 38, 1.0),
                      )
                    ],
                  ).show();
                }
              });
            },
            padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
            color: Colors.blue,
            child: Text('Add Special',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontStyle: FontStyle.italic)),
          ),
        ),
        new Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () {
              print(iSpecialCount);
              _showDialogSpecial();
            },
            padding: EdgeInsets.fromLTRB(80, 10, 80, 10),
            color: Colors.redAccent,
            child: Text('Active specials',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontStyle: FontStyle.italic)),
          ),
        ),
      ],
    );
  }

  Widget disableUpload() {
    return Container(
      height: screen_width / 2 + 20,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 10.0,
            right: 1.0,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              elevation: 10,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('Fotos/steak.jpg'), fit: BoxFit.cover),
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                width: screen_width / 2,
                height: screen_width / 2,
              ),
            ),
          ),
          Positioned(
            top: 20.0,
            left: 1.0,
            child: Container(
              width: screen_width / 2,
              height: screen_width / 2 - 10,
              child: Card(
                elevation: 10.0,
                color: Colors.transparent,
                child: FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: <Widget>[
                        AutoSizeText(
                          _special,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          textScaleFactor: 1,
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        AutoSizeText(
                          'By ' + widget.sBusinessName,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 6.0),
                          maxLines: 3,
                          textScaleFactor: 1,
                        ),
                        Text("Estimated : X km")
                      ],
                    ),
                  ),
                  back: Container(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: AutoSizeText(
                        _description,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 20.0),
                        maxLines: 6,
                        textScaleFactor: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 1.0,
            bottom: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 210, 0),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.call),
                color: Colors.white,
                splashColor: Colors.greenAccent,
                onPressed: () {
                  launch('tel:' + widget.sPhoneNumber);
                },
              ),
            ),
          ),
          Positioned(
            left: 60.0,
            bottom: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.location_on),
                color: Colors.white,
                splashColor: Colors.lightBlueAccent,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      height: screen_width / 2 + 20,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 10.0,
            right: 1.0,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              elevation: 10,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(image), fit: BoxFit.cover),
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                width: screen_width / 2,
                height: screen_width / 2,
              ),
            ),
          ),
          Positioned(
            top: 20.0,
            left: 1.0,
            child: Container(
              width: screen_width / 2,
              height: screen_width / 2 - 10,
              child: Card(
                elevation: 10.0,
                color: Colors.transparent,
                child: FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: <Widget>[
                        AutoSizeText(
                          _special,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                            textScaleFactor: 1,
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        AutoSizeText(
                          'By ' + widget.sBusinessName,
                          style: TextStyle(color: Colors.grey, fontSize: 6.0),
                          maxLines: 1,
                          textScaleFactor: 1.0,
                        ),
                        Text("Estimated : X km", textScaleFactor: 1,)
                      ],
                    ),
                  ),
                  back: Container(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: AutoSizeText(
                        _description,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 20.0),
                        maxLines: 6,
                        textScaleFactor: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 1.0,
            bottom: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 210, 0),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.call),
                color: Colors.white,
                splashColor: Colors.greenAccent,
                onPressed: () {
                  launch('tel:' + widget.sPhoneNumber);
                },
              ),
            ),
          ),
          Positioned(
            left: 60.0,
            bottom: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.location_on),
                color: Colors.white,
                splashColor: Colors.lightBlueAccent,
              ),
            ),
          )
        ],
      ),
    );
  }

  bool validateSpecialName(String value) {
    if (value.length < 2)
      return true;
    else
      return false;
  }

  bool validateDescription(String value) {
    if (value.length < 2)
      return true;
    else
      return false;
  }
}
