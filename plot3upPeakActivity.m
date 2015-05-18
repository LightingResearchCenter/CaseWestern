function plot3upPeakActivity
%PLOT3UPPEAKACTIVITY Summary of this function goes here
%   Detailed explanation goes here

[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);

projectDir = fullfile([filesep,filesep,'root'],'projects',...
    'NIH Alzheimers','CaseWesternData');
analysisDir = fullfile(projectDir,'Analysis');
phasorFilePath = fullfile(analysisDir,'2014-10-01_16-44_peakActivityOutput.mat');

TempStruct = load(phasorFilePath,'output');

peakResults = TempStruct.output;

% Remove empty cells
emptyIdx = cellfun(@isempty,peakResults);
peakResults(emptyIdx) = [];

% Flatten from to one struct
PeakResults = [peakResults{:}];

% Remove excluded subjects
excludeIdx = strcmp({PeakResults.excludeRepeat},'true');
PeakResults(excludeIdx) = [];

% Remove incomplete subjects
incompleteSubjects = [14,23,40,49,66,14.1,23.1,36.1,38.1,39.1,40.1,49.1,59.1,66.1,76.1];
for iSub = 1:numel(incompleteSubjects);
    incompleteIdx = [PeakResults.subject] == incompleteSubjects(iSub);
    PeakResults(incompleteIdx) = [];
end

maxAmp = max([PeakResults.amplitude]);
for i1 = 1:numel(PeakResults)
    PeakResults(i1).amplitude = PeakResults(i1).amplitude/maxAmp;
end

patientIdx = mod([PeakResults.subject],1) == 0;
caregiverIdx = ~patientIdx;

baselineIdx = [PeakResults.week] == 0;
interventionIdx = [PeakResults.week] == 1;
postIdx = [PeakResults.week] == 2;

summerIdx = strcmp({PeakResults.season},'summer');
winterIdx = strcmp({PeakResults.season},'winter');

% Baseline
patientBaselineSummer = PeakResults(patientIdx & baselineIdx & summerIdx);
patientBaselineWinter = PeakResults(patientIdx & baselineIdx & winterIdx);

caregiverBaselineSummer = PeakResults(caregiverIdx & baselineIdx & summerIdx);
caregiverBaselineWinter = PeakResults(caregiverIdx & baselineIdx & winterIdx);

% Intervention
patientInterventionSummer = PeakResults(patientIdx & interventionIdx & summerIdx);
patientInterventionWinter = PeakResults(patientIdx & interventionIdx & winterIdx);

caregiverInterventionSummer = PeakResults(caregiverIdx & interventionIdx & summerIdx);
caregiverInterventionWinter = PeakResults(caregiverIdx & interventionIdx & winterIdx);

% Post Intervention
patientPostSummer = PeakResults(patientIdx & postIdx & summerIdx);
patientPostWinter = PeakResults(patientIdx & postIdx & winterIdx);

caregiverPostSummer = PeakResults(caregiverIdx & postIdx & summerIdx);
caregiverPostWinter = PeakResults(caregiverIdx & postIdx & winterIdx);

%% Patients
% Create figure and axes
[hFigiure,width,height,units] = reports.initializefigure(1,'on');
fSize = get(0,'DefaultAxesFontSize');
set(0,'DefaultAxesFontSize',8);

hSub1 = subplot(2,3,1);
hSub1 = acrophaseaxes(hSub1);
hTitle1 = text(0,1.3,{'ADRD Patients';'Baseline'});
set(hTitle1,'HorizontalAlignment','center');
set(hTitle1,'FontWeight','bold');
set(hTitle1,'FontSize',fSize);

hSub2 = subplot(2,3,2);
hSub2 = acrophaseaxes(hSub2);
hTitle2 = text(0,1.3,{'ADRD Patients';'Intervention'});
set(hTitle2,'HorizontalAlignment','center');
set(hTitle2,'FontWeight','bold');
set(hTitle2,'FontSize',fSize);

hSub3 = subplot(2,3,3);
hSub3 = acrophaseaxes(hSub3);
hTitle3 = text(0,1.3,{'ADRD Patients';'Post Intervention'});
set(hTitle3,'HorizontalAlignment','center');
set(hTitle3,'FontWeight','bold');
set(hTitle3,'FontSize',fSize);


% Plot Baseline
[x,y] = phasor2cart([patientBaselineSummer.amplitude],[patientBaselineSummer.phi]);
hPBS = plot(hSub1,x,y,'ok');
set(hPBS,'MarkerFaceColor','none');
set(hPBS,'MarkerSize',3);
[x,y] = phasor2cart([patientBaselineWinter.amplitude],[patientBaselineWinter.phi]);
hPBW = plot(hSub1,x,y,'ok');
set(hPBW,'MarkerFaceColor','k');
set(hPBW,'MarkerSize',3);

