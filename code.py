import busio
from microcontroller import pin
from digitalio import DigitalInOut, Direction
import json
import time

from vl53l5cx import DATA_TARGET_STATUS, DATA_DISTANCE_MM
from vl53l5cx import STATUS_VALID, RESOLUTION_4X4
from vl53l5cx.cp import VL53L5CXCP

scl_pin, sda_pin, lpn_pin = (pin.GPIO1, pin.GPIO0, pin.GPIO28)
i2c = busio.I2C(scl_pin, sda_pin, frequency=1_000_000)

scl2_pin, sda2_pin, lpn2_pin = (pin.GPIO3, pin.GPIO2, pin.GPIO27)
i2c2 = busio.I2C(scl2_pin, sda2_pin, frequency=1_000_000)

uart = busio.UART(pin.GPIO12, pin.GPIO13, baudrate=9600)

lpn = DigitalInOut(lpn_pin)
lpn.direction = Direction.OUTPUT
lpn.value = True

lpn2 = DigitalInOut(lpn2_pin)
lpn2.direction = Direction.OUTPUT
lpn2.value = True

tof = VL53L5CXCP(i2c, lpn=lpn)
tof2 = VL53L5CXCP(i2c2, lpn=lpn2)

grid = 3

tof.init()
tof.resolution = RESOLUTION_4X4
tof.ranging_freq = 100
tof.start_ranging({DATA_DISTANCE_MM, DATA_TARGET_STATUS})

tof2.init()
tof2.resolution = RESOLUTION_4X4
tof2.ranging_freq = 100
tof2.start_ranging({DATA_DISTANCE_MM, DATA_TARGET_STATUS})

def get_tof_data(sensor):
    while not sensor.check_data_ready():
        time.sleep(0.01)
    
    results = sensor.get_ranging_data()
    distance = results.distance_mm
    status = results.target_status
    
    status_is_valid = list(map(lambda x: x == STATUS_VALID, status))
        
    data = {
        'distance': distance,
        'status': status_is_valid
    }
    
    return data

while True:
    tof1data = get_tof_data(tof)
    tof2data = get_tof_data(tof2)
    
    data = {
        'a': tof1data,
        'b': tof2data
    }
    output = json.dumps(data)
        
    print(output)
    uart.write(bytes(output + "\r\n", 'ascii')) 

