function [onset , offset , areas] = EMG_analysis (signal, muscleName, triggerPoints, redPoints, currentIndice, t, fs)
%% Values for onset and offset calculations
currentRed = redPoints(currentIndice);
currentTrigger = triggerPoints(currentIndice);
% if currentIndice == 1
%     TTH1 = round(.7 * triggerPoints(currentIndice)) ;
% else
%     TTH1 = round(.7 * (triggerPoints(currentIndice) - triggerPoints(currentIndice-1)));
% end
TTH1 = fs/2;
TTH2 = fs/2.5;
% if TTH2 <= 0 , TTH2 = 100 ; end
THG = 3 ;
TON = fs/40 ; %25ms * 500Hz ~= 12.5 samples
TOFF = TON ;
THRESH = THG * std(signal(currentTrigger-TTH1:currentTrigger-TTH2)) + mean(signal(currentTrigger-TTH1:currentTrigger-TTH2));
%% --- on and off time computations -------------------------------------
onset = []; offset = [];
ind = find( [signal ;THRESH-1; THRESH] >= THRESH );
ind(ind<currentTrigger-fs/4)=[];
ind(ind>currentTrigger+fs/2)=[];
g1=find([2 diff(ind)']>1);
g2=find(diff(g1)>= TON, 1,'first');
if ~isempty(g2)
    onset = ind(g1(g2));
    fprintf('Onset time: %6.2f   \n  ', t(onset))
end

ind = find([signal; THRESH+1 ; THRESH] <=THRESH);
ind(ind<=currentTrigger)=[];
if ~isempty(onset)
    ind(ind>onset)=[];
end
if currentIndice < length(triggerPoints)
    ind(ind>redPoints(currentIndice+1))=[];
end
g1=find([2 diff(ind)' ]>1);
g2=find(diff(g1)>=TOFF,1,'first');
if ~isempty(g2)
    offset=ind(g1(g2));
    fprintf('Offset time: %6.2f', t(offset))
end
fprintf('\n')

% plot (t,signal,'color', [0 0.447 0.741] , 'LineWidth', .5 )

ta = (currentTrigger-500):250:(currentTrigger+500); % 250 samples = .5s , 500 samples = 1s
areas(1)=trapz(signal(ta(1):ta(2)-1))/fs;
areas(2)=trapz(signal(ta(2):ta(3)-1))/fs;
areas(3)=trapz(signal(ta(3):ta(4)-1))/fs;
areas(4)=trapz(signal(ta(4):ta(5)-1))/fs;
areas = areas / max(areas);

% [~ , tMax] = max(signal(currentTrigger-250:currentTrigger+250));
% tMax = tMax + currentTrigger-250 -1;


% plot(t(125+(ta(1:4))), areas, 'o' ,'MarkerSize',4, 'Markerfacecolor', 'cyan', 'Markeredgecolor', 'black')
% for l = 1 : length(areas)
%     rectangle('Position',[t(ta(l)) areas(l)-1 250/fs 0], 'EdgeColor',[0.466 0.674 0.188],'LineWidth',1.5)
% end
% 
% if ~isempty(onset) , rectangle('Position',[t(onset) THRESH TON/fs 0], 'EdgeColor','black','LineWidth',2) ,end
% if ~isempty(offset) , rectangle('Position',[t(offset) THRESH TOFF/fs 0], 'EdgeColor','black','LineWidth',2) ,end
% 
% if currentIndice < length(triggerPoints)
%     MAX = max(signal(currentRed:redPoints(currentIndice+1)));
%     h = line([t(redPoints(currentIndice+1)) t(redPoints(currentIndice+1))], [0 1.1*MAX]);
%     set( h , 'LineWidth',1.2,'LineStyle', '-' ,'color','r') %[0.92 0.69 0.12]
% else
%     MAX  = max(signal(currentRed:end));
% end
% plot(t(tMax), signal(tMax) , 's' ,'MarkerSize',7, 'Markerfacecolor', 'blue', 'Markeredgecolor', 'black')
% 
% if currentIndice > 1
%     h = line([t(triggerPoints(currentIndice-1)) t(triggerPoints(currentIndice-1))], [0 1.1*MAX]);
%     set( h , 'LineWidth',1.2,'LineStyle', '-' ,'color',[0.92 0.69 0.12])
% end
% 
% 
% h = line([t(currentRed) t(currentRed)], [0 1.1*MAX]);
% set( h , 'LineWidth',1.2,'LineStyle', '-' ,'color','r') %[0.92 0.69 0.12]
% 
% h = line([t(currentTrigger) t(currentTrigger)], [0 1.1*MAX]);
% set( h , 'LineWidth',1.2,'LineStyle', '-' ,'color',[0.92 0.69 0.12])
% plot(t(onset),   signal(onset), 's' ,'MarkerSize',7, 'Markerfacecolor', 'yellow', 'Markeredgecolor', 'black')
% plot(t(offset), signal(offset) , 's' ,'MarkerSize',7, 'Markerfacecolor', 'magenta', 'Markeredgecolor', 'black')
% 
% rectangle('Position',[t(currentTrigger-TTH1) THRESH t(TTH1-TTH2) 0], 'EdgeColor','red','LineWidth',1)
% 
% if currentIndice == 1
%     xlim([0 t(redPoints(currentIndice+1))])
% elseif currentIndice < length(triggerPoints)
%     xlim([t(triggerPoints(currentIndice-1)) t(redPoints(currentIndice+1))])
% else
%     xlim([t(triggerPoints(currentIndice-1)) t(end)])
% end
% ylim ([0 1.1*MAX])
% title(muscleName)
end