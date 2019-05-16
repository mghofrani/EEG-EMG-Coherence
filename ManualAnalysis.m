clc
clear
close all
warning off
fmax = 25;
f = 1 : .5 : fmax;
fs = 500;

%% Import Data
[fileName,dataFolder] = uigetfile('*.txt');
fprintf('Test:%10s  \n',fileName);
dataTableOrig = readtable([dataFolder '\' fileName], 'delimiter', 'space'); % Import ASCII file
dataTableOrig.Var33 = [] ; % reduntant elctrode
dataTableOrig.CH32= [] ; % reduntant elctrode
dataTable = normalizeTable (dataTableOrig);
electrodeNames = dataTable.Properties.VariableNames; % Show acquired signals
t = (1: size(dataTable,1))/fs;

%% Find Trigger Activation Points
triggerSignal = dataTable.TRIGG;
load Hd
% Perturbation = fix(dataTable.TRIGG);
Perturbation = round(filter(Hd,dataTable.TRIGG));
[triggerPoints,indStop] = findTriggerPoints(Perturbation');
%%
TibialisAnterior = filterAndRectify(dataTable.TA, fs);
Gastrocnemius = filterAndRectify(dataTable.GAS, fs);
%%
% figure
% ax(1)= subplot(311);hold on
% plot(t,abs(dataTable.TA),'color' ,[0.929 0.694 0.125],'LineWidth' , .4)
% plot(t,TibialisAnterior,'LineWidth' , 1.2),title('TibialisAnterior')
% for k = 1: length(triggerPoints)
%     MAX = max(dataTable.TA(triggerPoints(k)-500:triggerPoints(k)+500));
%     h = line([t(triggerPoints(k)) t(triggerPoints(k))], [0 MAX]);
%     set( h , 'color', [.301 .745 .933] , 'LineWidth' , 1.3,'LineStyle', '--')
% end
% axis tight
%
% ax(2)=subplot(312);hold on
% plot(t,abs(dataTable.GAS),'color' ,[0.929 0.694 0.125],'LineWidth' , .4)
% plot(t,Gastrocnemius,'LineWidth' , 1.2),title('Gastrocnemius')
% for k = 1: length(triggerPoints)
%     MAX = max(dataTable.GAS(triggerPoints(k)-500:triggerPoints(k)+500));
%     h = line([t(triggerPoints(k)) t(triggerPoints(k))], [0 MAX]);
%     set( h , 'color', [.466 .674 .188] , 'LineWidth' , 1.3,'LineStyle', '--')
% end
% axis tight
%
% ax(3)=subplot(313);hold on
% plot(t,triggerSignal) , title([fileName(1:end-4)])
% axis tight
% plot(t(triggerPoints), triggerSignal(triggerPoints) , 'v','MarkerFaceColor','y','MarkerSize',8)
% maxfig(gcf,1)
%
% linkaxes(ax,'x')


%%
% close all
% Perturbation (Perturbation<=0) = 0 ;
% Perturbation = fix(Perturbation);
% ax(1) = subplot(311);
% hold on
% plot(t,TibialisAnterior,t,Perturbation,t, fix(Perturbation))
% plot(t(triggerPoints),Perturbation(triggerPoints),'og',t(indStop),Perturbation(indStop),'rs')
% ax(2) = subplot(312);
% hold on
% plot(t,Gastrocnemius,t(triggerPoints),Gastrocnemius(triggerPoints),'og',t(indStop),Gastrocnemius(indStop),'rs')
% plot(t, fix(Perturbation))
% ax(3) = subplot(313);
% hold on
% plot(t,dataTable.F8,t(triggerPoints),dataTable.F8(triggerPoints),'og',t(indStop),dataTable.F8(indStop),'rs')
% plot(t, fix(Perturbation))
% linkaxes(ax)
% %%
% % d = fdesign.comb('notch','L,BW,GBW,Nsh',10,25,-1,1,fs);
% % Hd=design(d);
% % % fvtool(Hd)
% %
% % figure
% % Perturbation = filter(Hd,triggerSignal);
% % plot(t,Perturbation)
% % ylabel('Voltage (V)')
% % xlabel('Time (s)')
% % title('Open-Loop Voltage')
% % legend('Unfiltered','Filtered')
% % grid
% %
% % figure
% % [popen,fopen] = periodogram(triggerSignal,[],[],fs);
% % [pbutt,fbutt] = periodogram(Perturbation,[],[],fs);
% %
% % plot(fopen,20*log10(abs(popen)),fbutt,20*log10(abs(pbutt)),'--')
% % ylabel('Power/frequency (dB/Hz)')
% % xlabel('Frequency (Hz)')
% % title('Power Spectrum')
% % legend('Unfiltered','Filtered')
% % grid
%
