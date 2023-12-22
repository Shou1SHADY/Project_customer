import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);

  @override
  _GoogleMapsScreenState createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? _mapController;
  Location _location = Location();
  LatLng _currentLocation = LatLng(0.0, 0.0);
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();

    if (_locationPermissionGranted) {
      _location.onLocationChanged.listen((LocationData currentLocation) {
        setState(() {
          _currentLocation =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
        _moveCameraToLocation();
      });
    }
  }

  void _checkLocationPermission() async {
    PermissionStatus permissionStatus = await _location.requestPermission();
    bool permissionGranted = permissionStatus == PermissionStatus.granted;
    setState(() {
      _locationPermissionGranted = permissionGranted;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void _moveCameraToLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 15.0),
      );
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      if (_selectedLocation != null) {
        _markers.removeWhere(
            (marker) => marker.markerId == MarkerId('selectedLocation'));
      }

      _selectedLocation = location;
      _markers.add(
        Marker(
          markerId: MarkerId('selectedLocation'),
          position: _selectedLocation!,
          infoWindow: InfoWindow(title: 'Selected Location'),
        ),
      );
    });
    _drawRoute();
  }

  void _drawRoute() {
    if (_selectedLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: _currentLocation,
            northeast: _selectedLocation!,
          ),
          100.0, // Padding value
        ),
      );

      Polyline polyline = Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: [
          _currentLocation,
          LatLng(_currentLocation.latitude, _selectedLocation!.longitude),
          _selectedLocation!,
        ],
      );

      setState(() {
        _polylines
            .clear(); // Clear existing polylines before adding the new one
        _polylines.add(polyline);
      });
    }
  }

  void _resetMarkersAndPolylines() {
    setState(() {
      _selectedLocation = null;
      _markers.removeWhere(
          (marker) => marker.markerId == MarkerId('selectedLocation'));
      _polylines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
            initialCameraPosition: CameraPosition(
              //  target: _currentLocation,
              target: LatLng(37.33500926, -122.03272188),
              zoom: 15.0,
            ),
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: _locationPermissionGranted,
            markers: _markers,
            polylines: _polylines,
          ),
          Visibility(
            visible: _selectedLocation != null,
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: _resetMarkersAndPolylines,
                child: Icon(Icons.clear),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
