k_max = 8; % pocet prepazek
N = 100; % pocet pozorovani
cenaCloveka = 1200;

start = now;
trzba = zeros(k_max,N);
cas = zeros(k_max,N);
cekani = zeros(k_max,N);
neobslouzeni = zeros(k_max,N);
delkaFronty = zeros(k_max,N);

parfor k = 1:k_max
    for n = 1:N
        [~,fronta,dobaVpekarne,dobaVeFronte,~,bezObsluhy,denniTrzba,~,~] = ...
            pekarna(k,Inf,15);
        trzba(k,n) = denniTrzba;
        cas(k,n) = dobaVpekarne;
        cekani(k,n) = dobaVeFronte;
        neobslouzeni(k,n) = bezObsluhy;
        delkaFronty(k,n) = fronta;
    end
end

stop = now;
dobaVypoctu = 86400 * (stop - start),

%% zobraz
prumernaTrzba = mean(trzba,2);
prumernaTrzba(:,2) = (1./(1:k_max))'.*prumernaTrzba;
prumernaTrzba(:,3) = prumernaTrzba(:,1)./sqrt((1:k_max)');
prumernyZisk = prumernaTrzba(:,1)-cenaCloveka*(1:k_max)';

odchylkaTrzby = std(trzba,0,2);

figure
subplot(2,2,[1,2])
bar(prumernaTrzba)
title('Trzba')
legend('trzba dne','trzba na cloveka','efektivita','Location','northwest')
xlabel('pocet pokladnich')
ylabel('penize')
%subplot(2,2,2)
%bar(prumernyVykon)
%title('Zisk')

prumerneCekani = mean(cekani,2);
odchylkaCekani = std(cekani,0,2);
subplot(2,2,3)
bar(prumerneCekani)
title('Cas ve frontì')
xlabel('pocet pokladnich')
ylabel('minuty')

prumerneOdmitnuti = mean(neobslouzeni,2);
prumernaDelkaFronty = mean(delkaFronty,2);
odchylkaOdmitnuti = std(neobslouzeni,0,2);
odchylkaDelkyFronty = std(delkaFronty,0,2);
subplot(2,2,4)
bar([prumerneOdmitnuti,prumernaDelkaFronty])
title('Neobslouzeni a fronta')
legend('neobslouzeni','delka fronty')
xlabel('pocet pokladnich')
ylabel('zakaznici')

%% vystupni tabulky
T = table((1:k_max)',[prumernaTrzba(:,1) odchylkaTrzby],...
    [prumerneCekani odchylkaCekani],...
    [prumerneOdmitnuti odchylkaOdmitnuti],...
    [prumernaDelkaFronty odchylkaDelkyFronty],...
    'VariableNames',{'k' 'Trzba' 'Cekani' 'Odmitnuti' 'Fronta'})
%[prumernaTrzba(:,1),odchylkaTrzby]
%[prumerneCekani odchylkaCekani prumerneOdmitnuti odchylkaOdmitnuti prumernaDelkaFronty odchylkaDelkyFronty]