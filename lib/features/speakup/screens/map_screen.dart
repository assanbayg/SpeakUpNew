import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:speakup/common/widgets/appbar.dart';
import 'package:speakup/common/widgets/bottom_navigation_bar.dart';
import 'package:speakup/util/data/marker_coords.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.text});

  final String text;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController mapController;
  static const int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }


  String dropdownValue = 'Алматы';

  void _onDropDownChanged(String? city) {
    setState(() {
      dropdownValue = city!;
      LatLng target;
      if (city == 'Алматы') {
        target = const LatLng(43.270447, 76.887133);
      } else {
        target = const LatLng(51.140712, 71.427101);
      }
      mapController.move(target, 12.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final markers = markerCoords
        .map((point) => Marker(
              point: point,
              width: 40,
              height: 40,
              child: SvgPicture.asset(
                'assets/icons/Location_fill.svg',
                width: 30,
                height: 30,
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
              ),
            ))
        .toList();

    return Scaffold(
      appBar: const SAppBar(
        page: "Map",
        title: "Логопедические центры",
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              initialCenter: LatLng(43.270447, 76.887133),
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.devoasis.speakup',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            bottom: 50.0,
            left: 15.0,
            child: Text(widget.text),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<String>(
                value: dropdownValue,
                onChanged: _onDropDownChanged,
                underline: const SizedBox(),
                icon: SvgPicture.asset(
                  'assets/icons/Arrow_down.svg',
                  width: 16,
                  height: 16,
                ),
                items: <String>['Алматы', 'Астана']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SBottomNavigationBar(
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
