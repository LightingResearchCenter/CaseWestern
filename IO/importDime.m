function [dTime,lux,CLA,CS,AI] = importDime(filepath, dimeSN)


%process organized file
[time1,lux,CLA,AI,~,~,~] = process_raw_dime_09Aug2011(filepath, dimeSN);

% Convert time to MATLAB datenum
dTime = (time1/(3600*24)+6.954217798611112e+005) + 18/1440;

% Calculate CS
CS = CSCalc_postBerlin_12Aug2011(CLA);

end