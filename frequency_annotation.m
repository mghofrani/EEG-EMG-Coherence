function frequency_annotation(fmax)
yl = ylim;
colors = get(gca,'colororder');
%% delta [1 - 3.5] Hz
hp = patch([1 1 3.5 3.5],[yl(1) yl(2) yl(2) yl(1)],'w',...
    'facecolor',colors(1,:),'FaceAlpha',.1);

%% theta [4 - 8] Hz
hp = patch([4 4 7.5 7.5],[yl(1) yl(2) yl(2) yl(1)],'w',...
    'facecolor',colors(2,:),'FaceAlpha',.1);

%% alpha [8 - 12] Hz
hp = patch([8 8 12 12],[yl(1) yl(2) yl(2) yl(1)],'w',...
    'facecolor',colors(3,:),'FaceAlpha',.1);

%% beta [12 - 25] Hz
hp = patch([12.5 12.5 25 25],[yl(1) yl(2) yl(2) yl(1)],'w',...
    'facecolor',colors(4,:),'FaceAlpha',.1);

%% gamma [30 - ] Hz
% hp = patch([30 30 fmax fmax],[yl(1) yl(2) yl(2) yl(1)],'w',...
%     'facecolor',colors(5,:),'FaceAlpha',.1);

grid on
% annotation( 'doublearrow',[.1+1/fmax .1+3.5/fmax],[0.9 0.9],'units','normalized');

% annotation('textbox',...
%     [1/fmax 0.7 3.5/fmax 0.15],...
%     'String',{'klk'},...
%     'FitBoxToText','off');
end