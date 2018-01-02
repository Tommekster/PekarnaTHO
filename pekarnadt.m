function [fronta,odmitnuto] = pekarnadt(tokPrichodu, tokVyrizeni, ...
    pocetPrepazek, maxFronta, dnu, pocatecniFronta, doba)
if nargin < 1, tokPrichodu = 0.05; end
if nargin < 2, tokVyrizeni = 0.1; end
if nargin < 3, pocetPrepazek = 1; end
if nargin < 4, maxFronta = Inf; end
if nargin < 5, dnu = 1; end
if nargin < 6, pocatecniFronta = zeros(dnu,1); end
if nargin < 7, doba = 28800; end % 8 hodin
% inicializace
nahoda = rand(dnu,doba);
fronta = zeros(dnu,doba+1);
fronta(:,1) = pocatecniFronta;
prichod = nahoda < tokPrichodu;
odmitnuto = zeros(dnu);

% simulace
for t = 1:doba
    fronty = fronta(:,t);
    nahody = nahoda(:,t);
    prichody = prichod(:,t);
    for d = 1:dnu
        s = fronty(d);
        x = nahody(d);
        if prichody(d) % prichod
            if s < maxFronta
                fronta(d,t+1) = s+1;
            else
                odmitnuto(d) = odmitnuto(d)+1;
            end
        elseif x < tokPrichodu + min(s,pocetPrepazek)*tokVyrizeni % vyrizeni
            fronta(d,t+1) = s-1; % nulu testovat nemusim diky minimu
        end
    end
end

% ukaz vysledek
if nargout < 1
    plot(fronta)
    if length(odmitnuto) > 1 
        plot(odmitnuto)
    else
        disp(['odmitnuto ' odmitnuto])
    end
end