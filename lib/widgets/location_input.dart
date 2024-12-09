import 'dart:convert';

import 'package:favorite_places/modals/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget{
 const LocationInput({super.key,required this.onSelectLocation});

 final void Function(PlaceLocation location) onSelectLocation;

 @override
  State<LocationInput> createState() {
   return _LocationInputState();
  }

}

class _LocationInputState extends State<LocationInput>{
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  String get locationImage{
    if(_pickedLocation == null){
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7C$lat,$lng&key=AIzaSyDI5h0k7rdLEoaPg6mefy4i-f9ogcHQXeA';
  }

  void _getCurrentLocation() async {
  
    Location location =  Location();

bool serviceEnabled;
PermissionStatus permissionGranted;
LocationData locationData;

serviceEnabled = await location.serviceEnabled();
if (!serviceEnabled) {
  serviceEnabled = await location.requestService();
  if (!serviceEnabled) {
    return;
  }
}

permissionGranted = await location.hasPermission();
if (permissionGranted == PermissionStatus.denied) {
  permissionGranted = await location.requestPermission();
  if (permissionGranted != PermissionStatus.granted) {
    return;
  }
}

  setState(() {
   
          _isGettingLocation = true;

    });

locationData = await location.getLocation();
final lat = locationData.latitude;
final lng = locationData.longitude;

if(lat == null || lng == null){
  return;
}
final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyDI5h0k7rdLEoaPg6mefy4i-f9ogcHQXeA');
final response = await http.get(url);
final resdata =  json.decode(response.body);
final address = resdata['results'][0]['formatted_address'];

setState(() {
   _pickedLocation = PlaceLocation(
    latitude: lat,
    longitude: lng,
    address: address
      );
          _isGettingLocation = false;

    });
//  print(locationData.latitude);
// print(locationData.latitude);
widget.onSelectLocation(_pickedLocation!);

  }

@override
  Widget build(BuildContext context) {
     Widget previewContent = Text('No location choosen',
    textAlign: TextAlign.center,
    style:Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: Theme.of(context).colorScheme.onBackground,
    )
    );

    if(_pickedLocation != null){
      previewContent = Image.network(
        locationImage,
      fit: BoxFit.cover,
      width: double.infinity,
      );
    }

    if(_isGettingLocation){
      previewContent = const CircularProgressIndicator();
    }

   return Column(children: [
    Container(
      alignment: Alignment.center,
      height: 170,
      width: double.infinity,
         decoration: BoxDecoration(
      border: Border.all(
        width: 1,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2))
    ),
    child: previewContent, 

    ),
   Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      TextButton.icon(
       onPressed:  _getCurrentLocation,
       icon: Icon(Icons.location_on),
      label: Text('get current location')),
        TextButton.icon(
       onPressed:( ){},
       icon: Icon(Icons.map),
      label: Text('select on map'))
    ],
   )
   ],);

  }
  }
