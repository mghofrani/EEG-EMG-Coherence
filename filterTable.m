function D = filterTable(D,fs)
%%
d = fdesign.comb('notch','L,BW,GBW,Nsh',10,2,-25,2,fs);
Hd=design(d);
% fvtool(Hd)
% save('Hd','Hd')
% load Hd
%%
for i = 1:size(D,2)
    currentElectrode = D.Properties.VariableNames{i};
    x = D{:,i};
    if  (strcmpi(currentElectrode, 'TA')|| strcmpi(currentElectrode, 'GAS'))        
        data_comb = filter(Hd,x);
        [b,a] = butter(3,[30]/(fs/2),'high');
        data_filt = filtfilt(b,a,abs(data_comb));

        windowSize = fs/20; % 50 ms = 1s / 20
        b = (1/windowSize)*ones(1,windowSize);
        a = 1 ;
        xRMS=  sqrt(filtfilt(b ,a , data_comb.^2));
        D{:,i} = xRMS;
    elseif strcmpi(currentElectrode, 'TRIGG')
        D{:,i} = filter(Hd,x);
    else
        xNotch= filter(Hd,x);
        [b,a] = butter(3, [1 40]/(fs/2), 'bandpass');
        D{:,i} = filter(b,a,xNotch);
    end    
end
end