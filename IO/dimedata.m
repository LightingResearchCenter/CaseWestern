function [dtime, lux, CLA, CS, activity, temp, x, y] = dimedata(num, txt, s, dstart, dstop)

dsub = num(:,1);
dint = num(:,2);
daim = num(:,3);
dime = num(:,6);

dquality = char(txt(2:end,4));
dfile = char(txt(2:end,8));

savefile = dfile(s,:);
%process organized file
[dtime, lux, CLA, activity, temp, x, y] = process_raw_dime_09Aug2011(savefile, dime(s));

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