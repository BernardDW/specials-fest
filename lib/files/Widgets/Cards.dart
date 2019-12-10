import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flip_card/flip_card.dart';

class CardsDisplay extends StatelessWidget {
  final String sImageURL;
  final String sSpecialName;
  final String sBusiness;
  final String sDistance;
  final String sSpecialDescription;
  final String sPhoneNumber;
  final String sLatitude;
  final String sLongitude;
  final bool bNetworkImage;
  final bool bAssetImage;
  final File fAssetImage;
  final bool bShowLocation;

  CardsDisplay(
      {Key key,
      this.sImageURL,
      this.sSpecialName,
      this.sBusiness,
      this.sDistance,
      this.sSpecialDescription,
      this.sPhoneNumber,
      this.sLatitude,
      this.sLongitude,
      this.bNetworkImage,
      this.bAssetImage,
      this.fAssetImage,
      this.bShowLocation})
      : super(key: key);

  double dSiz = 180;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: dSiz + 20,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              elevation: 10,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: bNetworkImage
                          ? CachedNetworkImageProvider(this.sImageURL)
                          : bAssetImage ? AssetImage(this.sImageURL) : FileImage(this.fAssetImage),
                      fit: BoxFit.cover),
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                width: dSiz,
                height: dSiz,
              ),
            ),
          ),
          Positioned(
            top: 20.0,
            left: 10.0,
            child: Container(
              width: dSiz,
              height: dSiz - 10,
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
                          this.sSpecialName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                          maxLines: 4,
                          textScaleFactor: 1.0,
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        AutoSizeText(
                          'By ' + this.sBusiness,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 6.0),
                          maxLines: 3,
                          textScaleFactor: 1.0,
                        ),
                        Text(
                          this.sDistance + " km",
                          textScaleFactor: 1.0,
                        )
                      ],
                    ),
                  ),
                  back: Container(
                    padding:
                        EdgeInsets.only(left: 5.0, right: 5.0, bottom: 18.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: AutoSizeText(
                        this.sSpecialDescription,
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
            left: 5.0,
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
                  launch('tel:' + this.sPhoneNumber);
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
                onPressed: () {
                  bShowLocation
                      ? _launchMaps(this.sLatitude, this.sLongitude)
                      : print('No Location'); //dLat,dLong
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*OPEN MAPS*/
void _launchMaps(String latitude, String longitude) async {
  String googleURL =
      'https://www.google.com/maps/search/?api=1&query=$latitude, $longitude';
  if (await canLaunch(
      "https://www.google.com/maps/search/?api=1&query=$latitude, $longitude")) {
    print('launching googleURL');
    await launch(googleURL);
  } else {
    throw 'Could not luanch url';
  }
}
