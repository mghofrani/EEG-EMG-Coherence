function [triggerPoints, indRed] = findTriggerPoints(triggerSignal, Perturbation)
TH = .8 * min(triggerSignal) ;
TON = 20 ;
ind = find( [triggerSignal ;TH+1; TH] <= TH );
g1=find([2 diff(ind)']>1);
g2=find(diff(g1)>= TON);
triggerPoints = ind(g1(g2));

triggerPoints = removeDuplicates(triggerPoints);

locs=[round(.7*triggerPoints(1)); triggerPoints];
indRed = [];
D = 300;
for i = 1 : numel(locs)-1
    [~ , I] = max(Perturbation(locs(i)+D : locs(i+1)-D));
    indRed(end+1)= locs(i) + I + D - 1;
end


%% find starting oscilation of a switch
% triggerSignal(1:150) = 0;
% triggerSignal(end-200:end) = 0;
% triggerPoints = [];
% indRed = [];
% for ind = find (triggerSignal)
%     if all(triggerSignal(ind:ind+100)~=-1)
%         continue
%     elseif all(triggerSignal(ind+1:ind+10)~=1) && any(triggerSignal(ind+1:ind+10)==-1) && all(triggerSignal(ind-150:ind-1)==0)
%         triggerPoints(end+1) = ind;    
%     elseif any(triggerSignal(ind+1:ind+200)~=0)  && all(triggerSignal(ind-150:ind-1)==0)
%         indRed(end+1) = ind;        
%     end
% end


% triggerPoints = removeDuplicates(triggerPoints);
% indRed = removeDuplicates(indRed);

%% History
% The following codes might be totally wrong!
% figure
% hold on
% plot(triggerSignal)
% plot(triggerPoints, triggerSignal(triggerPoints) , 'p','MarkerFaceColor','y','MarkerSize',10)
% title('Trigger Activation')
% xlabel (['Number of Trials: ' num2str(numel(triggerPoints))])
% axis tight

%%
% elseif all(triggerSignal(ind+1:ind+200)==0);
%         triggerPoints(end+1) =  ind;