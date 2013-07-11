function [dtime, lux, CLA, CS, activity, temp, x, y] = dimedata(filepath, dimeSN, dstart, dstop)


%process organized file
[dtime, lux, CLA, activity, temp, x, y] = process_raw_dime_09Aug2011(filepath, ...
																	 dimeSN);

dtime = dtime/(3600*24)+6.954217798611112e+005;
dtime = dtime + 18/1440;

CS = CSCalc_postBerlin_12Aug2011(CLA);

q = find((dtime >= dstart) & (dtime <= dstop));
dtime = dtime(q);
lux = lux(q);
CLA = CLA(q);
activity = activity(q);
CS = CS(q);
temp = temp(q);
x = x(q);
y = y(q);
end