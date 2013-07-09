function [phasorMagnitude,phasorAngle,IS,IV,mCS,MagH,f24abs] = phasorAnalysis(time, CS, activity)
%PHASORANALYSIS Performs analysis on CS and activity

%% Process and analyze data
Srate = 1/((time(2)-time(1))*(24*3600)); % sample rate in Hertz
% Calculate inter daily stability and variablity
[IS,IV] = IS_IVcalc(activity,1/Srate);

% Apply gaussian filter to data
CS = gaussian(CS, 4);
activity = gaussian(activity, 4);

% Calculate phasors
[phasorMagnitude, phasorAngle] = cos24(CS, activity, time);
[f24H,f24] = phasor24Harmonics(CS,activity,Srate); % f24H returns all the harmonics of the 24-hour rhythm (as complex numbers)
MagH = sqrt(sum((abs(f24H).^2))); % the magnitude including all the harmonics

mCS = mean(CS);
f24abs = abs(f24);

end
