% basic usage: "pekarna(4);"
function [zakaznici,prumerna_delka_fronty,...
    prumerna_doba_v_pekarne,prumerna_doba_ve_fronte,...
    pocet_obslouzenych, pocet_neobslouzenych, trzba, usla_trzba, fronta_hist] = ...
    pekarna(pocetPrepazek,maxFronta,dobaCekani,zakazniciph,...
    dobaObsluhy,utrata,pocatecniFronta,dobaSimulace)
if nargin < 1, pocetPrepazek = 1; end % pocet prepazek
if nargin < 2, maxFronta = Inf; end
if nargin < 3, dobaCekani = 15; end % ochota zakaznika pockat si
if nargin < 4, zakazniciph = 100; end % stredni pocet cestujicich k odbaveni za hodinu
if nargin < 5, dobaObsluhy = 2; end % stredni doba stravena na prepazce v minutach
if nargin < 6, utrata = 100; end
if nargin < 7, pocatecniFronta = 0; end
if nargin < 8, dobaSimulace = 8; end

% initializace
time = 0;
fronta = 0;
fronta_hist = [ ];
% 1.sloupec – prichod zakaznika do systemu, 2.sloupec - zacatek obsluhy, 
% 3.sloupec - konec obsluhy, 4.sloupec - uspesne obslouzen, 5.sl - timeout
zakaznici = [ ];
veFronte = [ ];
vObsluze = [ ];
obslouzeno = 0;

obsluha_hist = [];

prichod = time+exprnd(1/zakazniciph);
dalsiOdchod = Inf;
dalsiObsluha = Inf;

% pocatecni fronta
for i = 1:pocatecniFronta
    prichodZakaznika(time);
end

% simulace
while time < dobaSimulace
    fronta_hist(end+1,:) = [time fronta fronta+size(vObsluze,1)];
    obsluha_hist(end+1,:) = [time size(vObsluze,1)];

    % Buï prijde zakaznik nebo zakaznik odejde (skonci obsluha u prepazky)
    
    % bud se nikdo neobsluhuje, nebo prisel driv nez skonci nektery obsluhovany.
    if (prichod < min([Inf,dalsiObsluha,dalsiOdchod]))
        % zapisu ze prisel zakaznik
        prichodZakaznika(prichod);
        % posunu hodiny
        time = prichod;
        % pripravi se cas prichodu dalsiho cloveka
        prichod = time + exprnd(1/zakazniciph); 
    elseif dalsiOdchod < min([Inf,dalsiObsluha]) % zakaznikovi dosla trpelivost
        [time,clovek] = min(veFronte(:,2));
        opustFrontu(clovek)
    else % nastane dalsiObsluha (nekdo odesel od prepazky)
        %okamzik doobslouzeni zakaznika
        [time, prepazka] = min(vObsluze(:,2)); % POZOR tady se posouva cas; vezmu prvniho doobslouzeneho (na tento okamzik posunu hodiny)
        if(fronta > 0) % pokud mam lidi ve fronte, tak doobslouzeneho nahradim novym
            obsluzDalsihoZakaznika(time,veFronte(1,1),prepazka);
            opustFrontu(1);
        else
            vObsluze(prepazka,:) = [ ]; % zakaznik odesel
            dalsiObsluha = min(vObsluze(:,2));
        end
    end
end

%neobslouzeni zakazniku po zaviracce
if ~isempty(veFronte)
    for opozdilec = veFronte(:,1)
        zakaznici(opozdilec,2) = time;
        zakaznici(opozdilec,3) = time;
        zakaznici(opozdilec,4) = 0;
    end
    fronta = 0;
end

% vypocet prumerne delky fronty
prumerna_delka_fronty=sum(diff(fronta_hist(:,1)).*fronta_hist(1:end-1,2))/fronta_hist(end-1,1);
%vypocet pozadovanych casu [v min]
obslouzeni = zakaznici(zakaznici(:,4) == 1,:);
odmitnuti = zakaznici(zakaznici(:,4) == 0,:);
doba_v_pekarne=(obslouzeni(:,3)-obslouzeni(:,1))*60;
doba_v_obsluze=(obslouzeni(:,3)-obslouzeni(:,2))*60;
doba_ve_fronte=(zakaznici(:,2)-zakaznici(:,1))*60;
prumerna_doba_v_pekarne=mean(doba_v_pekarne);
prumerna_doba_v_obsluze=mean(doba_v_pekarne);
prumerna_doba_ve_fronte=mean(doba_ve_fronte);
pocet_obslouzenych = sum(zakaznici(:,4) == 1);
pocet_neobslouzenych = sum(zakaznici(:,4) == 0);
trzba = sum(obslouzeni(:,5));
usla_trzba = sum(odmitnuti(:,5));

