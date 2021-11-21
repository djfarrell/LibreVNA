# testvna.m
# Uses librevna.m

# Note, librevna.m must be in the path.
source("librevna.m");

p = vna_connect();

max_sweep_bytes = (65536*3);

idn_resp = read_cmmd_resp_str(p,"*IDN?\n");
vna_rev = read_cmmd_resp_str(p,":DEV:INF:FWREV?\n");
vna_sn = read_cmmd_resp_str(p,":DEV:CONN?\n");

calibration_filename = "TEST.cal"

# Set up the scan corresponding to test.cal used
wrt_cmmd(p,":DEV:MODE VNA\n");
wrt_cmmd(p,":VNA:SWEEP FREQUENCY\n")
wrt_cmmd(p,":VNA:STIM:LVL -10\n");
wrt_cmmd(p,":VNA:ACQ:IFBW 1000\n");
wrt_cmmd(p,":VNA:ACQ:AVG 1\n");

acq_points = 501;
wrt_cmmd_value(p,":VNA:ACQ:POINTS", acq_points);

fmin=100E3;
wrt_cmmd_value(p,":VNA:FREQuency:START", fmin);

fmax = 6000E6;
wrt_cmmd_value(p,":VNA:FREQuency:STOP", fmax);

# Load a SOLT cal and enable cal mode.
wrt_cmmd_resp_true(p,[":VNA:CALibration:LOAD? ",calibration_filename,"\n"]);

# wait and read the sweep, return freq and complex measurements.
[f,Z] = read_sweep(p,max_sweep_bytes);

vna_disconnect(p);



# Plot mag (in dB) and phase (in degrees)
subplot(4,1,1);
plot(f,20*log10(abs(Z))); # dB
axis([-Inf,Inf, -Inf, Inf]);
xlabel ("Frequency");
ylabel ("S11 DB");
axis([-Inf,Inf,-Inf,Inf]);

# Phase in degrees
subplot(4,1,2);
plot(f,180/pi*angle(Z));
xlabel ("Frequency");
ylabel ("S11 (deg)");
axis([-Inf,Inf,-180,180]);

# Z Im vs Re, zoom in 10x to check noise.
subplot(4,1,3);
plot(Z,"+"); # plot with '+' since dot is so small.
xlabel ("Zre");
ylabel ("Zim");
pscale = 1.0; # Allow zoom in to 50 ohm point to check noise, normally 1.0
axis([-pscale,pscale,-pscale,pscale],"square");

# TDR
tstep = 1E9/fmax; # scl in ns
X = tstep*(1:acq_points/2);  # time scale
Y = ifft(Z);

subplot(4,1,4);
#plot(X, 20*log10(abs(Y(1:acq_points/2))));  # dB mag
plot(X, real(Y(1:acq_points/2)));  # dB mag