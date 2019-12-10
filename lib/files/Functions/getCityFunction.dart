import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void getCityofUser(double lat, double long) async {
  var placemark = await Geolocator()
      .placemarkFromCoordinates(lat, long);
  var result = await http
      .post("http://specials-fest.com/PHP/addUserLocation.php", body: {
    "userdate": DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
    "usercity": placemark.first.locality.toString(),
  });
}