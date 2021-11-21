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

fmin=1E6;
wrt_cmmd_value(p,":VNA:FREQuency:START", fmin);

fmax = 6000E6;
wrt_cmmd_value(p,":VNA:FREQuency:STOP", fmax);

# Load a SOLT cal and enable cal mode.
wrt_cmmd_resp_true(p,[":VNA:CALibration:LOAD? ",calibration_filename,"\n"]);

# wait and read the sweep, return freq and complex measurements.
[f,Z] = read_sweep(p,max_sweep_bytes);

vna_disconnect(p);

# Plot trace width
linewidth=1.5;
fontsize=12;

# Plot mag (in dB) and phase (in degrees)
figure(1);
subplot(3,1,1);
plot(f,20*log10(abs(Z)),"linewidth", linewidth); # dB
axis([-Inf,Inf, -Inf, Inf]);
xlabel ("Frequency","fontsize",fontsize);
ylabel ("S11 dB","fontsize",fontsize);
axis([-Inf,Inf,-Inf,Inf]);
title ("S11 Mag","fontsize",fontsize+2);
grid on;

# Phase in degrees
subplot(3,1,2);
plot(f,180/pi*angle(Z),"linewidth", linewidth);
xlabel ("Frequency","fontsize",fontsize);
ylabel ("S11 (deg)","fontsize",fontsize);
axis([-Inf,Inf,-180,180]);
title ("S11 Phase","fontsize",fontsize+2);
grid on;

# Z Im vs Re, zoom in 10x to check noise.
subplot(3,1,3);
plot(Z,"linewidth", linewidth); # plot with '+' since dot is so small.

xlabel ("Zre","fontsize",fontsize);
ylabel ("Zim","fontsize",fontsize);
pscale = 1.0; # Allow zoom in to 50 ohm point to check noise, normally 1.0
axis([-pscale,pscale,-pscale,pscale],"square");
title ("Polar","fontsize",fontsize+2);
grid on;

figure(2);
# TDR
tstep = 1E9/fmax; # scl in ns
X = tstep*(1:acq_points/2);  # time scale
Y = ifft(Z);
subplot(1,1,1);
plot(X, 20*log10(abs(Y(1:acq_points/2))),"linewidth", linewidth);  # dB mag
#plot(X, real(Y(1:acq_points/2)), "linewidth", linewidth);
#plot(X, imag(Y(1:acq_points/2)), "linewidth", linewidth);
#plot(X,(180/pi)*angle(Y(1:acq_points/2)),"linewidth", linewidth);
title ("TDR","fontsize",fontsize+2);
xlabel ("ns","fontsize",fontsize);
ylabel ("dB","fontsize",fontsize);
grid on;
grid minor on;