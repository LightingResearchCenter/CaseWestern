function SleepState = FindSleepState(Activity,Threshold,epoch)
%SLEEPSTATE Calculate sleep state using LRC simple method

% Set Threshold value
if strcmpi(Threshold,'auto')
    Threshold = mean(Activity)*0.888/epoch;
end

% Make Activity array vertical if not already
[y,x] = size(Activity);
if x > y % The array is horizontal
    Activity = Activity';
end % The array is vertical

% Calculate Sleep State 1 = sleeping 0 = not sleeping
n = numel(Activity); %Find the number of data points
SleepState = zeros(1,n); % Preallocate SleepState
for i = 1:n
    if Activity(i) <= Threshold
        SleepState(i) = 1;
    else
        SleepState(i) = 0;
    end
end % End of calculate sleep state


end

