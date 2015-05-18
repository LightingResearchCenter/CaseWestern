function plot3upPhasor
%PLOT3UPPHASOR Summary of this function goes here
%   Detailed explanation goes here

[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);

projectDir = fullfile([filesep,filesep,'root'],'projects',...
    'NIH Alzheimers','CaseWesternData');
analysisDir = fullfile(projectDir,'Analysis');
phasorFilePath = fullfile(analysisDir,'2014-03-17_17-13_phasorOutput.mat');

TempStruct = load(phasorFilePath,'output');

phasorResults = TempStruct.output;

% Remove empty cells
emptyIdx = cellfun(@isempty,phasorResults);
phasorResults(emptyIdx) = [];

% Flatten from to one struct
PhasorResults = [phasorResults{:}];

% Remove excluded subjects
excludeIdx = strcmp({PhasorResults.excludeRepeat},'true');
PhasorResults(excludeIdx) = [];

% Remove incomplete subjects
incompleteSubjects = [14,23,40,49,66,14.1,23.1,36.1,38.1,39.1,40.1,49.1,59.1,66.1,76.1];
for iSub = 1:numel(incompleteSubjects);
    incompleteIdx = [PhasorResults.subject] == incompleteSubjects(iSub);
    PhasorResults(incompleteIdx) = [];
end

patientIdx = mod([PhasorResults.subject],1) == 0;
caregiverIdx = ~patientIdx;

baselineIdx = [PhasorResults.week] == 0;
interventionIdx = [PhasorResults.week] == 1;
postIdx = [PhasorResults.week] == 2;

summerIdx = strcmp({PhasorResults.season},'summer');
winterIdx = strcmp({PhasorResults.season},'winter');

% Baseline
patientBaselineSummer = PhasorResults(patientIdx & baselineIdx & summerIdx);
patientBaselineWinter = PhasorResults(patientIdx & baselineIdx & winterIdx);

caregiverBaselineSummer = PhasorResults(caregiverIdx & baselineIdx & summerIdx);
caregiverBaselineWinter = PhasorResults(caregiverIdx & baselineIdx & winterIdx);

% Intervention
patientInterventionSummer = PhasorResults(patientIdx & interventionIdx & summerIdx);
patientInterventionWinter = PhasorResults(patientIdx & interventionIdx & winterIdx);

caregiverInterventionSummer = PhasorResults(caregiverIdx & interventionIdx & summerIdx);
caregiverInterventionWinter = PhasorResults(caregiverIdx & interventionIdx & winterIdx);

% Post Intervention
patientPostSummer = PhasorResults(patientIdx & postIdx & summerIdx);
patientPostWinter = PhasorResults(patientIdx & postIdx & winterIdx);

caregiverPostSummer = PhasorResults(caregiverIdx & postIdx & summerIdx);
caregiverPostWinter = PhasorResults(caregiverIdx & postIdx & winterIdx);

%% Patients
% Create figure and axes
[hFigiure,width,height,units] = reports.initializefigure(1,'on');
fSize = get(0,'DefaultAxesFontSize');
set(0,'DefaultAxesFontSize',8);

hSub1 = subplot(2,3,1);
hSub1 = plots.phasoraxes(hSub1);
hTitle1 = text(0,1.3,{'ADRD Patients';'Baseline'});
set(hTitle1,'HorizontalAlignment','center');
set(hTitle1,'FontWeight','bold');
set(hTitle1,'FontSize',fSize);

hSub2 = subplot(2,3,2);
hSub2 = plots.phasoraxes(hSub2);
hTitle2 = text(0,1.3,{'ADRD Patients';'Intervention'});
set(hTitle2,'HorizontalAlignment','center');
set(hTitle2,'FontWeight','bold');
set(hTitle2,'FontSize',fSize);

hSub3 = subplot(2,3,3);
hSub3 = plots.phasoraxes(hSub3);
hTitle3 = text(0,1.3,{'ADRD Patients';'Post Intervention'});
set(hTitle3,'HorizontalAlignment','center');
set(hTitle3,'FontWeight','bold');
set(hTitle3,'FontSize',fSize);


% Plot Baseline
[x,y] = phasor2cart([patientBaselineSummer.phasorMagnitude],[patientBaselineSummer.phasorAngle]);
hPBS = plot(hSub1,x,y,'ok');
set(hPBS,'MarkerFaceColor','none');
set(hPBS,'MarkerSize',3);
[x,y] = phasor2cart([patientBaselineWinter.phasorMagnitude],[patientBaselineWinter.phasorAngle]);
hPBW = plot(hSub1,x,y,'ok');
set(hPBW,'MarkerFaceColor','k');
set(hPBW,'MarkerSize',3);

