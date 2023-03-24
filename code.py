import busio
from microcontroller import pin
from digitalio import DigitalInOut, Direction
import json

from vl53l5cx import DATA_TARGET_STATUS, DATA_DISTANCE_MM
from vl53l5cx import STATUS_VALID, RESOLUTION_4X4
from vl53l5cx.cp import VL53L5CXCP

scl_pin, sda_pin, lpn_pin, _ = (pin.GPIO1, pin.GPIO0, pin.GPIO28, pin.GPIO5)
i2c = busio.I2C(scl_pin, sda_pin, frequency=1_000_000)

uart = busio.UART(pin.GPIO12, pin.GPIO13, baudrate=9600)

lpn = DigitalInOut(lpn_pin)
lpn.direction = Direction.OUTPUT
lpn.value = True

tof = VL53L5CXCP(i2c, lpn=lpn)

tof.init()
tof.resolution = RESOLUTION_4X4
grid = 3

tof.ranging_freq = 10

tof.start_ranging({DATA_DISTANCE_MM, DATA_TARGET_STATUS})

while True:
    if tof.check_data_ready():
        results = tof.get_ranging_data()
        distance = results.distance_mm
        status = results.target_status
        
        status_is_valid = list(map(lambda x: x == STATUS_VALID, status))
        
        data = {
            'distance': distance,
            'status': status_is_valid
        }
        
        output = json.dumps(data)
        
        #print(output)
        #uart.write(bytes("test" + "\r\n", 'ascii'))
        print(output)
        uart.write(bytes(output + "\r\n", 'ascii'))

