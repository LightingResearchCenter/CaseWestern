function SleepState = FindSleepState(Activity,Threshold)
%SLEEPSTATE Calculate sleep state using LRC simple method

% Make Activity array vertical if not already
Activity = Activity(:);

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

