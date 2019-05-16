clc
clear
close all
warning off
fmax = 30;
f = 1 : .5 : fmax;
fs = 500;
%% Choose the desired interval for calculations
for test = {'sp' 'dp' 'sup' 'dup'}
    for intervalMode = 1: 3; % Modes : I[-1000,-500]  II[-500,0]  III[0,500]
        tic
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
        folderAddress = [pwd '\PxxPng\' test '\intervalMode' num2str(intervalMode) '\'] ;
        mkdir(folderAddress);
        %% Data Folders
        dataFolder = [pwd '\Data\'];
        patients = ls([dataFolder '*.']); % Enlist all patients
        patients(1:2,:) = []; % The first two elements correspond to . and ..
        numberOfCases = size(patients, 1); % Number of patients in the experiment
        %%
        fileID1 = fopen([folderAddress '1DeltaPower.csv'],'w');
        fprintf(fileID1,'%10s,%8s,','Case','Test');
        fileID2 = fopen([folderAddress  '2ThetaPower.csv'],'w');
        fprintf(fileID2,'%10s,%8s,','Case','Test');
        fileID3 = fopen([folderAddress  '3AlphaPower.csv'],'w');
        fprintf(fileID3,'%10s,%8s,','Case','Test');
        fileID4 = fopen([folderAddress '4BetaPower.csv'],'w');
        fprintf(fileID4,'%10s,%8s,','Case','Test');
        fileID5 = fopen([folderAddress '5BetaIIPower.csv'],'w');
        fprintf(fileID5,'%10s,%8s,','Case','Test');
        [ages,names] = xlsread('age');
        
        %%
        for currentCase = 1 : numberOfCases
            caseName = strtrim(patients(currentCase,:)); % Remove the entailing spaces
            fprintf('Case:%10s  Progress: %2.1f  \n',caseName,100*currentCase/numberOfCases)
            %% Import Data
            filesList = ls([dataFolder caseName '\*.txt']); % Enlist the files for all experiments on each patient
            numberOfTests = size(filesList, 1); % On each case, several tests have been done
            for currentTest = 1 : numberOfTests
                fileName = strtrim(filesList(currentTest,:)); % Remove the entailing spaces
                if and(~and(currentCase==1 , currentTest==1),...
                        ~strcmpi(fileName(~isspace(fileName(1:end-4))),test))
                    continue
                end
                fprintf('Test:%10s  \n',fileName);
                dataTableOrig = readtable([dataFolder caseName '\' fileName], 'delimiter', 'space'); %
                dataTableOrig.Var33 = [] ; % reduntant elctrode
                dataTableOrig.CH32= [] ; % reduntant elctrode
                dataTable = filterTable(dataTableOrig,fs);
                electrodeNames = dataTable.Properties.VariableNames; % Show all acquired signals
                electrodeNames = electrodeNames([5 6 9 10 13 14])
                t = (1: size(dataTable,1))/fs;
                if and(currentCase==1 , currentTest==1)
                    fprintf(fileID1,'%s,',electrodeNames{:}); fprintf(fileID1,'\n');
                    fprintf(fileID2,'%s,',electrodeNames{:}); fprintf(fileID2,'\n');
                    fprintf(fileID3,'%s,',electrodeNames{:}); fprintf(fileID3,'\n');
                    fprintf(fileID4,'%s,',electrodeNames{:}); fprintf(fileID4,'\n');
                    fprintf(fileID5,'%s,',electrodeNames{:}); fprintf(fileID5,'\n');
                    elderlyPxx = cell(numel(electrodeNames),1);
                    youngsterPxx = cell(numel(electrodeNames),1);
                end
                
                fprintf(fileID1,'%10s,%8s,',caseName,fileName(1:end-4));
                fprintf(fileID2,'%10s,%8s,',caseName,fileName(1:end-4));
                fprintf(fileID3,'%10s,%8s,',caseName,fileName(1:end-4));
                fprintf(fileID4,'%10s,%8s,',caseName,fileName(1:end-4));
                
                %% Find Trigger Activation Points
                triggerSignal = dataTableOrig.TRIGG;
                Perturbation = abs(dataTable.TRIGG); % Powerline noise removed
                [triggerPoints,indStop] = findTriggerPoints(triggerSignal,Perturbation);
                if isempty(triggerPoints), fprintf(fileID1,'\n'); continue, end
                %% Power Spectral Density Estimation
                % colors = colormap(copper(numel(triggerPoints)));
                pxx = cell (length(triggerPoints),numel(electrodeNames));
                for i = 1 : numel(electrodeNames)
                    x = dataTable.(electrodeNames{i});
                    %             figure('Visible','Off'), hold on
                    Counter = 1;
                    
                    for triggerPoint = triggerPoints';
                        [pxx{Counter,i},~] = pwelch(x(triggerPoint-t1:triggerPoint-t2),[],[],f,fs);
                        %plot(f,10*log10(pxx{Counter,i}),'LineWidth',2,'Color',colors(Counter,:))
                        Counter = Counter + 1;
                    end
                    MEDpxx = trimmean(cell2mat(pxx(:,i)),30);
                    if returnAge(caseName,ages,names) <= 30
                        youngsterPxx {i}(end+1,:) =  MEDpxx;
                    else
                        elderlyPxx {i}(end+1,:) =  MEDpxx;
                    end
                    %             plot(f,10*log10(MEDpxx),'LineWidth',2)
                    %             xlabel('Frequency (Hz)')
                    %             ylabel('Magnitude (dB)')
                    %             title([ '[' fileName(1:end-4) ']     Power Spectral Density,  ' electrodeNames{i}])
                    %             frequency_annotation(fmax);
                    %             folderAddress = [pwd '\results\' caseName '\' fileName(1:end-4) ...
                    %                 '\PSD\intervalMode' num2str(intervalMode) '\'] ;
                    %             mkdir(folderAddress);
                    %             saveas(gcf, [folderAddress electrodeNames{i} '.png'])
                    %             close
                    
                    deltaPow = mean(MEDpxx(:,1:6));
                    thetaPow = mean(MEDpxx(:,7:15));
                    alphaPow = mean(MEDpxx(:,15:23));
                    betaPow  = mean(MEDpxx(:,23:49));
                    beta2Pow  = mean(MEDpxx(:,35:59));
                    fprintf(fileID1,'%6.2f,',deltaPow);
                    fprintf(fileID2,'%6.2f,',thetaPow);
                    fprintf(fileID3,'%6.2f,',alphaPow);
                    fprintf(fileID4,'%6.2f,',betaPow);
                    fprintf(fileID5,'%6.2f,',beta2Pow);
                end
                
                fprintf(fileID1,'\n');
                fprintf(fileID2,'\n');
                fprintf(fileID3,'\n');
                fprintf(fileID4,'\n');
                fprintf(fileID5,'\n');
            end
            toc
        end
        fclose('all');
        save('PxxResults', 'elderlyPxx', 'youngsterPxx','f','electrodeNames')
        %%
        % load ('PxxResults.mat')
        close all
        for i = 1 : numel(electrodeNames)
            figure
            hold on
            y = 10*log10(cell2mat(elderlyPxx(i)));
            plot_ci(f,[trimmean(y,30); trimmean(y,30)-std(y); trimmean(y,30)+std(y)], 'PatchColor', 'b', 'PatchAlpha', 0.1, ...
                'MainLineWidth', 2, 'MainLineColor', 'b', ...
                'LineWidth', 1, 'LineStyle',':', 'LineColor', 'k');
            
            y = 10*log10(cell2mat(youngsterPxx(i)));
            plot_ci(f,[trimmean(y,30); trimmean(y,30)-std(y); trimmean(y,30)+std(y)], 'PatchColor', 'r', 'PatchAlpha', 0.1, ...
                'MainLineWidth', 2, 'MainLineColor', 'r', ...
                'LineWidth', 1, 'LineStyle','-', 'LineColor', 'k');
            
            title([ '[' test ']     Power Spectral Density,  ' electrodeNames{i}])
            xlabel('Frequency (Hz)')
            ylabel('Magnitude (dB)')
            
            saveas(gcf, [folderAddress electrodeNames{i} '.png'])
            %     frequency_annotation(fmax)
        end
    end
end