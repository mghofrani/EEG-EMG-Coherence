clc
clear
close all
warning off
fmax = 25;
f = 1 : .5 : fmax;
fs = 500;
test = 'sp'

%% Data Folders
dataFolder = [pwd '\Data\'];
patients = ls([dataFolder '*.']); % Enlist all patients
patients(1:2,:) = []; % The first two elements correspond to . and ..
numberOfCases = size(patients, 1); % Number of patients in the experiment
%%
fileID1 = fopen([test '_TibialisAnterior_Analysis.csv'],'w');
fprintf(fileID1,'%10s,%8s,%12s,%8s,%8s,%8s \n','Case','File','onsetTibialis',...
    'Group','Age','Test');

fileID2 = fopen([test '_Gastrocnemius_Analysis.csv'],'w');
fprintf(fileID2,'%10s,%8s,%12s,%8s,%8s,%8s \n','Case','File','onsetGastrocnemius',...
    'Group','Age','Test');

[ages,names] = xlsread('age');

for currentCase = 1 : numberOfCases
    caseName = strtrim(patients(currentCase,:)); % Remove the entailing spaces
    caseAge = returnAge(caseName,ages,names);
    fprintf('Case:%10s  Progress: %d  \n',caseName,100*currentCase/numberOfCases);
    %% Import Data
    filesList = ls([dataFolder caseName '\*.txt']); % Enlist the files for all experiments on each patient
    numberOfTests = size(filesList, 1); % On each case, several tests have been done
    for currentTest = 1 : numberOfTests
        %% Import Data
        tic
        fileName = strtrim(filesList(currentTest,:)); % Remove the entailing spaces
        testName = lower(fileName(~isspace(fileName(1:end-4))));
        if ~strcmpi(fileName(~isspace(fileName(1:end-4))),test)
            continue
        end
        %idx = strfind(dataFolder,'\');
        fprintf('Test:%10s  \n',fileName);
        dataTableOrig = readtable([dataFolder caseName '\' fileName], 'delimiter', 'space'); %
        dataTableOrig.Var33 = [] ; % reduntant elctrode
        dataTableOrig.CH32= [] ; % reduntant elctrode
        dataTableOrig = dataTableOrig(:, end-2: end); % remove EEG
        dataTable = filterTable(dataTableOrig,fs);
        electrodeNames = dataTable.Properties.VariableNames; % Show acquired signals
        t = (1: size(dataTable,1))/fs;
        %% Find Trigger Activation Points
        triggerSignal = dataTableOrig.TRIGG;
        Perturbation = abs(dataTable.TRIGG); % Powerline noise removed
        [triggerPoints,indStop] = findTriggerPoints(triggerSignal,Perturbation);
        
        resultAddress = [pwd '\results\' caseName '\' fileName(1:end-4)];
        mkdir (resultAddress)
        
        %% EMG Analysis
        %         figure
        %         for i = 1 : 3
        %             subplot(3,1,i),hold on
        %             currentElectrode = dataTable.Properties.VariableNames{i};
        %             ss = dataTable.(currentElectrode);
        %             for k = 1: length(triggerPoints)
        %                 h = line([t(triggerPoints(k)) t(triggerPoints(k))], [min(ss) max(ss)]);
        %                 set( h , 'LineWidth',1.2,'LineStyle', '-' ,'color',[0.92 0.69 0.12])
        %             end
        %             for k = 1: length(indStop)
        %                 h = line([t(indStop(k)) t(indStop(k))], [min(ss) max(ss)]);
        %                 set( h , 'LineWidth',1.2,'LineStyle', '-' ,'color','r') %[0.92 0.69 0.12]
        %             end
        %             plot ( t , ss ); % , 'color' , )[.466 .674 .188]
        %             title(currentElectrode)
        %             axis tight
        %         end
        %         maxfig(gcf,1)
        %         saveas(gcf, [resultAddress '\`Muscles.png'])
        %         close
        onsetT = [];
        onsetG = [];
        for  i = 1 : length(triggerPoints);
            currentTrigger = triggerPoints(i);
            %             figure('Visible','Off')
            %             subplot(311), hold on
            %             plot(t,dataTableOrig.TRIGG)
            %             h = line([t(currentTrigger) t(currentTrigger)], [min(dataTable.TRIGG) max(dataTable.TRIGG)]);
            %             set( h , 'LineWidth',1.2,'LineStyle', '-' ,'color',[0.92 0.69 0.12])
            %             axis tight
            %             if i == 1
            %                 xlim([0 t(indStop(i+1))])
            %             elseif i < length(triggerPoints)
            %                 xlim([t(triggerPoints(i-1)) t(indStop(i+1))])
            %             else
            %                 xlim([t(triggerPoints(i-1)) t(end)])
            %             end
            %             title(['t_{Perturbation}: ' num2str(t(currentTrigger),'%6.1f ')])
            %
            %             subplot(312), hold on
            %             plot(t,abs(dataTable.TA),'color' ,[0.929 0.694 0.125])
            tMax = 1;
            [onset , ~ , ~] = EMG_analysis (dataTable.TA , ['[' testName ']  TibialisAnterior'], triggerPoints,indStop , i , t,fs);
            if ~isempty(onset)
                onsetT(end+1) = t(onset)-t(currentTrigger);
            end
            
            subplot(313), hold on
            plot(t,abs(dataTable.GAS),'color' ,[0.929 0.694 0.125])
            [onset , ~ , ~] = EMG_analysis (dataTable.GAS , ['[' testName ']  Gastrocnemius'] , triggerPoints,indStop, i , t , fs);
            if ~isempty(onset)
                onsetG(end+1) = t(onset)-t(currentTrigger) ;
            end
            %             xlabel('Seconds')
            
            %             saveas(gcf, [resultAddress '\' num2str(floor(t(currentTrigger))) '.png'])
            %             close
        end
        fprintf(fileID1,'%10s,%8s,%6.4f,%2d,%2d,%10s \n',caseName,...
            fileName(1:end-4), mean(onsetT),caseAge>31,caseAge,testName);
        
        fprintf(fileID2,'%10s,%8s,%6.4f,%2d,%2d,%10s \n',caseName,...
            fileName(1:end-4), mean(onsetG),caseAge>31,caseAge,testName);
        toc
    end
end
fclose('all');