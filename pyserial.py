import datetime
import time

import serial

ser = serial.Serial("COM9", 115200)  # change COM port

while True:
    now = datetime.datetime.now()
    msg = now.strftime("%H%M%S\n")  # e.g. "142530\n"
    ser.write(msg.encode("ascii"))
    time.sleep(1)  # send every second, or only once when you start
