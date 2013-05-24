function [time, lux, CLA, activity, temp,x , y] = selectDays(starttime, endtime, time, lux, CLA, activity, temp, x, y, crop_start, crop_end)

starttime = datenum(starttime);
endtime = datenum(endtime);

if (crop_start ~= 0)
	z = find((time >= starttime) & (time <= endtime) & ((time <= crop_start) | (time >= crop_end)));
%else
%	z = find((time >= starttime) & (time <= endtime));


time = time(z);
lux = lux(z);
CLA = CLA(z);
activity = activity(z);
temp = temp(z);
x = x(z);
y = y(z);
end


