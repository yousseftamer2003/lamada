import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food2go_app/constants/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

class FullScreenMapScreen extends StatefulWidget {
  final CameraPosition initialPosition;

  const FullScreenMapScreen({
    super.key,
    required this.initialPosition,
  });

  @override
  State<FullScreenMapScreen> createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  List<AutocompletePrediction> predictions = [];
  List<AutocompletePrediction>? _searchResults;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  late GooglePlace googlePlace;

  @override
void initState() {
  super.initState();
  googlePlace = GooglePlace('AIzaSyDuPxES-ul4k6UU4MiME97aoWHpxRt7Www');
}

Future<void> _handleSearch(String query) async {
  var result = await googlePlace.autocomplete.get(
    query,
    components: [Component("country", "eg")],
  );

  if (result != null && result.predictions != null) {
    setState(() {
      _searchResults = result.predictions;
    });
  }
}


  void _selectLocation(LatLng position, String address) {
  setState(() {
    _selectedLocation = position;
    _selectedAddress = address;
    log('Selected Location: $position, Address: $address');
  });
}


  void _onSelectButtonPressed() {
    if (_selectedAddress != null) {
      Navigator.pop(context, _selectedAddress);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: 
            TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Search for a place',
    filled: true,
    fillColor: Colors.grey.shade300,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  ),
  onChanged: (value) {
    if (value.isNotEmpty) {
      _handleSearch(value);
    } else {
      setState(() => _searchResults = []);
    }
  },
),

          ),
          if (_searchResults != null && _searchResults!.isNotEmpty)
  Expanded(
    child: ListView.builder(
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final result = _searchResults![index];
        return ListTile(
          title: Text(result.description ?? ''),
          onTap: () async {
  final details = await googlePlace.details.get(result.placeId ?? '');
  if (details != null && details.result != null) {
    final location = details.result!.geometry!.location;
    if (location != null) {
      final latLng = LatLng(location.lat!, location.lng!);

      // Animate camera to the selected location
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 16), // Adjust the zoom level
      );

      // Update state to show the marker and address
      _selectLocation(latLng, result.description ?? '');
    }
  }

  // Clear search results to hide the dropdown
  setState(() {
    _searchResults = null;
  });
},

        );
      },
    ),
  ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: widget.initialPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: (LatLng position) {
                _selectLocation(position, 'Selected location');
                _mapController.animateCamera(
                  CameraUpdate.newLatLng(position),
                );
              },
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: _selectedLocation!,
                      )
                    }
                  : {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _onSelectButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: maincolor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Select'),
            ),
          ),
        ],
      ),
    );
  }
}
