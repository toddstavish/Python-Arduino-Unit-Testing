from unittest import TestCase
from configobj import ConfigObj
from os import environ
from timeit import Timer
import voyeur.arduino as arduino


class TestSerial(TestCase):
    """Tests writes / reads over serial to / from controller"""
 
 
    def setUp(self):
        self.protocol = "Continuous"
        configFile = environ.get("VOYEUR_CONFIG")
        self.port = arduino.SerialPort(configFile)
        config = ConfigObj(configFile)
        pde_hex_path = config['test']['continuous']['hex_path']
        if self.port.request_protocol_name() != self.protocol:
            self.port.upload_code(pde_hex_path)


    def tearDown(self):
        self.port.close()


    def test_protocol_name(self):
        """Tests to see if arduino hardware has the correct code (pde) loaded for this test suite"""
        name = self.port.request_protocol_name()
        self.assertEqual(self.protocol, name)
 

    def test_time_request_data(self):
        """Test to see if continuous read of analog data is less than one secound per call"""
        t = Timer("request_data()", "from test_arduino_continuous_ser import request_data")
        time = t.timeit(1)
        print time
        self.assert_(time < 2)

        
    def test_request_data_continuity(self):
        """Test continuous read of analog data for continuity. Check counter and less than 1 millisecond"""
        counter = 1
        for i in range(2):
            data = self.port.request_data()
            values = data.split('*')
            if i == 0:
                last = values[0].split(',')      
            for value in values:
                if value != '':         
                    next = value.split(',')
                    time = int(next[1]) - int(last[1])
                    print time
                    self.assert_(time <= 2000)
                    self.assertEqual(int(next[0]), counter)
                    last = next
                    counter += 1


def request_data():
    configFile = environ.get("VOYEUR_CONFIG")
    port = arduino.SerialPort(configFile)    
    port.request_data()