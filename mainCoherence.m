clc
clear
close all
warning off
fmax = 30;
f = 1 : .5 : fmax;
fs = 500;
electrodeNumbers = [5 5 6 9 9 10 10 13; 6 13 14 10 13 6 14 4];
elderlyCxy = cell(1,length(electrodeNumbers));
youngsterCxy = cell(1,length(electrodeNumbers));
;
%% Cho[ages,names] = xlsread('age')ose the desired interval for calculations
for experiment = {'sp' 'dp' 'sup' 'dup'}
    experiment = cell2mat(experiment)
    for intervalMode = 1:3; % Modes : I[-1000,-500]  II[-500,0]  III[0,500]
        switch intervalMode
            case 1
                t1 = 1000;
                t2 = 500;
            case 2
                t1 = 500;
                t2 = 0;
            case 3
                t1 = 0;
                t2 = -500;
        end
        folderAddress = [pwd '\Cxy\' experiment '\intervalMode' num2str(intervalMode) '\'] ;
        mkdir(folderAddress);
        %% Data Folders
        dataFolder = [pwd '\Data\'];
        patients = ls([dataFolder '*.']); % Enlist all patients
        patients(1:2,:) = []; % The first two elements correspond to . and ..
        numberOfCases = size(patients, 1); % Number of patients in the experiment
        %% Output Files
        fileID1 = fopen([folderAddress '1DeltaCoherence.csv'],'w');
        fileID2 = fopen([folderAddress '2ThetaCoherence.csv'],'w');
        fileID3 = fopen([folderAddress '3AlphaCoherence.csv'],'w');
        fileID4 = fopen([folderAddress  '4BetaCoherence.csv'],'w');
        fileID5 = fopen([folderAddress '4Beta2Coherence.csv'],'w');
        for file = [fileID1 fileID2 fileID3 fileID4 fileID5]
            fprintf(file,'%10s,%8s, %8s,','Case','Experiment','Age');
        end
        %%
        for currentCase = 1 : numberOfCases
            caseName = strtrim(patients(currentCase,:)) % Remove the entailing spaces
            age = returnAge(caseName,ages,names)
            %% Import Data
            filesList = ls([dataFolder caseName '\*.txt']); % Enlist the files for all experiments on each patient
            numberOfExperiments = size(filesList, 1); % On each case, several tests have been done: sp dp sup dup
            for currentExp = 1 : numberOfExperiments
                fileName = strtrim(filesList(currentExp,:)); % Remove the entailing spaces
                if and(~and(currentCase==1 , currentExp==1),...
                        ~strcmpi(fileName(~isspace(fileName(1:end-4))),experiment))
                    continue
                end
                dataTableOrig = readtable([dataFolder caseName '\' fileName], 'delimiter', 'space'); %
                dataTableOrig.Var33 = [] ; % reduntant elctrode
                dataTableOrig.CH32= [] ; % reduntant elctrode
                dataTable = filterTable(dataTableOrig,fs);
                electrodeNames = dataTable.Properties.VariableNames; % Show acquired signals
                if currentCase == 1
                    for file = [fileID1 fileID2 fileID3 fileID4 fileID5]
                        for idx = 1: size(electrodeNumbers,2)
                            i = electrodeNumbers(1,idx);
                            j = electrodeNumbers(2,idx);
                            fprintf(file,'%s - %s,',electrodeNames{i},electrodeNames{j});
                        end
                        fprintf(file,'\n');
                    end
                end
            end
            t = (1: size(dataTable,1))/fs;
            %% Find Trigger Activation Points
            triggerSignal = dataTableOrig.TRIGG;
            Perturbation = abs(dataTable.TRIGG); % Powerline noise removed
            [triggerPoints,indStop] = findTriggerPoints(triggerSignal,Perturbation);
            if isempty(triggerPoints), fprintf(fileID1,'\n'); continue, end
            for file = [fileID1 fileID2 fileID3 fileID4 fileID5]
                fprintf(file,'%10s,%8s,%d,',caseName,fileName,age);
            end
            %% Coherence Computation
            Cxy = cell(1,length(electrodeNumbers));
            MEDcxy = cell(1,length(electrodeNumbers));
            for idx = 1 : size(electrodeNumbers,2)
                i = electrodeNumbers(1,idx);
                j = electrodeNumbers(2,idx);
                x = dataTable.(electrodeNames{i});
                for counter = 1: numel(triggerPoints);
                    triggerPoint = triggerPoints(counter);
                    y = dataTable.(electrodeNames{j});
                    [Cxy{idx}(counter,:),~] = mscohere(x(triggerPoint-t1:triggerPoint-t2),...
                        y(triggerPoint-t1:triggerPoint-t2),[],[],f,fs);
                end
                MEDcxy{idx} = trimmean((Cxy{idx}),30);
                if  age <= 30
                    youngsterCxy{idx}(end+1,:) =  MEDcxy{idx};
                else
                    elderlyCxy{idx}(end+1,:) =  MEDcxy{idx};
                end
                deltaCoh = mean(MEDcxy{idx}(1:6));
                thetaCoh = mean(MEDcxy{idx}(7:15));
                alphaCoh = mean(MEDcxy{idx}(15:23));
                betaCoh =  mean(MEDcxy{idx}(23:49));
                beta2Coh = mean(MEDcxy{idx}(35:59));
                
                fprintf(fileID1,'%6.2f,',deltaCoh);
                fprintf(fileID2,'%6.2f,',thetaCoh);
                fprintf(fileID3,'%6.2f,',alphaCoh);
                fprintf(fileID4,'%6.2f,',betaCoh);
                fprintf(fileID5,'%6.2f,',beta2Coh);
            end
            for file = [fileID1 fileID2 fileID3 fileID4 fileID5]
                fprintf(file, '\n');
            end
        end
        save(['resultsCxy' experiment intervalMode],'youngsterCxy','elderlyCxy','electrodeNumbers','f')
    end
    %%
    close all
    for idx = 1 : numel(electrodeNumbers)
        i = electrodeNumbers(idx,1);
        j = electrodeNumbers(idx,2);
        figure
        hold on
        xlabel('Frequency (Hz)')
        ylabel('Coherence')
        title([electrodeNames{i} ' , ' electrodeNames{j}])
        
        y = 10*log10(elderlyCxy{idx});
        plot_ci(f,[trimmean(y,30); trimmean(y,30)-std(y); trimmean(y,30)+std(y)], 'PatchColor', 'b', 'PatchAlpha', 0.1, ...
            'MainLineWidth', 2, 'MainLineColor', 'b', ...
            'LineWidth', 1, 'LineStyle',':', 'LineColor', 'k');
        
        y = 10*log10(youngsterCxy{idx});
        plot_ci(f,[trimmean(y,30); trimmean(y,30)-std(y); trimmean(y,30)+std(y)], 'PatchColor', 'r', 'PatchAlpha', 0.1, ...
            'MainLineWidth', 2, 'MainLineColor', 'r', ...
            'LineWidth', 1, 'LineStyle','-', 'LineColor', 'k');
        
        %                 frequency_annotation(fmax);
        saveas(gcf, [folderAddress electrodeNames{i} '_' electrodeNames{j} '.png'])
        close(gcf)
    end
end
