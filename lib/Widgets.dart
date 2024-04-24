/*This is like a component in angular, here you do some shit with it's own view
  * It's literally a view object in a MVC*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import 'Design.dart';
import 'main.dart';

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BigCard(),
          const SizedBox(height: 10),
          Text(
            "App desarrollada por Leonardo",
            style: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

/*Another class. Another view
  * This is in order to handle the favorite words of the state class, it's cool and shi*/
class BluetoothClass extends StatefulWidget {
  const BluetoothClass({super.key});

  @override
  State<BluetoothClass> createState() => _BluetoothClassState();
}

class _BluetoothClassState extends State<BluetoothClass>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey();
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  var _deviceList = <BluetoothDevice>[] = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    bluetoothConnectionState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      bluetoothConnectionState();
    }
  }

  Future<void> bluetoothConnectionState() async {
    List<BluetoothDevice> devices = [];

    // Get the list of paired devices

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    //Know when is connected and disconnected

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothBondState.bonded:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case BluetoothBondState.none:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        case BluetoothState.STATE_TURNING_OFF:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        default:
          print(state);
      }
    });

    if (!mounted) {
      return;
    }

    setState(() {
      _deviceList = devices;
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if(Provider.of<MyAppState>(context, listen: false).connected){
      items.add(DropdownMenuItem(
        child: Text(Provider.of<MyAppState>(context, listen: false).device?.name ?? 'No Name Available'),
      ));
    }
    if (_deviceList.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in _deviceList) {
        if(device == Provider.of<MyAppState>(context, listen: false).device){
          continue;
        }
        items.add(DropdownMenuItem(
          value: device,
          child: Text(
            device.name ?? 'No Name Available',
          ),
        ));
      }
    }
    return items;
  }

  BluetoothConnection? _connection;

  void _connect() {
    if (_device == null) {
      show('No device selected');
      print("No device connected");
    } else {
      bluetooth.isEnabled.then((isConnected) {
        if (isConnected!) {
          try {
            BluetoothConnection.toAddress(_device?.address).then((value) {
              _connection = value;
              Provider.of<MyAppState>(context, listen: false).setPressed(false);
              Provider.of<MyAppState>(context, listen: false).setConnected(true);
              Provider.of<MyAppState>(context, listen: false).connect(_connection!);
              Provider.of<MyAppState>(context, listen: false).deviceConnected(_device);
              show('Connected to ${_device?.name}');
            }).catchError((error) {
              show('Error: $error');
            });
          } catch (e) {
            show('Error: $e');
          }
        }
      });
    }
  }

  void _disconnect() {
    _connection = Provider.of<MyAppState>(context, listen: false).connection;
    _connection?.dispose();
    Provider.of<MyAppState>(context, listen: false).setPressed(false);
    Provider.of<MyAppState>(context, listen: false).setConnected(false);
  }

  Future show(
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Builder(builder: (context) {
      return Scaffold(
          key: _globalKey,
          appBar: AppBar(title: const Center(child: Text("Bluetooth"))),
          backgroundColor: Colors.purpleAccent,
          body: Container(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //This is to center your column to the vertical (idk if it affects horizontal too)
                      children: [
                        MsgBlock(),
                        SizedBox(
                          height: 10,
                        ),
                        //This is some kind of margin on y (and I guess you can do it on x too).
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            const Text('Device',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            DropdownButton(
                                items: _getDeviceItems(),
                                onChanged: (value) =>
                                    setState(() => _device = value!),
                                value: _device),
                          ]
                      )
                  ),
                  Center(
                      child: Column(
                        children: [
                          ElevatedButton(
                              onPressed: appState.pressed
                                  ? null
                                  : appState.connected
                                  ? _disconnect
                                  : _connect,
                              child: Text(appState.connected ? 'Disconnect' : 'Connect')
                          )
                        ]
                      )
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: ConnectionS(connected: appState.connected),
                    )
                  )
                  ),
                  Expanded(child: Center(
                    child:
                        Text(appState.connected ? 'Conectado a: ${appState.device?.name}' : 'No conectado', style: TextStyle(fontSize: 20, color: appState.connected ? Colors.black : Colors.red))
                  )
                  )
                ],
              ),
          )
      );
    });
  }
}

