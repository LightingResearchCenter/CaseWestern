function [dTime, CS, AI] = importDime(filepath, dimeSN)


%process organized file
[dTime, ~, CLA, AI, ~, ~, ~] =...
    process_raw_dime_09Aug2011(filepath, dimeSN);

dTime = dTime/(3600*24)+6.954217798611112e+005;
dTime = dTime + 18/1440;

CS = CSCalc_postBerlin_12Aug2011(CLA);

end