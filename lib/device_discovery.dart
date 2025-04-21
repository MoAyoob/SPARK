import 'dart:async';
import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';

class DeviceDiscovery {
  MDnsClient _mdnsClient = MDnsClient();
  final StreamController<PtrResourceRecord> _controller = // Changed to PtrResourceRecord
  StreamController<PtrResourceRecord>.broadcast();
  final List<String> _networkDevices = [];

  Stream<PtrResourceRecord> get deviceStream => _controller.stream;
  List<String> get networkDevices => _networkDevices;

  Future<void> startDiscovery() async {
    try {
      await _mdnsClient.start();
      await _sweepNetwork();

      // mDNS discovery with proper type handling
      final stream = _mdnsClient.lookup(
        ResourceRecordQuery.serverPointer('_http._tcp.local'),
      );

      await for (ResourceRecord response in stream) { // Single record per response
        if (response is PtrResourceRecord) {
          final deviceName = response.domainName;
          if (!_networkDevices.contains(deviceName)) {
            _networkDevices.add(deviceName);
          }
          _controller.add(response); // Send the PtrResourceRecord directly
        }
      }
    } catch (e) {
      print("Discovery error: $e");
    }
  }

  Future<void> _sweepNetwork() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              final baseIp = parts.sublist(0, 3).join('.');
              await Future.wait(List.generate(255, (i) async {
                final host = '$baseIp.${i + 1}';
                try {
                  final socket = await Socket.connect(host, 80,
                      timeout: Duration(milliseconds: 200));
                  socket.destroy();
                  if (!_networkDevices.contains(host)) {
                    _networkDevices.add(host);
                  }
                } catch (_) {}
              }));
            }
          }
        }
      }
    } catch (e) {
      print("Network sweep error: $e");
    }
  }

  Future<Map<int, bool>> scanPorts(String host) async {
    final ports = [22, 23, 80, 443, 8080, 8888];
    final results = <int, bool>{};

    await Future.wait(ports.map((port) async {
      try {
        final socket = await Socket.connect(host, port, timeout: Duration(seconds: 1));
        socket.destroy();
        results[port] = true;
      } catch (_) {
        results[port] = false;
      }
    }));

    return results;
  }

  void stopDiscovery() {
    _mdnsClient.stop();
    _controller.close();
    _networkDevices.clear();
  }
}