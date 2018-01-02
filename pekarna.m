function pekarna(dobaSimulace,zakazniciph,pocetPrepazek,...
    dobaObsluhypm,maxFronta,pocatecniFronta)
if nargin < 1, dobaSimulace = 8; end
if nargin < 2, zakazniciph = 100; end % stredni pocet cestujicich k odbaveni za hodinu
if nargin < 3, pocetPrepazek = 1; end % pocet prepazek
if nargin < 4, dobaObsluhypm = 2; end % stredni doba stravena na prepazce v minutach
if nargin < 5, maxFronta = Inf; end
if nargin < 6, pocatecniFronta = 0; end

% initializace
time = 0;
fronta = 0;
obsluha = [ ];
prichod = time+exprnd(1/zakazniciph);
fronta_hist = [ ];
% 1.sloupec – prichod zakaznika do systemu, 2.sloupec - zacatek obsluhy, 
% 3.sloupec - konec obsluhy, 4.sloupec - uspesne obslouzen
zakaznici=[ ];
obslouzeno = 0;

% pocatecni fronta
for i = 1:pocatecniFronta
    prichodZakaznika(0);
end

% simulace
while time < dobaSimulace
    fronta_hist(end+1,:)=[time fronta fronta+length(obsluha)];

    % Buï prijde zakaznik nebo zakaznik odejde (skonci obsluha u prepazky)
    
    % bud se nikdo neobsluhuje, nebo prisel driv nez skonci nektery obsluhovany.
    if (isempty(obsluha))||(prichod < min(obsluha))
        % zapisu ze prisel zakaznik
        prichodZakaznika(prichod);
        % posunu hodiny
        time = prichod;
        % pripravi se cas prichodu dalsiho cloveka
        prichod=time+exprnd(1/zakazniciph); 
    else
        %okamzik doobslouzeni zakaznika
        [time, prepazka] = min(obsluha); % POZOR tady se posouva cas; vezmu prvniho doobslouzeneho (na tento okamzik posunu hodiny)
        if(fronta > 0) % pokud mam lidi ve fronte, tak doobslouzeneho nahradim novym
            fronta = fronta-1; % tzn. ubyde mi jeden ve fronte
            obslouzeno=obslouzeno+1;  % inkrementuji pocet obslouzenych
            
            obsluha(prepazka) = time+exprnd(dobaObsluhypm/60); % vygeneruji mu dobu obsluhy
            zakaznici(obslouzeno,2) = time;   % zacatek obsluhy
            zakaznici(obslouzeno,3) = obsluha(prepazka); % konec obsluhy, tzn. cas+exprnd(1/mu)
            zakaznici(obslouzeno,4) = 1; % zakaznik obslouzen
        else
            obsluha(prepazka)=[ ]; % zakaznik odesel
        end
    end
end

%neobslouzeni zakazniku po zaviracce
zakaznici(end-fronta+1:end,2:4)=[time;time;0]*ones(1,fronta);

%{
    function vykresliFrontu
        %vykresleni fronty do grafu a vypocet prumerne delky fronty
        figure
        subplot(1,2,1)
        stairs(fronta_hist(:,1),fronta_hist(:,3),'r')
        hold on
        stairs(fronta_hist(:,1),fronta_hist(:,2),'g')
        title('Vyvoj fronty a poctu zákazníku v centru')
        xlabel('Cas [hodiny]')
        ylabel('Pocet zakazniku')
        legend('Pocet zakazniku v systemu','Velikost fronty')
        prumerna_delka_fronty=sum(diff(fronta_hist(:,1)).*fronta_hist(1:end-1,2))/fronta_hist(end-1,1)
    end 
%vypocet pozadovanych casu [v min]
doba_v_systemu=(zakaznici(:,3)-zakaznici(:,1))*60;
doba_ve_fronte=(zakaznici(:,2)-zakaznici(:,1))*60;
prumerna_doba_v_systemu=mean(doba_v_systemu)
prumerna_doba_ve_fronte=mean(doba_ve_fronte)

%vykresleni doby stravene v centru
%figure
subplot(1,2,2)
hist(doba_v_systemu,35)
title('Graf doby stravene v centru')
xlabel('Doba stravena v centru [minuty]')
ylabel('Pocet zakazniku') 
%}

    function prichodZakaznika(prichod)
        zakaznici(end+1,1) = prichod; % pridame zakaznika do systemu
        % prichozi zakaznik musi cekat ve fronte nebo se rovnou obslouzi
        if(length(obsluha) < pocetPrepazek) %existuje volna prepazka
            obsluha = [obsluha, prichod+exprnd(dobaObsluhypm/60)]; % pridam konec obsluhy cloveka
            zakaznici(end,2)=prichod; % zacatek obsluhy
            zakaznici(end,3)=obsluha(end);  % konec obl., tzn. cas+exprnd(1/mu)
            zakaznici(end,4)=1; % zakaznik obslouzen
            obslouzeno = obslouzeno+1; % inkrementuji pocet obslouzenych
        else %zakaznik musí cekat ve fronte
            if fronta < maxFronta 
                fronta = fronta+1; % zakaznik pocka ve fronte
            else % zakaznik odesel jinam
                zakaznici(end,2) = prichod;
                zakaznici(end,3) = prichod;
                zakaznici(end,4) = 0; % neobslouzen
            end
        end
    end
end