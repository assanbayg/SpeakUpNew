import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:speakup/common/widgets/appbar.dart';
import 'package:speakup/features/speakup/screens/converter_screen.dart';
import 'package:speakup/features/speakup/screens/home_screen.dart';
import 'package:speakup/features/speakup/screens/profile_page.dart';

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

  // Store all coordinates in a LatLng list 
  // TODO: move this to a separate file
  final List<LatLng> markerCoords = [
    const LatLng(51.1684126, 71.4377708),
    const LatLng(51.110174, 71.4405484),
    const LatLng(51.1458321, 71.391254),
    const LatLng(51.1404791, 71.4816291),
    const LatLng(51.1318099, 71.4431659),
    const LatLng(51.1584428, 71.4392943),
    const LatLng(51.1645947, 71.4210839),
    const LatLng(51.1141434, 71.419799),
    const LatLng(51.0968369, 71.4283003),
    const LatLng(51.1318099, 71.4431659),
    const LatLng(51.1318099, 71.4431659),
    const LatLng(51.1318099, 71.4431659),
    const LatLng(51.1318099, 71.4431659),
    const LatLng(51.1318099, 71.4431659),
    const LatLng(43.2279509, 76.9298164),
    const LatLng(43.2483956, 76.9242436),
    const LatLng(43.2588596, 76.9215298),
    const LatLng(43.2647393, 76.9418947),
    const LatLng(43.1954553, 76.9166263),
    const LatLng(43.2607363, 76.9382604),
    const LatLng(43.2631766, 76.9407591),
    const LatLng(43.2647393, 76.9418947),
    const LatLng(43.2625185, 76.917988),
    const LatLng(43.259426, 76.923469),
    const LatLng(43.2531557, 76.9462131),
    const LatLng(43.2441716, 76.9029286),
    const LatLng(43.257839, 76.936721),
    const LatLng(43.2491872, 76.9153096),
  ];

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
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
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
