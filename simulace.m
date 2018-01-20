k_max = 10; % pocet prepazek
N = 100; % pocet pozorovani


start = now;
trzba = zeros(k_max,N);
cekani = zeros(k_max,N);
neobslouzeni = zeros(k_max,N);

parfor k = 1:k_max
    for n = 1:N
        [~,~,dobaVpekarne,~,~,bezObsluhy,denniTrzba,~] = pekarna(k);
        trzba(k,n) = denniTrzba;
        cekani(k,n) = dobaVpekarne;
        neobslouzeni(k,n) = bezObsluhy;
    end
end

stop = now;
dobaVypoctu = 86400 * (stop - start),