
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:multicast_dns/multicast_dns.dart';

class DeviceDiscovery {
  MDnsClient? _mdnsClient;
  StreamSubscription<ResourceRecord>? _mdnsSubscription;
  final StreamController<PtrResourceRecord> _controller =
  StreamController<PtrResourceRecord>.broadcast();
  final List<String> _networkDevices = [];
  bool _isDiscovering = false;
  String _scanStatus = 'Not Started';

  Stream<PtrResourceRecord> get deviceStream => _controller.stream;
  List<String> get networkDevices => _networkDevices;
  String get scanStatus => _scanStatus;

  Future<void> startDiscovery() async {
    if (_isDiscovering) return;
    _isDiscovering = true;
    _scanStatus = 'Scanning...';
    _networkDevices.clear();
    _controller.sink.add(PtrResourceRecord('', 0, domainName: ''));

    try {
      if (kIsWeb) {
        await _webDiscovery();
      } else {
        await _nativeDiscovery();
      }
    } catch (e) {
      print("Discovery error: $e");
      _scanStatus = 'Scan Failed';
    } finally {
      _isDiscovering = false;
    }
  }

  Future<void> _nativeDiscovery() async {
    _mdnsClient = MDnsClient();
    try {
      final interfaces = await NetworkInterface.list();
      InternetAddress? ipv4Address;

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            ipv4Address = addr;
            break;
          }
        }
        if (ipv4Address != null) break;
      }

      await _mdnsClient!.start();
      _mdnsSubscription = _mdnsClient!
          .lookup(ResourceRecordQuery.serverPointer('_http._tcp.local'))
          .listen((response) async {  // Make the callback async
        if (response is PtrResourceRecord && !_controller.isClosed) {
          final deviceName = response.domainName;
          if (!_networkDevices.contains(deviceName)) {
            _networkDevices.add(deviceName);
            _controller.add(response);
          }
        }
      });
    } catch (e) {
      print("Native discovery error: $e");
      _scanStatus = 'Scan Failed';
    }
  }

  Future<void> _webDiscovery() async {
    if (!_controller.isClosed) {
      // Mock mDNS device
      _controller.add(PtrResourceRecord(
        'MockIoTDevice._http._tcp.local.',
        10,
        domainName: 'MockIoTDevice.local',
      ));

      _networkDevices.add('172.20.10.2');
      await Future.delayed(const Duration(seconds: 2));
    }
  }


  Future<Map<int, bool>> scanPorts(String host) async {
    final ports = [80]; // Simplified to only scan port 80
    final results = <int, bool>{};

    try {
      if (kIsWeb) {
        final client = HttpClient();
        for (var port in ports) {
          try {
            final request = await client.get(host, port, '')
                .timeout(const Duration(seconds: 2));
            await request.close();
            results[port] = true;
          } catch (_) {
            results[port] = false;
          }
        }
      } else {
        for (var port in ports) { //changed to a loop
          try {
            final socket = await Socket.connect(host, port)
                .timeout(const Duration(seconds: 2));
            socket.destroy();
            results[port] = true;
          } catch (_) {
            results[port] = false;
          }
        }
      }
    } catch (e) {
      print("Port scan error: $e");
      _scanStatus = 'Scan Failed';
    }

    return results;
  }

  void stopDiscovery() {
    _mdnsSubscription?.cancel();
    _mdnsClient?.stop();
    _mdnsClient = null;
    _isDiscovering = false;
    _scanStatus = 'Scan Complete';
    if (!_controller.isClosed) {
      _controller.add(PtrResourceRecord('', 0, domainName: ''));
    }
  }
}
