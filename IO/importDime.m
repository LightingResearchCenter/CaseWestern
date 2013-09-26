function [csTS, aiTS] = importDime(filepath, dimeSN)


%process organized file
[dtime, ~, CLA, AI, ~, ~, ~] =...
    process_raw_dime_09Aug2011(filepath, dimeSN);

dtime = dtime/(3600*24)+6.954217798611112e+005;
dtime = dtime + 18/1440;

CS = CSCalc_postBerlin_12Aug2011(CLA);

% Convert data to timeseries objects
csTS = timeseries(CS,dtime);
aiTS = timeseries(AI,dtime);

end