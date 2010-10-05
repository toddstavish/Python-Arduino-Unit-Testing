from unittest import TestCase
from configobj import ConfigObj
from os import environ
from timeit import Timer
import voyeur.arduino as arduino


class TestAnalogSpeed(TestCase):
    """Tests writes / reads over serial to / from controller"""
 
 
    def setUp(self):
        self.protocol = "Continuous"
        configFile = environ.get("VOYEUR_CONFIG")
        self.port = arduino.SerialPort(configFile)
        config = ConfigObj(configFile)
        self.pde_hex_path = config['test']['analog_read']['hex_path']
        

    def tearDown(self):
        self.port.close()


    def test_time_read_line(self):
        """Test to see if continuous read of analog data is less than two secounds per call"""
        self.port.upload_code(self.pde_hex_path)
        t = Timer(lambda: self.port.read_line())
        time = t.timeit(1)
        print time
        self.assert_(time < 2)


    def test_time_analog_read(self):
        """Test the time of reading four analog pins"""
        self.port.upload_code(self.pde_hex_path)
        while True:
            self.port.write(' ')             
            line = self.port.read_line()
            if line:
                print line
                values = line.split(',')
                self.assert_(int(values[1])-int(values[0]) < 100)
                break
        

