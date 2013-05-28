function PhasorReport(time, CS, activity, Title, savePath)
%PHASORREPORT Generates graphical summary of CS and Activity

%% Process and analyze data
% Trim data to length of experiment
TI = time - time(1); % time index in days from start
days = floor(max(TI));
delta = find(TI <= days); % indices of data to keep
time = time(delta);
TI = TI(delta);
activity = activity(delta);
CS = CS(delta);

Srate = 1/((time(2)-time(1))*(24*3600)); % sample rate in Hertz
% Calculate inter daily stability and variablity
[IS,IV] = IS_IVcalc(activity,1/Srate);

% Apply gaussian filter to data
CS = gaussian(CS, 4);
activity = gaussian(activity, 4);
% Calculate phasors
[phasorMagnitude, phasorAngle] = cos24(CS, activity, time);
[f24H,f24] = phasor24Harmonics(CS,activity,Srate); % f24H returns all the harmonics of the 24-hour rhythm (as complex numbers)
MagH = sqrt(sum((abs(f24H).^2))); % the magnitude including all the harmonics

%% Create figure
figure1 = figure(1);
paperPosition = [0 0 11 8.5];
set(figure1,'PaperUnits','inches',...
    'PaperType','usletter',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperPosition',paperPosition,...
    'Units','inches',...
    'Position',paperPosition);

%% Set spacing values
xMargin = 0.5/paperPosition(3);
xSpace = 0.125/paperPosition(3);
yMargin = 0.5/paperPosition(4);
ySpace = 0.125/paperPosition(4);

%% Create title
titleHandle = annotation(figure1,'textbox',...
    [0.5,1-yMargin,0.1,0.1],...
    'String',Title,...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'LineStyle','none',...
    'FontSize',14);
% Center the title and shift down
titlePosition = get(titleHandle,'Position');
titlePosition(1) = 0.5-titlePosition(3)/2;
titlePosition(2) = 1-yMargin-titlePosition(4);
set(titleHandle,'Position',titlePosition);

%% Create date stamp
dateStamp = ['Printed: ',datestr(now,'mmm. dd, yyyy HH:MM')];
datePosition = [0.8,1-yMargin,0.1,0.1];
dateHandle = annotation(figure1,'textbox',datePosition,...
    'String',dateStamp,...
    'FitBoxToText','on',...
    'HorizontalAlignment','right',...
    'LineStyle','none');
% Shift left and down
datePosition = get(dateHandle,'Position');
datePosition(1) = 1-xMargin-datePosition(3);
datePosition(2) = 1-yMargin-datePosition(4); 
set(dateHandle,'Position',datePosition);
%% Calculate usable space for plots
workHeight = titlePosition(2)-ySpace-yMargin;
workWidth = 1-2*xMargin;

%% Panel 1 Activity and CS
% Set position values
x1 = xMargin; % half an inch from the edge
w1 = 1-2*xMargin; % width fot half inch margins
h1 = workHeight/3-ySpace/2; % half of top half with spacing
y1 = workHeight+yMargin-h1;
% Create plot
axes1 = axes('Parent',figure1,'OuterPosition',[x1 y1 w1 h1]);
hold(axes1);
set(axes1,'Box','off','TickDir','out');
area1 = area(axes1,TI,activity);
set(area1,'FaceColor',[.2 .2 .2],'EdgeColor','none','DisplayName','Activity');
plot1 = plot(axes1,TI,CS);
set(plot1,'Color',[.6 .6 .6],'LineWidth',2,'DisplayName','Circadian Stimulus');
xlim(axes1,[0 days]);
set(axes1,'xtick',0:1:days);
ymax = ceil(max([max(activity),max(CS)])/.5)*.5;
ylim(axes1,[0 ymax]);
legend(axes1,'Location','NorthOutside','Orientation','horizontal');

%% Panel 2 Phasors
h2 = 2*workHeight/3-ySpace/2;
y2 = yMargin;
w2 = h1*paperPosition(3)/paperPosition(4);
x2 = x1+w2/4;
%   Plot phasors
axes('Parent',figure1,'OuterPosition',[x2 y2 w2 h2]);
phasorplot(phasorMagnitude,phasorAngle,.75,3,6,'top','left',.1);
title(gca,'CS/Activity Phasor');

%% Panel 3 Text annotations
h3 = h2;
y3 = y2;
w3 = (workWidth-xSpace)/2;
x3 = xMargin+w3;
notes = cell(9,1);
notes{1} = ['Phasor Magnitude: ', num2str(phasorMagnitude, '%.2f')];
notes{2} = ['Phasor Angle: ', num2str(phasorAngle, '%.2f'), ' hours'];
notes{3} = ' ';
notes{4} = ['IS: ', num2str(IS, '%.2f')];
notes{5} = ['IV: ', num2str(IV, '%.2f')];
notes{6} = ' ';
notes{7} = ['Average CS: ', num2str(mean(CS), '%.2f')];
notes{8} = ['Mag w/ harmonics: ' num2str(MagH,'%.3f')];
notes{9} = ['Mag 1st harmonic: ' num2str(abs(f24),'%.3f')];
text3 = annotation(figure1,'textbox', [x3 y3 w3 h3], 'String',notes);
set(text3,'EdgeColor','none','HorizontalAlignment','left',...
    'VerticalAlignment','middle','FontSize',14);

%[savePath, Title, '.fig']
saveas( gcf, [savePath, '\', Title, '.pdf'] );
clf(1);
end
