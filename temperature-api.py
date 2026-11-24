import argparse
import json
import os
import re
import time
from functools import partial
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Lock
from urllib.parse import urlsplit


SENSOR_DIR = Path('/sys/bus/w1/devices')
READ_ATTEMPTS = 3
SENSOR_READ_LOCK = Lock()
SENSOR_ENV = {
    '/sensors/outdoor/temperature': 'OUTDOOR_SENSOR_ID',
    '/sensors/indoor/temperature': 'INDOOR_SENSOR_ID',
}


def read_temperature(sensor_file=None):
    if sensor_file is None:
        sensor_file = next(iter(sorted(SENSOR_DIR.glob('28-*/w1_slave'))), None)
        if sensor_file is None:
            raise OSError('No DS18B20 sensor found')

    for attempt in range(READ_ATTEMPTS):
        lines = sensor_file.read_text(encoding='ascii').splitlines()
        if len(lines) >= 2 and lines[0].rstrip().endswith(' YES'):
            _, marker, value = lines[1].partition('t=')
            if marker:
                celsius = int(value) / 1000
                return {
                    'celsius': celsius,
                    'fahrenheit': round(celsius * 9 / 5 + 32, 4),
                }

        if attempt < READ_ATTEMPTS - 1:
            time.sleep(0.2)

    raise OSError('Sensor returned no valid reading')


class TemperatureHandler(BaseHTTPRequestHandler):
    def __init__(self, *args, sensor_file=None, named_sensor_files=None, **kwargs):
        self.sensor_file = sensor_file
        self.named_sensor_files = named_sensor_files or {}
        super().__init__(*args, **kwargs)

    def do_GET(self):
        path = urlsplit(self.path).path
        if path == '/temperature':
            sensor_file = self.sensor_file
        elif path in SENSOR_ENV:
            sensor_file = self.named_sensor_files.get(path)
            if sensor_file is None:
                self.send_json(503, {'error': 'Temperature sensor not configured'})
                return
        else:
            self.send_json(404, {'error': 'Endpoint not found'})
            return

        try:
            with SENSOR_READ_LOCK:
                temperature = read_temperature(sensor_file)
        except (OSError, ValueError) as error:
            self.log_error('Temperature read failed: %s', error)
            self.send_json(503, {'error': 'Temperature sensor unavailable'})
            return

        self.send_json(200, temperature)

    def send_json(self, status, data):
        body = json.dumps(data).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(body)


def main():
    parser = argparse.ArgumentParser(description='Serve DS18B20 temperature readings over HTTP.')
    parser.add_argument('--host', default='127.0.0.1', help='Address to listen on')
    parser.add_argument('--port', type=int, default=8000, help='Port to listen on')
    parser.add_argument('--sensor-file', type=Path, help='Path to a specific w1_slave file')
    args = parser.parse_args()

    named_sensor_files = {}
    for path, variable in SENSOR_ENV.items():
        sensor_id = os.environ.get(variable, '').strip()
        if not sensor_id:
            continue
        if not re.fullmatch(r'28-[0-9a-f]{12}', sensor_id):
            parser.error(f'{variable} must be a 28- sensor ID with 12 lowercase hex digits')
        named_sensor_files[path] = SENSOR_DIR / sensor_id / 'w1_slave'

    handler = partial(
        TemperatureHandler,
        sensor_file=args.sensor_file,
        named_sensor_files=named_sensor_files,
    )
    with ThreadingHTTPServer((args.host, args.port), handler) as server:
        print(f'Listening on http://{args.host}:{server.server_port}/temperature')
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == '__main__':
    main()
