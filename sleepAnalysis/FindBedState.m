function BedState = FindBedState(Activity,Threshold)
%FINDBEDSTATE Calculate sleep state using LRC simple method

% Make Activity array vertical if not already
Activity = Activity(:);

maxAI = max(Activity);

% Calculate Bed State 1 = in bed 0 = not in bed
n = numel(Activity); %Find the number of data points
BedState = zeros(1,n); % Preallocate SleepState
for i = 1:n
    if Activity(i) <= Threshold*maxAI
        BedState(i) = 1;
    else
        BedState(i) = 0;
    end
end % End of calculate sleep state


end