% nakresli vysledek 
if nargout < 1
    figure
    subplot(2,2,[1,3])
    %subplot(2,2,1)
    vykresliFrontu
    subplot(2,2,2)
    vykresliDobu
    subplot(2,2,4)
    vykresliPenize
    %subplot(2,2,3)
    %plot(obsluha_hist(:,1),obsluha_hist(:,2))
    
    % vypis hodnoty
    disp(['Prumerne hodnoty'])
    disp(['   delka fronty: ' num2str(round(prumerna_delka_fronty))])
    disp(['   doba v pekarne: ' num2str(prumerna_doba_v_pekarne)])
    disp(['   doba ve fronte: ' num2str(prumerna_doba_ve_fronte)])
    disp(['Obslouzeno ' num2str(pocet_obslouzenych) ...
        ' lidi za ' num2str(round(trzba)) ' penez'])
    disp(['Neobslouzeno ' num2str(pocet_neobslouzenych) ...
        ' lidi s ' num2str(round(usla_trzba)) ' penezi'])
end
    
    function vykresliFrontu
        % vykresleni vyvoje fronty
        stairs(fronta_hist(:,1),fronta_hist(:,3),'b') % pocet lidi v pekarne (prepazky + fronta)
        hold on
        stairs(fronta_hist(:,1),fronta_hist(:,2),'g') % pocet lidi ve fronte
        plot(xlim,[1,1]*prumerna_delka_fronty,'g--');
        
        %yyaxis right
        %stairs(odmitnuti(:,1),cumsum(odmitnuti(:,4)==0),'r') % pocet odmitnutych zakazniku
        %plot([fronta_hist(1,1),fronta_hist(end,1)],[1,1]*prumerna_delka_fronty,'g--');
        title('Vyvoj fronty a poctu zákazníku v pekarne')
        xlabel('Cas [hodiny]')
        ylabel('Pocet zakazniku')
        legend('Pocet zakazniku v pekarne','Velikost fronty','Prumer','Neobslouzeni')
        hold off
    end

    function vykresliDobu
        %vykresleni doby stravene v pekarne
        histogram(doba_v_obsluze,35)
        title('Graf doby stravene v pekarne')
        xlabel('stravena doba [minuty]')
        ylabel('Pocet zakazniku') 
        hold on
        histogram(doba_ve_fronte,35)
        line([1,1]*prumerna_doba_v_pekarne,ylim,'Color','r')
        
        legend('v obsluze', 've fronte', 'prumer')
       % plot()
       hold off
    end

    function vykresliPenize
        obso = sortrows(obslouzeni,3);
        stairs(obso(:,3),cumsum(obso(:,5)));
        hold on
        odmi = sortrows(odmitnuti,3);
        stairs(odmi(:,3),cumsum(odmi(:,5)),'r');
        hold off
        title('Trzba a usla trzba')
        xlabel('cas')
        ylabel('trzba')
        legend('trzba','usla trzba','Location','northwest')
    end

    function prichodZakaznika(prichod)
        zakaznici(end+1,1) = prichod; % pridame zakaznika do systemu
        zakaznici(end,5) = gamrnd(utrata,1); %normrnd(utrata,0.25*utrata); % ochota utratit
        % prichozi zakaznik musi cekat ve fronte nebo se rovnou obslouzi
        if(size(vObsluze,1) < pocetPrepazek) %existuje volna prepazka
            obsluzDalsihoZakaznika(prichod,size(zakaznici,1));
        else %zakaznik musi cekat ve fronte
            if fronta < maxFronta 
                zakaznikCeka(prichod,size(zakaznici,1));
            else % zakaznik odesel jinam, nevejde se do fronty
                zakaznici(end,2) = prichod;
                zakaznici(end,3) = prichod;
                zakaznici(end,4) = 0; % neobslouzen
            end
        end
    end

    function obsluzDalsihoZakaznika(zacatek,i,prepazka)
        konecObsluhy = zacatek + exprnd(dobaObsluhy/60);
        if nargin < 3 
            vObsluze(end+1,1:2) = [i konecObsluhy];
        else % nahradi zakaznika dalsim
            %odchazejici = vObsluze(prepazka,1);
            vObsluze(prepazka,1:2) = [i konecObsluhy];
        end
        dalsiObsluha = min(vObsluze(:,2));
        zakaznici(i,2) = zacatek; % zacatek obsluhy
        zakaznici(i,3) = konecObsluhy;  % konec obl., tzn. cas+exprnd(1/mu)
        zakaznici(i,4) = 1; % zakaznik obslouzen
        obslouzeno = obslouzeno+1; % inkrementuji pocet obslouzenych
    end

    function zakaznikCeka(kdy,kdo)
        if dobaCekani < Inf
            casOdchodu = kdy + exprnd(dobaCekani/60);
        else 
            casOdchodu = Inf;
        end
        fronta = fronta+1; % zakaznik pocka ve fronte
        veFronte(end+1,1:2) = [kdo casOdchodu];
        dalsiOdchod = min(veFronte(:,2));

        zakaznici(kdo,2) = casOdchodu; 
        zakaznici(kdo,3) = casOdchodu; % do kdy vydrzi ve fronte
        zakaznici(kdo,4) = 0; % neobslouzen dosud
    end
    
    function opustFrontu(clovek)
        veFronte(clovek,:) = [ ]; % clovek odesel z fronty
        fronta = fronta-1;
        dalsiOdchod = min(veFronte(:,2));
    end
end
