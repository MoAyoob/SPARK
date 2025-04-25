# mock_iot_device.py
import socket
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from zeroconf import ServiceInfo, Zeroconf
import time

class MockIoTDevice:
    def __init__(self):
        self.device_name = "MockIoTDevice"
        self.ip_address = self.get_local_ip()
        self.port = 8080  
        self.service_type = "_http._tcp.local."
        service_name = f"{self.device_name}._http._tcp.local."  # Correct format
        self.zeroconf = Zeroconf()
        self.http_server = None

    def get_local_ip(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            s.connect(("8.8.8.8", 8080))
            ip = s.getsockname()[0]
        except Exception:
            ip = "127.0.0.1"
        finally:
            s.close()
        return ip

    def start_http_server(self):
        server_address = ('', self.port)
        self.http_server = ThreadingHTTPServer(server_address, SimpleHTTPRequestHandler)
        print(f"Starting HTTP server on port {self.port}")
        self.http_server.serve_forever()

    def advertise_service(self):
        service_name = f"{self.device_name}._http._tcp.local."
        service_info = ServiceInfo(
            self.service_type,
            service_name,
            addresses=[socket.inet_aton(self.ip_address)],
            port=self.port,
            properties={b'name': self.device_name.encode('utf-8')},
        )
        self.zeroconf.register_service(service_info)
        print(f"Advertising service {service_name} at {self.ip_address}")

    def start(self):
        try:
            # Start HTTP server in a separate thread
            import threading
            server_thread = threading.Thread(target=self.start_http_server)
            server_thread.daemon = True
            server_thread.start()
            
            # Advertise service via mDNS
            self.advertise_service()
            
            print("Mock IoT device running. Press Ctrl+C to stop...")
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            self.stop()

    def stop(self):
        print("Shutting down...")
        self.zeroconf.unregister_all_services()
        self.zeroconf.close()
        if self.http_server:
            self.http_server.shutdown()
        print("Service stopped")

if __name__ == "__main__":
    device = MockIoTDevice()
    device.start()