function [magnitude, angle] = cos24(x, y, time)
%cos24 returns the 24 hour phasor using x and y
%x is one data set
%y is the other data set
%time is the common timestamps (in days) for the signals
%magnitude is the phasor magnitude
%angle is the phasor angle in hours

%per equals the number of seconds per sample
%per = 1/srate

%tot equals the total number of days of data
%tot = (per*length(x))/86400;

%time = (0:(per/86400):(tot - per/86400))';

%fits the signals using a 24 hour cosine curve
[Mx, Ax, phix] = cosinorFit( time, x, 1, 1 );
[My, Ay, phiy] = cosinorFit( time, y, 1, 1 );

%angle is just the difference in phases
angle = (phix - phiy)/(2*pi);

%pshift is the number of points to shift so that the signals line up
pshift = angle/(time(2) - time(1));

%shift one signal so that they overlap
y = circshift(y, round(pshift));

fitx = Mx + Ax*cos(2*pi*time + phix);
fity = My + Ay*cos(2*pi*time + phiy);

%magnitude is just the normalized cross covariance (from wikipedia)
%magnitude = (.5*Ax*Ay)/(std(x)*std(y))
magnitude = (std(fitx)*std(fity))/(std(x)*std(y));

angle = angle*24;

if(angle > 12)
    angle = angle - 24;
end
if(angle < -12)
    angle = angle + 24;
end