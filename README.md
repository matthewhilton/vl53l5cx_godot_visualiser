# vl53l5cx_godot_visualiser

Visualiser for data from https://www.st.com/en/imaging-and-photonics-solutions/vl53l5cx.html using Godot v3

## Requirements
1. Godot V3 Mono https://godotengine.org/
2. Pi Pico with Circuitpython
3. vl53l5cx sensor
4. UART module e.g. FTDI232rl

## How to use
1. Connect sensor to Pi pico or other circuitpython board via I2C
2. Upload library https://github.com/mp-extras/vl53l5cx to device
3. Upload code.py in this repo to the device and run
5. Connect UART module. You should be able to connect using a serial program such as Putty and see the data
6. Open the Godot project
7. Update the Serial node's script to the correct COM port
8. Run the scene. Note - It is scaled down for ease of use (since the vl53l5cx can read over 4 metres this is massive in Godot)