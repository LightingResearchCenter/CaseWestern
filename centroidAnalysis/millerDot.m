function [C_time,C_magnitude] = millerDot(time1,CS,AI)
%MILLERDOT Creates a polar plot of CS, activity, and the centroid of CS
%   time1 is an array of either datenum values or in units of days.
%   CS is an array of circadian stimulus values equal in length to time.
%   AI is an array of activity values equal in length to time.

%% Prepare data
% Reshape data into columns of full days
% ASSUMES CONSTANT SAMPLING RATE
TI = time1 - floor(time1(1)); % create a time index in units of days
dayIdx = find(TI >= 1 + TI(1),1,'first') - 1;
extra = rem(length(TI),dayIdx)-1;
CS(end-extra:end) = [];
AI(end-extra:end) = [];
CS = reshape(CS,dayIdx,[]);
AI = reshape(AI,dayIdx,[]);

% Average data across days
mCS = mean(CS,2);
mAI = mean(AI,2);

% Trim time index
TI = TI(1:dayIdx);

% Complete the loop
mCS(end+1) = mCS(1);
mAI(end+1) = mAI(1);
TI(end+1) = TI(1);

% Convert the time index to radians
theta = TI*2*pi;

% Apply Gaussian filter to CS and AI
csFilt = gaussian(mCS, 4);
aiFilt = gaussian(mAI, 4);

%% Calculate the centroid
[C_rho,C_theta] = centroidCSpolar(TI,csFilt);
C_time = C_theta/(2*pi); % Convert radians to datenum
C_time = mod(C_time,1); % Correct for rollover
C_magnitude = C_rho;

%% Plot the data
% Plot AI
millerDotPlot(theta,aiFilt,'-g');
hold(gca,'on');
% Plot CS
millerDotPlot(theta,csFilt,'-b');
% Plot the centroid
millerDotPlot(C_theta,C_rho,'xr');
hold(gca,'off');

%% Plot the legend
legend1 = legend('Activity','CS','CS Centroid');
set(legend1,'Location','SouthOutside','Orientation','horizontal');

end

