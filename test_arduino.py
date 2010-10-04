from unittest import TestCase
from configobj import ConfigObj
from os import environ
import voyeur.arduino as arduino
import voyeur.db as db


class TestSerial(TestCase):
    """Tests writes / reads over serial to / from controller"""
 
           
    def setUp(self):
        self.protocol = "AcceptanceCode"
        configFile = environ.get("VOYEUR_CONFIG")
        self.port = arduino.SerialPort(configFile)
        config = ConfigObj(configFile)
        self.pde_hex_path = config['test']['iteration1']['hex_path']
        if self.port.request_protocol_name() != self.protocol:
            self.port.upload_code(self.pde_hex_path)


    def tearDown(self):
        self.port.close()


    def test_protocol_name(self):
        """Tests to see if arduino hardware has the correct code (pde) loaded for this test suite"""
        name = self.port.request_protocol_name()
        self.assertEqual(self.protocol, name)
 
        
    def test_start_trial(self):
        """Testing command to start trial, passes parameters, cotroller passes back first parameter for check"""
        check = 25000
        parameters = {
            "trialNumber"        : (1, db.Int, 1),
            "interTrialInterval" : (2, db.Int, check),
            "stimDelay"          : (3, db.Int, 500),
            "stimDuration"       : (4, db.Int, 500),
            "xCenter"            : (5, db.Int16, 0),
            "xWidth"             : (6, db.Int16, 20),
            "yCenter"            : (7, db.Int16, 0),
            "yWidth"             : (8, db.Int16, 20),
            "valveOpenTime"      : (9, db.Int, 30),
            "valveDelayTime"     : (10, db.Int, 1000),
            "responseMode"       : (11, db.Int16, 0)
            }
        val = self.port.start_trial(parameters)
        self.assertEqual(int(val), check)


    def test_end_trial(self):
        """Testing command to end trial, tests for controller to pass back end code"""
        val = self.port.end_trial()
        self.assertEqual(val, "3,*")
        
    def test_conversion(self):
        correct = {
            "trialNumber" : (1, 'I', 1),
            "testValue1"  : (2, 'h', 7),
            "testValue2"  : (3, 'h', 5),
            "testValue3"  : (4, 'I', 5),            
            }
        parameters = {
                "trialNumber" : (1, db.Int, 1),
                "testValue1"  : (2, db.Int16, 7),
                "testValue2"  : (3, db.Int16, 5),
                "testValue3"  : (4, db.Int, 5),            
            }
        params_orig = parameters.copy()
        new = arduino.convert_format(parameters)
        self.assertEqual(params_orig, parameters)
        self.assertEqual(correct, new)
        
