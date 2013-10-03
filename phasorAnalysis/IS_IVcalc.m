function [IS,IV] = IS_IVcalc(A,dt)
% Returns the interdaily stability (IS) and the
% intradaily variability (IV) statistic for time series A.
% A is a column vector and must be in equal time increments
% given by scalar dt in units of seconds.
% Converts data to hourly increments before calculating metric.

N = length(A);
if (N < 24 || N*dt < 24*3600)
    error('Cannot compute statistic because time series is less than 24 hours');
end
if dt>3600
    error('Cannot compute statistic becasue time increment is larger than one hour');
end
dthours = dt/3600;
if (rem(1/dthours,1) > eps)
    warning('dt does not divide into an hour without a remainder');
end
% Convert to hourly data increments
Ahourly = zeros(floor(N*dthours),1);
for i = 1:floor(N*dthours) % 1 to the number of hours of data
    %Ahourly(i) = sum(A((i-1)*1*60+1:i*1*60))/(1*60);
    Ahourly(i) = meanExcludeNaN(A(floor((i-1)/dthours+1):floor(i/dthours)));
end

p = 24; % period in hours
Ap = EnrightPeriodogramMean(Ahourly,p);
IS = Ap^2/var(Ahourly,1);
AhourlyMean = mean(Ahourly);
IV = (sum(diff(Ahourly).^2)/(length(Ahourly)-1))/(sum((Ahourly-AhourlyMean).^2)/length(Ahourly));