% Plot Intervention
[x,y] = phasor2cart([patientInterventionSummer.phasorMagnitude],[patientInterventionSummer.phasorAngle]);
hPIS = plot(hSub2,x,y,'ok');
set(hPIS,'MarkerFaceColor','none');
set(hPIS,'MarkerSize',3);
[x,y] = phasor2cart([patientInterventionWinter.phasorMagnitude],[patientInterventionWinter.phasorAngle]);
hPIW = plot(hSub2,x,y,'ok');
set(hPIW,'MarkerFaceColor','k');
set(hPIW,'MarkerSize',3);

% Plot Post Intervention
[x,y] = phasor2cart([patientPostSummer.phasorMagnitude],[patientPostSummer.phasorAngle]);
hPPS = plot(hSub3,x,y,'ok');
set(hPPS,'MarkerFaceColor','none');
set(hPPS,'MarkerSize',3);
[x,y] = phasor2cart([patientPostWinter.phasorMagnitude],[patientPostWinter.phasorAngle]);
hPPW = plot(hSub3,x,y,'ok');
set(hPPW,'MarkerFaceColor','k');
set(hPPW,'MarkerSize',3);


%% Caregivers
% Create figure and axes

hSub4 = subplot(2,3,4);
hSub4 = plots.phasoraxes(hSub4);
hTitle4 = text(0,-1.3,{'Caregivers';'Baseline'});
set(hTitle4,'HorizontalAlignment','center');
set(hTitle4,'FontWeight','bold');
set(hTitle4,'FontSize',fSize);

hSub5 = subplot(2,3,5);
hSub5 = plots.phasoraxes(hSub5);
hTitle5 = text(0,-1.3,{'Caregivers';'Intervention'});
set(hTitle5,'HorizontalAlignment','center');
set(hTitle5,'FontWeight','bold');
set(hTitle5,'FontSize',fSize);

hSub6 = subplot(2,3,6);
hSub6 = plots.phasoraxes(hSub6);
hTitle6 = text(0,-1.3,{'Caregivers';'Post Intervention'});
set(hTitle6,'HorizontalAlignment','center');
set(hTitle6,'FontWeight','bold');
set(hTitle6,'FontSize',fSize);

% Plot Baseline
[x,y] = phasor2cart([caregiverBaselineSummer.phasorMagnitude],[caregiverBaselineSummer.phasorAngle]);
hCBS = plot(hSub4,x,y,'sk');
set(hCBS,'MarkerFaceColor','none');
set(hCBS,'MarkerSize',3);
[x,y] = phasor2cart([caregiverBaselineWinter.phasorMagnitude],[caregiverBaselineWinter.phasorAngle]);
hCBW = plot(hSub4,x,y,'sk');
set(hCBW,'MarkerFaceColor','k');
set(hCBW,'MarkerSize',3);

% Plot Intervention
[x,y] = phasor2cart([caregiverInterventionSummer.phasorMagnitude],[caregiverInterventionSummer.phasorAngle]);
hCIS = plot(hSub5,x,y,'sk');
set(hCIS,'MarkerFaceColor','none');
set(hCIS,'MarkerSize',3);
[x,y] = phasor2cart([caregiverInterventionWinter.phasorMagnitude],[caregiverInterventionWinter.phasorAngle]);
hCIW = plot(hSub5,x,y,'sk');
set(hCIW,'MarkerFaceColor','k');
set(hCIW,'MarkerSize',3);

% Plot Post Intervention
[x,y] = phasor2cart([caregiverPostSummer.phasorMagnitude],[caregiverPostSummer.phasorAngle]);
hCPS = plot(hSub6,x,y,'sk');
set(hCPS,'MarkerFaceColor','none');
set(hCPS,'MarkerSize',3);
[x,y] = phasor2cart([caregiverPostWinter.phasorMagnitude],[caregiverPostWinter.phasorAngle]);
hCPW = plot(hSub6,x,y,'sk');
set(hCPW,'MarkerFaceColor','k');
set(hCPW,'MarkerSize',3);

%%

suptitle({'Case Western Phasors';''});
h = [hPBS,hPBW,hCBS,hCBW];
M = {'ADRD Patients - Summer','ADRD Patients - Winter',...
    'Caregivers - Summer','Caregivers - Winter'};
plots.legendflex.legendflex(h,M,'ncol',2,'nrow',2,'ref',gcf,'anchor',[2,6],'buffer',[0,-0.5],'bufferunit','normalized','padding',[0 0 20]);

saveas(gcf,'test.pdf');
set(0,'DefaultAxesFontSize',fSize);
end


function [x,y] = phasor2cart(mag,ang)

rho = mag;

theta = ang*pi/12;

[x,y] = pol2cart(theta,rho);

end

