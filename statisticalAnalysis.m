close all 
clear

% fileName = 'sup_Gastrocnemius_Analysis.csv';
fileName = 'sup_TibialisAnterior_Analysis.csv';
[Case,File,onset,Group,Age,Test] = importfile(fileName);

fileName = strrep(fileName,'_', '  ');
figure
boxplot(onset,Group,'notch','on','labels',{'Age < 31','Age > 31'})
ylabel('onset')
title(fileName)
%%
fileName = 'sup_Gastrocnemius_Analysis.csv';
[Case,File,onset,Group,Age,Test] = importfile(fileName);

fileName = strrep(fileName,'_', '  ');
figure
boxplot(onset,Group,'notch','on','labels',{'Age < 31','Age > 31'})
ylabel('onset')
title(fileName)
%%
fileName = 'sp_TibialisAnterior_Analysis.csv';
[Case,File,onset,Group,Age,Test] = importfile(fileName);

fileName = strrep(fileName,'_', '  ');
figure
boxplot(onset,Group,'notch','on','labels',{'Age < 31','Age > 31'})
ylabel('onset')
title(fileName)
%%
fileName = 'sp_Gastrocnemius_Analysis.csv';
[Case,File,onset,Group,Age,Test] = importfile(fileName);

fileName = strrep(fileName,'_', '  ');
figure
boxplot(onset,Group,'notch','on','labels',{'Age < 31','Age > 31'})
ylabel('onset')
title(fileName)
