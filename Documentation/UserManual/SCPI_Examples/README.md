# SCPI Programming Examples
This directory contains some basic examples, demonstrating the scripting capabilities of the LibreVNA using the SCPI interface. They are only intended as a starting point, for the complete list of available commands see the [SCPI Programming Guide](../ProgrammingGuide.pdf).

## How to run the examples
1. Connect the LibreVNA to your computer
2. Start the LibreVNA-GUI and make sure that the SCPI server is enabled (Window->Preferences->General). The examples use the default port (19542).
3. Use python3 to run an example


## Octave example using Ubuntu 18, Octave 4..2.2
1. Have LibreVNA running with S11 available.
2. Install instrument-control package for Octave.
3. Run Octave, be sure test_vna.m and librevna.m are in the Octave path.
4. In testvna.m adjust the calibration_filename or comment out the Calibration:LOAD? line. 
5. I have run with the libreVNA supplied cable on port 1 with an open end.  See SampleWTDR.pdf.

