
# librevna.m
# Octave (Matlab) example by djfarrell for LibreVNA
# see test_vna. for use.

1; # script file

pkg load instrument-control

function p = vna_connect()
p = tcp("127.0.0.1", 19542);
#my_vna_sn = "000000000000";
#wrt_cmmd([":DEV:CONN ", my_vna_sn, "\n"]);
endfunction

function vna_disconnect(p)
clear p;
endfunction

global rdly = 50;
global rsize = 8;
global ldpause = 1.0;
global swdly = 500; # 500 is good for 501 and 1000Hz bw

#calibration_filename = "TEST.cal"
#max_sweep_bytes = (65536*3);

# Write a string, get a string.
function resp = read_cmmd_resp_str(p,s)
  global rdly;
  x = tcp_write(p,s);
  val = tcp_read(p, 32, rdly); # attempt to read 32 bytes;
  resp = char(val);
endfunction
 
# Basic write with LF reponse (or ERROR)
function wrt_cmmd(p,s)
  global rdly;
  global rsize;
  x = tcp_write(p,s);
  pause(0.1);
  x = tcp_read(p, rsize, rdly);
  if(x(1) != 10)
    printf("Bad response: %s for %s", char(x), s);
    return;
  end
endfunction

# Command with a value, needs special space handling.
function wrt_cmmd_value(p,s,v)
  global rdly;
  global rsize;
  
  # Odd concat which preserves trailing spaces.
  tmp = [s ' ' num2str(v)  "\n"];
  tcp_write(p,tmp);
  
  pause(0.1);
  x = tcp_read(p, rsize, rdly);
  if(x(1) != 10)
    printf("Bad response: %s for %s", char(x), s);
    return;
  end
endfunction

# Write expects a "TRUE" response
function wrt_cmmd_resp_true(p,s)
  global rdly;
  global rsize;
  global ldpause;
  tcp_write(p,s);
  pause(ldpause);
  x = tcp_read(p, rsize, rdly); # TRUE or FALSE
  char(x);
  if(char(x) != "TRUE\n")
    printf("Bad response: %s for %s", char(x), s);
    return
  end
endfunction

# Read sweep, return frequency and complex data, up to npt bytes in length.
function [f,Z] = read_sweep(p,npt)
  global rdly;
  global rsize;
  global swdly;
  
  # Wait for sweep
  do
    tcp_write(p,":VNA:ACQ:FIN?\n");
    pause(0.10);
    x = tcp_read(p, rsize, swdly); # TRUE or FALSE
  until (x(1) == 84) # T of True

  # 64k read size easily fits 501 points.
  data = tcp_write(p,":VNA:TRACE:DATA? S11\n");
  v1 = tcp_read(p, npt, 500); #64K ok for 2001, 192K for 4501(max) points
  n = str2num(char(v1));
  
  # Parse freq and IQ
  for i=0:(length(n)/3-1)
   f(i+1) = n(1+(i*3)); # freq
   Z(i+1) = n(2+(i*3)) + n(3+(i*3))*j; # complex impedance
  endfor
  
endfunction

