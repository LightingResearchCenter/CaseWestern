function [dtime, lux, CLA, CS, activity, temp, x, y] = dimedata(num, txt, s, numdays)

dsub = num(:,1);
dint = num(:,2);
daim = num(:,3);
dime = num(:,6);

dstart = datenum((txt(2:end,5)));
dstop = datenum(dstart)+7;
dquality = char(txt(2:end,4));
dfile = char(txt(2:end,8));

%wakethresh = 0.2

for j = s
    
     savefile = dfile(j,:);
%     %test for removal
% %     %put raw file in matlab format if needed
% %     marker = 0;
% %     rawfile = dfile(s,:);
% %     for i = 1:length(rawfile)
% %         if(rawfile(i:i + 3) == '.txt')
% %             marker = i;
% %             break;
% %         end
% %     end
% %     savefile = [rawfile(1:marker - 1), '_matlab.txt'];
% %     if(~exist(savefile, 'file'))
% %        organize_raw_dimesimeter_file_test(rawfile, savefile);
% %     end
    
    %process organized file
    [dtime, lux, CLA, activity, temp, x, y] = process_raw_dime_09Aug2011(savefile, dime(s));
    
    dtime = dtime/(3600*24)+6.954217798611112e+005;
    dtime = dtime + 18/1440;
    
    CS = CSCalc_postBerlin_12Aug2011(CLA);
    
    q = find((dtime >= dstart(s)) & (dtime <= dstop(s)));
    dtime = dtime(q);
    lux = lux(q);
    CLA = CLA(q);
    activity = activity(q);
    CS = CS(q);
    temp = temp(q);
    x = x(q);
    y = y(q);
end