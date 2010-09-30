import os
import time
import struct
import binascii
import glob
import db
import platform
from serial import Serial
from configobj import ConfigObj

class SerialPort(object):
        
        
    def __init__(self, configFile):
        """Takes the string name of the serial port
        (e.g. "/dev/tty.usbserial","COM1") and a baud rate (bps) and
        connects to that port at that speed.
        """
        serialport = usbserial_path()
        self.config = ConfigObj(configFile)
        serial = self.config['serial']
        baudrate = serial['baudrate']
        self.serial = Serial(serialport, baudrate, timeout=1)
        

    def read_line(self):
        """Reads the serial buffer"""
        return self.serial.readline()
    
 
    def read_until(self, until):
        """Reads the serial buffer *until* times"""
        buf = ""
        n = 0
        done = True
        while done:
            line = self.serial.readline()
            if line == '':
                time.sleep(0.01)
                continue
            buf = buf + line
            n += 1
            if n == until:
                done = False
        return buf
    

    def write(self, data):
        """Writes *data* string to serial"""
        self.serial.write(data)
    

    def request_data(self):
        """Reads analog pins"""
        while True:
            self.write(chr(87)) 
            line = self.read_line()
            if line:
                return line
                #values = line.split('*')
                #data = dict(
                #        count = values[1],
                #        time = values[2],
                #        analog1 = values[3],
                #        analog2 = values[4],
                #        analog3 = values[5],
                #        analog4 = values[6],
                #    )

    
    
    def request_details(self, event_def):
        """Reads event data"""
        while True:
            self.write(chr(88)) 
            line = self.read_line()
            if line:
                values = line.split(',')
                data = {}
                for key, (index, value) in event_def.items(): 
                    data[key] =  values[index]
                return data
    

    def start_trial(self, parameters):
        """Sends start command"""
        parameters.pop("trialNumber")
        values = parameters.values()
        values.sort()
        while True:
            self.write(chr(90))
            for index, format, value in values:
                self.write(pack_integer(format, value))               
            accepted = self.read_line()
            if accepted:
                return accepted;
    

    def end_trial(self):
        """Sends end command"""
        while True:
            self.write(chr(89))             
            accepted = self.read_line()
            if accepted:
                return accepted;


    def request_protocol_name(self):
        """Get protocal name from arduino (gives the name of the code that is running)"""
        while True:
            self.write(chr(91))            
            line = self.read_line()
            if line:
                values = line.split(',')
                return values[1]
    
                                                              
    def upload_code(self, hex_path):
        """Upload code to the arduino"""
        self.serial.close()
        avr = self.config['avr']
        command = avr['command']
        conf = avr['conf']        
        verbosity = avr['verbosity']
        flags = avr['flags']
        arduino_upload_cmd = command \
                            + " -C" + conf \
                            + " " + verbosity \
                            + " " + flags \
                            + " -P" + self.serial.name \
                            + " -Uflash:w:" + hex_path + ":i"
        os.system(arduino_upload_cmd)
        self.serial.open()
    
                                               
    def close(self):
        """Closes the serial connection"""
        self.serial.close()
    

def pack_integer(format, value):
    """Packs integer as a binary string
       I = python 4 byte unsigned integer to an arduino unsigned long
       h = python 2 byte short to an arduino integer
    """
    return struct.pack(format, value)


def usbserial_path():
    """Returns the first connected USB serial device."""
    
    #Windows
    if platform.win32_ver()[0] != '':
        return "COM3"
    
    # Unix/OS X
    available = glob.glob('/dev/tty.usbserial*')
    
    if len(available) == 0:
        raise IOError("Unable to find a tty.usbserial device.")
    
    return available[0]


