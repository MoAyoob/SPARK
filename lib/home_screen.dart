import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bill_management_screen.dart';
import 'rewards_screen.dart';
import 'usage_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Device> _devices = [
    Device(
      name: "Smart TV",
      room: "Haidar room",
      status: false,
      icon: 'tv.svg',
    ),
    Device(
      name: "Air Purifier",
      room: "Kitchen",
      status: true,
      icon: 'air-purifier.svg',
    ),
    Device(
      name: "Air Conditioner",
      room: "Hussain\'s Room",
      status: false,
      icon: 'air-conditioner.svg',
    ),
    Device(
      name: "Main Router",
      room: "Huawei Router 5G",
      status: true,
      icon: 'router.svg',
    ),
    Device(
      name: "Smart Light",
      room: "Hall - 4 lights",
      status: false,
      icon: 'light-bulb.svg',
    ),
    Device(name: "Socket", room: "Kitchen", status: false, icon: 'plug.svg'),
  ];

  // *** CORRECT WIDGET LIST (ORDER IS CRUCIAL) ***
  final List<Widget> _widgetOptions = [
    HomeScreenContent(), // Index 0: My Home
    UsageAnalysisScreen(), // Index 1: Analytics
    BillManagementScreen(), // Index 2: Bill
    RewardsScreen(), // Index 3: Rewards
  ];

  @override //  *** IMPLEMENT THE build METHOD ***
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), //  Display the selected content
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'My Home'),
          // Index 0: HomeScreenContent
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Analytics'),
          // Index 1: UsageAnalysisScreen
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Bill'),
          // Index 2: BillManagementScreen
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Rewards'),
          // Index 3: RewardsScreen
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        iconSize: 24,
        showUnselectedLabels: false,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final List<Device> _devices = [
    Device(
      name: "Smart TV",
      room: "Haidar room",
      status: false,
      icon: 'tv.svg',
    ),
    Device(
      name: "Air Purifier",
      room: "Kitchen",
      status: true,
      icon: 'air-purifier.svg',
    ),
    Device(
      name: "Air Conditioner",
      room: "Hussain\'s Room",
      status: false,
      icon: 'air-conditioner.svg',
    ),
    Device(
      name: "Main Router",
      room: "Huawei Router 5G",
      status: true,
      icon: 'router.svg',
    ),
    Device(
      name: "Smart Light",
      room: "Hall - 4 lights",
      status: false,
      icon: 'light-bulb.svg',
    ),
    Device(name: "Socket", room: "Kitchen", status: false, icon: 'plug.svg'),
  ];

  Widget _buildControlButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required BoxConstraints constraints,
  }) {
    String iconPath = "assets/icons/$icon";
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[100],
            padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.04,
                vertical: constraints.maxHeight * 0.02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(constraints.maxWidth * 0.025),
            ),
          ),
          child: SvgPicture.asset(
            iconPath,
            width: constraints.maxWidth * 0.12,
            height: constraints.maxHeight * 0.06,
            colorFilter: const ColorFilter.mode(
              Colors.green,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.008),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: constraints.maxWidth * 0.035,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Mohammed\'s Home",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: constraints.maxWidth * 0.055,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person),
                      iconSize: constraints.maxWidth * 0.065,
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: constraints.maxHeight * 0.018),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(constraints.maxWidth * 0.022),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[200]!, Colors.green[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                    BorderRadius.circular(constraints.maxWidth * 0.018),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Current bill",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: constraints.maxWidth * 0.038,
                        ),
                      ),
                      Text(
                        "17.03 BHD",
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.w900,
                          fontSize: constraints.maxWidth * 0.038,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.018),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildControlButton(
                      icon: "control.svg",
                      label: "Control & Secure",
                      onPressed: () {},
                      constraints: constraints,
                    ),
                    _buildControlButton(
                      icon: "add.svg",
                      label: "Add Devices",
                      onPressed: () {},
                      constraints: constraints,
                    ),
                    _buildControlButton(
                      icon: "solar.svg",
                      label: "Solar Panel",
                      onPressed: () {},
                      constraints: constraints,
                    ),
                  ],
                ),
                SizedBox(height: constraints.maxHeight * 0.018),
                Text(
                  "My IoT Devices",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: constraints.maxWidth * 0.042,
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.008),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: constraints.maxWidth * 0.012,
                    mainAxisSpacing: constraints.maxHeight * 0.008,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    return _buildDeviceItem(
                      device: _devices[index],
                      context: context,
                      constraints: constraints,
                      onStatusChanged: (value) {
                        setState(() {
                          _devices[index].status = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceItem({
    required Device device,
    required BuildContext context,
    required BoxConstraints constraints,
    required ValueChanged<bool> onStatusChanged,
  }) {
    String iconPath = "assets/icons/${device.icon}";
    return Card(
      color: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(constraints.maxWidth * 0.018),
      ),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.012),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.042,
              child: Align(
                alignment: Alignment.center,
                child: _buildDeviceIcon(
                  device.icon,
                  constraints.maxWidth * 0.075,
                  constraints.maxHeight * 0.042,
                ),
              ),
            ),
            Text(
              device.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.026,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              device.room,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.021,
                color: Colors.grey[600],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  device.status ? "On" : "Off",
                  style: TextStyle(fontSize: constraints.maxWidth * 0.021),
                ),
                Transform.scale(
                  scale: 0.6,
                  child: Switch(
                    value: device.status,
                    onChanged: onStatusChanged,
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.grey,
                  size: constraints.maxWidth * 0.038,
                ),
                onPressed: () {
                  _showDeviceControlPopup(context);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceIcon(String iconPath, double width, double height) {
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        "assets/icons/$iconPath",
        width: width,
        height: height,
        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
      );
    } else if (iconPath.endsWith('.png') || iconPath.endsWith('.jpg')) {
      return Image.asset(
        "assets/icons/$iconPath",
        width: width,
        height: height,
      );
    } else {
      return Icon(
        Icons.question_mark,
        size: width,
        color: Colors.green,
      );
    }
  }

  void _showDeviceControlPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(content: DeviceControlScreen());
      },
    );
  }
}

class Device {
  String name;
  String room;
  bool status;
  String icon;

  Device({
    required this.name,
    required this.room,
    required this.status,
    required this.icon,
  });
}

class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({Key? key}) : super(key: key);

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  final List<String> devices = [
    "Living Room Light",
    "Kitchen Light",
    "Bedroom Light",
    "Water Valve",
  ];
  final Map<String, bool> _deviceStates = {};
  @override
  void initState() {
    super.initState();
    for (var device in devices) {
      _deviceStates[device] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...devices.map((device) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListTile(
                  title: Text(device),
                  trailing: Switch(
                    value: _deviceStates[device] ?? false,
                    onChanged: (bool value) {
                      setState(() {
                        _deviceStates[device] = value;
                      });
                      print("Device '$device' toggled to: $value");
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