% Plot Intervention
[x,y] = phasor2cart([patientInterventionSummer.amplitude],[patientInterventionSummer.phi]);
hPIS = plot(hSub2,x,y,'ok');
set(hPIS,'MarkerFaceColor','none');
set(hPIS,'MarkerSize',3);
[x,y] = phasor2cart([patientInterventionWinter.amplitude],[patientInterventionWinter.phi]);
hPIW = plot(hSub2,x,y,'ok');
set(hPIW,'MarkerFaceColor','k');
set(hPIW,'MarkerSize',3);

% Plot Post Intervention
[x,y] = phasor2cart([patientPostSummer.amplitude],[patientPostSummer.phi]);
hPPS = plot(hSub3,x,y,'ok');
set(hPPS,'MarkerFaceColor','none');
set(hPPS,'MarkerSize',3);
[x,y] = phasor2cart([patientPostWinter.amplitude],[patientPostWinter.phi]);
hPPW = plot(hSub3,x,y,'ok');
set(hPPW,'MarkerFaceColor','k');
set(hPPW,'MarkerSize',3);


%% Caregivers
% Create figure and axes

hSub4 = subplot(2,3,4);
hSub4 = acrophaseaxes(hSub4);
hTitle4 = text(0,-1.3,{'Caregivers';'Baseline'});
set(hTitle4,'HorizontalAlignment','center');
set(hTitle4,'FontWeight','bold');
set(hTitle4,'FontSize',fSize);

hSub5 = subplot(2,3,5);
hSub5 = acrophaseaxes(hSub5);
hTitle5 = text(0,-1.3,{'Caregivers';'Intervention'});
set(hTitle5,'HorizontalAlignment','center');
set(hTitle5,'FontWeight','bold');
set(hTitle5,'FontSize',fSize);

hSub6 = subplot(2,3,6);
hSub6 = acrophaseaxes(hSub6);
hTitle6 = text(0,-1.3,{'Caregivers';'Post Intervention'});
set(hTitle6,'HorizontalAlignment','center');
set(hTitle6,'FontWeight','bold');
set(hTitle6,'FontSize',fSize);

% Plot Baseline
[x,y] = phasor2cart([caregiverBaselineSummer.amplitude],[caregiverBaselineSummer.phi]);
hCBS = plot(hSub4,x,y,'sk');
set(hCBS,'MarkerFaceColor','none');
set(hCBS,'MarkerSize',3);
[x,y] = phasor2cart([caregiverBaselineWinter.amplitude],[caregiverBaselineWinter.phi]);
hCBW = plot(hSub4,x,y,'sk');
set(hCBW,'MarkerFaceColor','k');
set(hCBW,'MarkerSize',3);

% Plot Intervention
[x,y] = phasor2cart([caregiverInterventionSummer.amplitude],[caregiverInterventionSummer.phi]);
hCIS = plot(hSub5,x,y,'sk');
set(hCIS,'MarkerFaceColor','none');
set(hCIS,'MarkerSize',3);
[x,y] = phasor2cart([caregiverInterventionWinter.amplitude],[caregiverInterventionWinter.phi]);
hCIW = plot(hSub5,x,y,'sk');
set(hCIW,'MarkerFaceColor','k');
set(hCIW,'MarkerSize',3);

% Plot Post Intervention
[x,y] = phasor2cart([caregiverPostSummer.amplitude],[caregiverPostSummer.phi]);
hCPS = plot(hSub6,x,y,'sk');
set(hCPS,'MarkerFaceColor','none');
set(hCPS,'MarkerSize',3);
[x,y] = phasor2cart([caregiverPostWinter.amplitude],[caregiverPostWinter.phi]);
hCPW = plot(hSub6,x,y,'sk');
set(hCPW,'MarkerFaceColor','k');
set(hCPW,'MarkerSize',3);

%%

suptitle({'Case Western Activity Amplitude and Acrophase';''});
h = [hPBS,hPBW,hCBS,hCBW];
M = {'ADRD Patients - Summer','ADRD Patients - Winter',...
    'Caregivers - Summer','Caregivers - Winter'};
plots.legendflex.legendflex(h,M,'ncol',2,'nrow',2,'ref',gcf,'anchor',[2,6],'buffer',[0,-0.5],'bufferunit','normalized','padding',[0 0 20]);

saveas(gcf,'test.pdf');
set(0,'DefaultAxesFontSize',fSize);
end


function [x,y] = phasor2cart(mag,ang)

rho = mag;

theta = 2*pi - ang;

[x,y] = pol2cart(theta,rho);

end

