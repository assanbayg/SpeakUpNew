import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:speakup/common/widgets/appbar.dart';
import 'package:speakup/features/speakup/screens/converter_screen.dart';
import 'package:speakup/features/speakup/screens/home_screen.dart';
import 'package:speakup/features/speakup/screens/profile_page.dart';
import 'package:speakup/util/data/marker_coords.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.text});

  final String text;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController mapController;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Get.to(const HomeScreen());
        break;
      case 1:
        Get.to(ConverterScreen());
        break;
      case 2:
        Get.to(const MapScreen(text: ""));
        break;
      case 3:
        Get.to(UserProfilePage());
        break;
    }
  }

  Widget _buildNavItem(String asset, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(asset, width: 24, height: 24),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
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
              child: const Icon(Icons.location_on, color: Colors.red, size: 30),
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
            child: DropdownButton<String>(
              value: dropdownValue,
              onChanged: _onDropDownChanged,
              items: <String>['Алматы', 'Астана']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            _buildNavItem('assets/images/chat.png', 'Спичи', 0),
            _buildNavItem('assets/images/convert.png', 'Конвертер', 1),
            _buildNavItem('assets/images/marker.png', 'Центры', 2),
            _buildNavItem('assets/images/profile.png', 'Профайл', 3),
          ],
        ),
      ),
    );
  }
}
