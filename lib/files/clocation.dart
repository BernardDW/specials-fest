import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart' as GeoLoc;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
import 'Widgets/Cards.dart';
import 'globalvariables.dart' as globals;
import 'package:flutter/services.dart';
import 'package:location/location.dart';

List<dynamic> lMonday,
    lTuesday,
    lWednesday,
    lThursday,
    lFriday,
    lSaturday,
    lSunday;

List<dynamic> lMondayTemp = List(),
    lTuesdayTemp = List(),
    lWednesdayTemp = List(),
    lThursdayTemp = List(),
    lFridayTemp = List(),
    lSaturdayTemp = List(),
    lSundayTemp = List();

double screen_width;
LocationData currentPos = null;
bool bStore = false;
bool bInitial = false;
bool isLocationEnabled = true;
bool _permission = false;

List<String> _SpecialPlaces = List();

class CurrentLocation extends StatefulWidget {
  @override
  _CurrentLocation createState() => _CurrentLocation();
}

class _CurrentLocation extends State<CurrentLocation> {
  List<String> _sFoodType = ["All", "Food", "Drinks"];
  List<String> _sDistanceOrder = ["Ascending", "Descending"];
  List<String> _sDayName = List(7);
  List<String> _dateDayName = List(7);
  var now;
  bool bLocation = false;
  var displayTypeFood = 'All';
  var typeFood = 'All';
  int _distanceValue = 20;
  String sDistanceOrder = 'ASC';
  String displayDistanceOrder = "Ascending";
  Location _locationService = new Location();
  String error;

  getMethod(int iDistance, String sDay, String sType, double lat, double long,
      List<dynamic> lDay, String dateDay, String sDistaceOrder) async {
    if (bStore == false) {
      String theUrl =
          'http://specials-fest.com/PHP/getData.php?days=$sDay&distance=$iDistance&latitude=$lat&longitude=$long&type=$sType&datestring=$dateDay&distanceorder=$sDistaceOrder';
      var res = await http
          .get(Uri.encodeFull(theUrl), headers: {"Accept": "application/json"});
      List<dynamic> responsBody = json.decode(res.body);

      switch (sDay) {
        case "Monday":
          {
            _SpecialPlaces.clear();
            lMonday = responsBody;
          }
          break;

        case "Tuesday":
          {
            lTuesday = responsBody;
          }
          break;

        case "Wednesday":
          {
            lWednesday = responsBody;
          }
          break;

        case "Thursday":
          {
            lThursday = responsBody;
          }
          break;

        case "Friday":
          {
            lFriday = responsBody;
          }
          break;

        case "Saturday":
          {
            lSaturday = responsBody;
          }
          break;

        case "Sunday":
          {
            lSunday = responsBody;
            bStore = true;
          }
          break;

        default:
          {
            print("Invalid choice");
          }
          break;
      }
      int iTeller = 0;
      responsBody.forEach((e) {
        if (_SpecialPlaces.length == 0) {
          _SpecialPlaces.add('All Places');
          _SpecialPlaces.add(responsBody[iTeller]['businessname']);
        } else if (!_SpecialPlaces.contains(
            responsBody[iTeller]['businessname'])) {
          _SpecialPlaces.add(responsBody[iTeller]['businessname']);
        }
        iTeller++;
      });
      return responsBody;
    } else {
      return lDay;
    }
  }

  @override
  void initState() {
    super.initState();
    now = new DateTime.now().weekday.toInt() - 1;
    int _iDayNow = now;
    for (int iTel = 0; iTel < 7; iTel++) {
      if (_iDayNow == 7) {
        _iDayNow = 0;
      }
      var formatter = DateFormat('dd LLL');
      var iFormatter = DateFormat('y-M-d');
      _dateDayName[_iDayNow] = iFormatter
          .format(DateTime.now().add(Duration(days: iTel)))
          .toString();
      _sDayName[_iDayNow] =
          formatter.format(DateTime.now().add(Duration(days: iTel))).toString();
      _iDayNow++;
    }

    if (currentPos == null) {
      print('get Current location');
      initPlatformState();
    } else {
      bLocation = true;
    }
  }

  initPlatformState() async {
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 1000);

    LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        print("Permission: $_permission");
        if (_permission) {
          location = await _locationService.getLocation();
          setState(() {
            if (!bInitial) {
              getCityofUser(location);
              bInitial = true;
            }
            currentPos = location;
            globals.globalPosition = location;
            bLocation = true;
          });
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          initPlatformState();
        } else {
          setState(() {
            isLocationEnabled = false;
            print(isLocationEnabled);
          });
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      location = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    screen_width = media.size.width;
    return DefaultTabController(
      initialIndex: now,
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: SearchSpecials());
              },
            )
          ],
          backgroundColor: Colors.indigo,
          centerTitle: true,
          title: Text(
            'Specials Fest',
            textScaleFactor: 1.0,
          ),
          bottom: TabBar(isScrollable: true, tabs: [
            Tab(
              text: 'Monday\n' + _sDayName[0],
            ),
            Tab(
              text: 'Tuesday\n' + _sDayName[1],
            ),
            Tab(
              text: 'Wednesday\n' + _sDayName[2],
            ),
            Tab(
              text: 'Thursday\n' + _sDayName[3],
            ),
            Tab(
              text: 'Friday\n' + _sDayName[4],
            ),
            Tab(
              text: 'Saturday\n' + _sDayName[5],
            ),
            Tab(
              text: 'Sunday\n' + _sDayName[6],
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            ListDae('Monday', lMonday, _dateDayName[0]),
            ListDae('Tuesday', lTuesday, _dateDayName[1]),
            ListDae('Wednesday', lWednesday, _dateDayName[2]),
            ListDae('Thursday', lThursday, _dateDayName[3]),
            ListDae('Friday', lFriday, _dateDayName[4]),
            ListDae('Saturday', lSaturday, _dateDayName[5]),
            ListDae('Sunday', lSunday, _dateDayName[6])
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                  child: Image.asset('Fotos/logo.png'),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: <Color>[
                    Colors.deepOrangeAccent,
                    Colors.orange
                  ]))),
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.fastfood,
                  color: Colors.red,
                ),
                title: Text('Special Type :'),
                trailing: DropdownButton<String>(
                  value: displayTypeFood,
                  items: _sFoodType.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem));
                  }).toList(),
                  onChanged: (String newValueSelected) {
                    if (this.mounted) {
                      this.setState(() {
                        bStore = false;
                        typeFood = newValueSelected;
                        displayTypeFood = newValueSelected;
                      });
                    }
                  },
                ),
              ),
              Divider(),
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.filter_list,
                  color: Colors.blue,
                ),
                title: Text('Distance :'),
                trailing: DropdownButton<String>(
                  value: displayDistanceOrder,
                  items: _sDistanceOrder.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem));
                  }).toList(),
                  onChanged: (String newValueSelected) {
                    if (this.mounted) {
                      this.setState(() {
                        bStore = false;
                        if (newValueSelected == "Ascending") {
                          sDistanceOrder = 'ASC';
                        } else {
                          sDistanceOrder = 'DESC';
                        }
                        displayDistanceOrder = newValueSelected;
                      });
                    }
                  },
                ),
              ),
              Divider(),
              FluidSlider(
                value: _distanceValue.toDouble(),
                labelsTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                min: 0.0,
                max: 200.0,
                valueTextStyle: TextStyle(fontSize: 15),
                onChanged: (double newValue) {
                  if (this.mounted) {
                    setState(() {
                      bStore = false;
                      _distanceValue = newValue.round();
                    });
                  }
                },
              ),
              Center(
                child: Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Current filter distance : $_distanceValue km",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )),
              ),
              Divider(),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      bLocation = false;
                      isLocationEnabled = true;
                      initPlatformState();
                      bStore = false;
                    });
                  },
                  color: Colors.blueAccent,
                  child: Text(
                    'Reload Location',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget ListDae(String sDay, List<dynamic> lDay, String dateDay) {
    if (!bLocation) {
      //Die load aan die begin waar sy value true is
      if (!isLocationEnabled) {
        return Center(
            child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
              child: Text(
                'Please ENABLE your location to display specials',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Open Sans',
                    fontSize: 20),
              ),
            ),
            RaisedButton(
              onPressed: () {
                initPlatformState();
              },
              color: Colors.blueAccent,
              child: Text(
                'Enable Location',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ));
      } else {
        return Center(
          child: Text(
            'Getting location...',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontFamily: 'Open Sans',
                fontSize: 20),
          ),
        );
      }
    } else {
      return FutureBuilder(
        future: getMethod(_distanceValue, sDay, typeFood, currentPos.latitude,
            currentPos.longitude, lDay, dateDay, sDistanceOrder),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List snap = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Error fetching Data \n Please check your connection",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: RawMaterialButton(
                      shape: CircleBorder(),
                      fillColor: Colors.blueAccent,
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (this.mounted) {
                          setState(() {});
                        }
                      },
                    ),
                    width: 50,
                    height: 50,
                  )
                ],
              ),
            );
          }
          if (snap.length != 0) {
            return RefreshIndicator(
              onRefresh: () {
                pullRefresh();
              },
              child: ListView.builder(
                itemCount: snap.length,
                itemBuilder: (context, index) {
                  return CardsDisplay(
                    sImageURL: "${snap[index]['imageurl']}",
                    sSpecialName: "${snap[index]['specialname']}",
                    sBusiness: "${snap[index]['businessname']}",
                    sDistance: "${snap[index]['distance']}",
                    sSpecialDescription: "${snap[index]['specialdescription']}",
                    sPhoneNumber: '${snap[index]['phonenumber']}',
                    sLatitude: '${snap[index]['latitude']}',
                    sLongitude: '${snap[index]['longitude']}',
                    bNetworkImage: true,
                    bShowLocation: true,
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Text(
                "Sorry no specials for this day \n Check filter distance",
                textAlign: TextAlign.center,
                textScaleFactor: 1.0,
              ),
            );
          }
        },
      );
    }
  }

  void SearchPlacePressed(String sPlace) {
    if (sPlace == 'All Places') {
      if (lMondayTemp.length != 0 ||
          lTuesdayTemp.length != 0 ||
          lWednesdayTemp.length != 0 ||
          lThursdayTemp.length != 0 ||
          lFridayTemp.length != 0 ||
          lSaturdayTemp.length != 0 ||
          lSundayTemp.length != 0) {
        lMonday = lMondayTemp;
        lTuesday = lTuesdayTemp;
        lWednesday = lWednesdayTemp;
        lThursday = lThursdayTemp;
        lFriday = lFridayTemp;
        lSaturday = lSaturdayTemp;
        lSunday = lSundayTemp;
      }
    } else {
      if (lMondayTemp.length != 0 ||
          lTuesdayTemp.length != 0 ||
          lWednesdayTemp.length != 0 ||
          lThursdayTemp.length != 0 ||
          lFridayTemp.length != 0 ||
          lSaturdayTemp.length != 0 ||
          lSundayTemp.length != 0) {
        lMonday = lMondayTemp;
        lTuesday = lTuesdayTemp;
        lWednesday = lWednesdayTemp;
        lThursday = lThursdayTemp;
        lFriday = lFridayTemp;
        lSaturday = lSaturdayTemp;
        lSunday = lSundayTemp;
      }
      lMondayTemp = List();
      lTuesdayTemp = List();
      lWednesdayTemp = List();
      lThursdayTemp = List();
      lFridayTemp = List();
      lSaturdayTemp = List();
      lSundayTemp = List();
      lMondayTemp.addAll(lMonday);
      lTuesdayTemp.addAll(lTuesday);
      lWednesdayTemp.addAll(lWednesday);
      lThursdayTemp.addAll(lThursday);
      lFridayTemp.addAll(lFriday);
      lSaturdayTemp.addAll(lSaturday);
      lSundayTemp.addAll(lSunday);
      lMonday.clear();
      lTuesday.clear();
      lWednesday.clear();
      lThursday.clear();
      lFriday.clear();
      lSaturday.clear();
      lSunday.clear();
      int iTeller = 0;
      lMondayTemp.forEach((e) {
        if (lMondayTemp[iTeller]['businessname'] == sPlace) {
          lMonday.add(lMondayTemp[iTeller]);
        }
        iTeller++;
      });
      iTeller = 0;
      lTuesdayTemp.forEach((e) {
        if (lTuesdayTemp[iTeller]['businessname'] == sPlace) {
          lTuesday.add(lTuesdayTemp[iTeller]);
        }
        iTeller++;
      });
      iTeller = 0;
      lWednesdayTemp.forEach((e) {
        if (lWednesdayTemp[iTeller]['businessname'] == sPlace) {
          lWednesday.add(lWednesdayTemp[iTeller]);
        }
        iTeller++;
      });
      iTeller = 0;
      lThursdayTemp.forEach((e) {
        if (lThursdayTemp[iTeller]['businessname'] == sPlace) {
          lThursday.add(lThursdayTemp[iTeller]);
        }
        iTeller++;
      });
      iTeller = 0;
      lFridayTemp.forEach((e) {
        if (lFridayTemp[iTeller]['businessname'] == sPlace) {
          lFriday.add(lFridayTemp[iTeller]);
        }
        iTeller++;
      });
      iTeller = 0;
      lSaturdayTemp.forEach((e) {
        if (lSaturdayTemp[iTeller]['businessname'] == sPlace) {
          lSaturday.add(lSaturdayTemp[iTeller]);
        }
        iTeller++;
      });
      iTeller = 0;
      lSundayTemp.forEach((e) {
        if (lSundayTemp[iTeller]['businessname'] == sPlace) {
          lSunday.add(lSundayTemp[iTeller]);
        }
        iTeller++;
      });
    }
    print(sPlace);
  }

  Future<Null> pullRefresh() async {
    setState(() {
      bStore = false;
    });
    await Future.delayed(Duration(seconds: 2));
    return null;
  }
}

class SearchSpecials extends SearchDelegate<String> {
  final recentSpecialSearch = _SpecialPlaces;

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSpecialSearch
        : _SpecialPlaces.where(
                (p) => p.startsWith(new RegExp(query, caseSensitive: false)))
            .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          _CurrentLocation().SearchPlacePressed(suggestionList[index]);
          close(context, null);
        },
        leading: Icon(Icons.fastfood),
        title: RichText(
          text: TextSpan(
              text: suggestionList[index].substring(0, query.length),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: suggestionList[index].substring(query.length),
                    style: TextStyle(color: Colors.grey))
              ]),
        ),
      ),
      itemCount: suggestionList.length,
    );
  }
}

void getCityofUser(LocationData pos) async {
  var placemark = await GeoLoc.Geolocator()
      .placemarkFromCoordinates(pos.latitude, pos.longitude);
  var result = await http
      .post("http://specials-fest.com/PHP/addUserLocation.php", body: {
    "userdate": DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
    "usercity": placemark.first.locality.toString(),
  });
}
