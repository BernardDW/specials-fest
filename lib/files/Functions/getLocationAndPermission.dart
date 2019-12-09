import 'package:location/location.dart';

Future<List> initPlatformState(Location _locationService, bool _permission) async {
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
          // setState(() {
          //   if (!bInitial) {
          //     getCityofUser(location);
          //     bInitial = true;
          //   }
          //   currentPos = location;
          //   globals.globalPosition = location;
          //   bLocation = true;
          // });
          // return true;
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          initPlatformState(_locationService, _permission);
        } else {
          // setState(() {
          //   isLocationEnabled = false;
          //   print(isLocationEnabled);
          // });
          // return false;
        }
      }
    } catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        // error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        // error = e.message;
      }
      location = null;
    }
  }