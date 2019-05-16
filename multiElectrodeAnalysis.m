function [] = multiElectrodeAnalysis( ~ )
%MULTIELECTRODEANALYSIS Summary of this function goes here
%   Detailed explanation goes here
clc
clear
close all
warning off
fmax = 25;
% f = 1 : .5 : fmax;
fs = 500;
%%
intervalMode = 3; % Modes : I[-1000,-500]  II[-500,0]  III[0,500]
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
%% Import Data
[ages,names] = xlsread('age');
[fileName,dataFolder] = uigetfile('*.txt')
idx = strfind(dataFolder,'\');
caseName = dataFolder(idx(end-1)+1:end-1)
fprintf('Test:%10s  \n',fileName);
dataTableOrig = readtable([dataFolder '\' fileName], 'delimiter', 'space'); % Import ASCII file
dataTableOrig.Var33 = [] ; % reduntant elctrode
dataTableOrig.CH32= [] ; % reduntant elctrode

dataTable = filterTable(dataTableOrig,fs);
electrodeNames = dataTable.Properties.VariableNames; % Show acquired signals
t = (1: size(dataTable,1))/fs;

%% Find Trigger Activation Points
triggerSignal = dataTableOrig.TRIGG;
Perturbation = abs(dataTable.TRIGG); % Powerline noise removed
% Perturbation = dataTableOrig.TRIGG/max(dataTableOrig.TRIGG);
% Hd = load ('Hd'); Hd=Hd.Hd;
% Perturbation = fix(filter(Hd, Perturbation));
[triggerPoints,indStop] = findTriggerPoints(triggerSignal,Perturbation);

%%
fh1=figure('Units','normalized','Visible','on','Name',...
    ['   Test: ' fileName(1:end-4) '    Age: ' num2str(returnAge(caseName,ages,names)) '   ' caseName]);
set(zoom(fh1),'Motion','horizontal','Enable','on');
set(pan(fh1),'Motion','horizontal','Enable','on');
selection = false(numel(electrodeNames),1);
% selection (1:2:end-4) = false;
% selection (1:3:end-4) = false;
% selection (1:5:end-4) = false;
% selection (1:7:end-4) = false;
% selection (1:9:end-4) = false;
selection (end-2:end) = true;
% selection (end-4) = true;

electrodeTable = uitable('Parent',fh1,'Units','normalized','Position', [.01 .07 .11 .9], ...
    'rowname', electrodeNames,...
    'columnformat',{'logical'},...
    'ColumnWidth',{'auto'},...
    'ColumnEditable', [true],...
    'BackgroundColor',[.85 .87 .33; .31 .82 .75] , ...
    'visible', 'on',...
    'data',selection,...
    'CellEditCallback',@showGraphs);
uicontrol('Style', 'pushbutton', ...
    'Units', 'normalized', ...
    'Position', [.01 .04 .11 .03], ...
    'String', '<Reset>', ...
    'Callback', 'xlim auto' );
maxfig(fh1,1)
ax_handles = [];
magnify_handles = [];
spectrum_handles = [];
tf_handles = [];
temp = [];
showGraphs();
    function showGraphs(~,~)
        set(zoom(fh1),'ActionPostCallback',@zoomCallback);
        set(pan(fh1),'ActionPostCallback',@zoomCallback);
        if ~isempty(temp), temp = xlim; end
        delete([ax_handles,magnify_handles,spectrum_handles,tf_handles]);
        flags = find(electrodeTable.Data);
        left= 0.15;
        currentCount = numel(flags);
        width=0.84;
        height=0.9 / currentCount ; % which is also bottom1-bottom2
        bottom = linspace (.98 - height , .05 , currentCount);
        ax_handles = zeros ( 1 , currentCount);
        magnify_handles = zeros ( 1 , currentCount);
        spectrum_handles = zeros ( 1 , currentCount);
        tf_handles = zeros ( 1 , currentCount);
        
        for j = 1 : currentCount
            magnify_handles(j) = uicontrol( ...
                'Style', 'pushbutton', ...
                'Units', 'normalized', ...
                'Position', [1.01*left bottom(j) .02 .02], ...
                'String', '<T>', ...
                'tag', num2str(j), ...
                'Callback', @magnify );
            
            spectrum_handles(j) = uicontrol( ...
                'Style', 'pushbutton', ...
                'Units', 'normalized', ...
                'Position', [1.16*left bottom(j) .02 .02], ...
                'String', '<F>', ...
                'tag', num2str(j), ...
                'Callback', @spectrumEstimation );
            
            tf_handles(j) = uicontrol( ...
                'Style', 'pushbutton', ...
                'Units', 'normalized', ...
                'Position', [1.31*left bottom(j) .02 .02], ...
                'String', '<TF>', ...
                'tag', num2str(j), ...
                'Callback', @spectrogramEstimation );
            
            ax_handles(j) = axes('Position',[left bottom(j) width height] );            
            hold on;
            currentElectrode = dataTable.Properties.VariableNames{flags(j)};
            ss = dataTable.(currentElectrode);
            for k = 1: length(triggerPoints)
                h = line([t(triggerPoints(k)) t(triggerPoints(k))], [min(ss) max(ss)]);
                set( h , 'LineWidth',2.8,'LineStyle', '-' ,'color',[0.92 0.69 0.12])
            end
            for k = 1: length(indStop)
                h = line([t(indStop(k)) t(indStop(k))], [min(ss) max(ss)]);
                set( h , 'LineWidth',2.8,'LineStyle', '-' ,'color','r') %[0.92 0.69 0.12]
            end                        
            h = plot ( t , ss ); % , 'color' , )[.466 .674 .188]
            legend (h,currentElectrode , 'Location','NorthEast'); legend('boxoff')          
            axis tight          
            if j == currentCount, break, end
            set(gca, 'XTickLabel', [],'XTick',[] )
        end
        linkaxes (ax_handles , 'x')
        if isempty(temp), temp = xlim; end
        xlim(temp);
        
        function magnify (hObject,~)
            number=str2double(get(hObject,'tag'));            
            fh5=figure(5);clf
            new_handle = copyobj (ax_handles (number) , fh5);
            set(new_handle, 'Position' ,[0.1300 0.1100 0.7750 0.8150],...
                'XTickMode', 'auto', 'XTickLabelMode', 'auto', ...
                'YTickMode', 'auto', 'YTickLabelMode', 'auto')
            signalName = [dataTable.Properties.VariableNames{flags(number)}];
            title(signalName)            
            hold on
            plot(t,(dataTableOrig.(signalName)))
            ylim auto
        end
        
        function spectrumEstimation (hObject,~)
            number=str2double(get(hObject,'tag'));
            figure(6); clf, hold on
            x = dataTableOrig.(dataTableOrig.Properties.VariableNames{flags(number)});
            [pxx,f] = periodogram(x,[],[],fs);
            plot(f,10*log10(pxx),'color', [0 0.447 0.741] )
            
            x = dataTable.(dataTable.Properties.VariableNames{flags(number)});
            [pxx,f] = periodogram(x,[],[],fs);          
            plot(f,10*log10(pxx),'color' ,[0.929 0.694 0.125] )
            ylabel('dB')
            title([dataTable.Properties.VariableNames{flags(number)}])
            %            frequency_annotation
        end
        
        function spectrogramEstimation (hObject,~)            
%             f = 1 : .5 : fmax;
            number=str2double(get(hObject,'tag'));
            figure(7); clf, hold on
            center =  mean(get(ax_handles(number),'XLim'));
%             [~,I] = min(abs(triggerPoints/fs-center));
%             triggerPoint = triggerPoints(I);
            I=round(fs*get(ax_handles(1),'XLim'));
            
%             subplot(121)
            x = dataTableOrig.(dataTableOrig.Properties.VariableNames{flags(number)});
%             spectrogram(x(I(1):I(2)),[],round(diff(I)/2),[],fs,'yaxis')
            
            [pxx,f] = pwelch(x(I(1):I(2)),[],[],[],fs);
            
            plot(f,10*log10(pxx),'LineWidth',2)            
                        
%             subplot(122)
            x = dataTable.(dataTable.Properties.VariableNames{flags(number)});
%             spectrogram(x(I(1):I(2)),[],round(diff(I)/2),[],fs,'yaxis')
            
            
            [pxx,f] = pwelch(x(I(1):I(2)),[],[],[],fs);
            plot(f,10*log10(pxx),'LineWidth',2)
%             xlim([0 30])
            legend('Raw','Filtered')
            xlabel('Frequency (Hz)')
            ylabel('Magnitude (dB)')
%             signalName = [dataTable.Properties.VariableNames{flags(number)}];
%             title([signalName '  [Interval: ' num2str(intervalMode) ...
%                 '] Perturbation:' num2str(triggerPoint/fs) ])            
%             frequency_annotation(fmax);
        end
                
        function zoomCallback(~,~)
            I=round(fs*get(ax_handles(1),'XLim'));
            for i = 1: numel(ax_handles)
                y = dataTable.(dataTable.Properties.VariableNames{flags(i)});
                ylim(ax_handles(i),[min(y(I(1):I(2))) max(y(I(1):I(2)))]);
            end
        end
    end
end
