import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import 'widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}


/*
* From what I could understand this shit works as a Singleton in some apps
* (Basically it handles the global variables for your app I thin)
*/
class MyAppState extends ChangeNotifier with WidgetsBindingObserver {
  BluetoothConnection? connection;
  BluetoothDevice? device;
  bool _connected = false;
  bool _pressed = false;

  bool get connected => _connected;
  bool get pressed => _pressed;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setPressed(bool value) {
    _pressed = value;
    notifyListeners();
  }

  void connect(BluetoothConnection connection){
    this.connection = connection;
  }

  void deviceConnected(BluetoothDevice? device){
    this.device = device;
    notifyListeners();
  }
}


/*I think this is kinda like the main container, like a Scene in javafx or something like that
* Apparently making it a "StatefulWidget" makes it so you can have some features of the state
* properties in your class?*/
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  /*This is what I mean, apparently with a Stateless widget you can't modify the
  * states of your app, but you can get access to them declaring it like an object*/
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = BluetoothClass();
        break;
      case 2:
        page = CommunicateBluetooth();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    /*I'm not a huge fan of this shit, fortunately android studio makes it look pretty.
    * Even tho it looks like shit there we have some kind of "Widget state" where you can control
    * which view is being shown through the NavigationRail type, it's pretty cool*/
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth > 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bluetooth),
                      label: Text('Bluetooth test'),
                    ),
                    NavigationRailDestination(icon: Icon(Icons.message), label: Text("Comunicar"))
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}