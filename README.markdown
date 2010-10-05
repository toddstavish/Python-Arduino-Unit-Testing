Python Arduino Unit Testing
=========================================================

Uses python to dynamically load hex images of Arduino code for unit testing. 

We are using Arduino boards for data acquisition in a large scientific experiment. Subsequently, we have to support several Arduino boards with different implementations. I wrote python utilities to dynamically load Arduino hex images during unit testing. This code supports Windows and OSX via configuration file. To find out where your hex images are placed by the Arduino IDE (as well as your board specific build flags), hit the shift key before you hit the build (play) button. Hit the shift while hitting upload to find out where your avrdude (command line upload utility) is located on your system / version of Arduino. Alternatively, you can look at the included config files and use your install location (currently on Arduino 0020).