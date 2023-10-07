import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:water_app/Authentication/authenticate.dart';
import 'package:water_app/Login/home_screen.dart';
import 'package:water_app/Pages/map_page.dart';
// import 'package:water_app/water_temperature.dart';
import 'package:water_app/Pages/menu_book.dart';
import 'package:water_app/Storage/cloud_storage.dart';
import 'package:water_app/globals.dart';
import 'package:water_app/map_location.dart';
import 'package:water_app/processData/process_city.dart';
// import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  static String id = 'home_page';
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final String title;

  List<String> dataCountries = ["Taiwan", "America", "Canada"];
  String dataCountry = "Taiwan";

  late Widget currentWidget;
  late final List<Map<String, dynamic>> locations;

  int currentDrawerIndex = 0;
  @override
  void initState() {
    super.initState();
    title = widget.title;
    CloudStorage.loadUserData(Authentication.getCurrentUserEmail())
        .then((value) {
      currentUser = value;
    });
    locations = ProcessCities.citiesData;
    currentWidget = CheckCurrentPosition(country: dataCountry);
  }

  List<Map<String, dynamic>> _search(String str) {
    List<Map<String, dynamic>> results = [];
    for (var city in locations) {
      if (city['cityName'].toLowerCase().contains(str.toLowerCase())) {
        results.add(city);
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: <Widget>[
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  hintText: "Search place...",
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (string) {
                    // print(string);
                    controller.openView();
                  },
                  leading: Icon(Icons.search, color: Colors.grey[800]),
                );
              }, suggestionsBuilder:
                      (BuildContext context, SearchController controller) {
                List<Map<String, dynamic>> results = _search(controller.text);
                return results.take(15).map((location) {
                  return ListTile(
                    title: Text(location['cityName']),
                    onTap: () {
                      setState(() {
                        controller.closeView(location['cityName']);
                        currentWidget = CheckCurrentPosition(
                          country: dataCountry,
                          refSearchLocation: location['coordinate'] as LatLng,
                        );
                      });
                    },
                  );
                });
              }),
            ),
          ],
        ),
      ]),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.5,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    'Water App',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('menu_book'),
              onTap: () async {
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {
                  currentWidget = const MenuBook();
                });
              },
            ),
            for (int i = 0; i < dataCountries.length; i++)
              ListTile(
                  leading: const Icon(Icons.height_outlined),
                  title: Text(dataCountries[i]),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      currentWidget =
                          CheckCurrentPosition(country: dataCountries[i]);
                      dataCountry = dataCountries[i];
                    });
                  }),
            ListTile(
              leading: const Icon(Icons.height_outlined),
              title: const Text('Logout'),
              onTap: () async {
                if (!mounted) return;
                Authentication.signOut();
                Navigator.popUntil(context, ModalRoute.withName(HomeScreen.id));
              },
            ),
          ],
        ),
      ),
      body: currentWidget,
      // body: const Center(
      //   child: Text('Hello World'),
      // ),
    );
  }
}
