mu_min = 50;    % minimalni odbaveni
mu_max = 150;   % maximalni odbaveni
mu_step = 10;   % krok v odbaveni
Tmax = 16;      % doba simulace
Tsteps = 160;     % pocet kroku behem hodiny
N = 160;        % pocet pozorovani

start = now;
k_max = round((mu_max-mu_min)/mu_step);
fronta = zeros(k_max+1,N,Tsteps);
Tstep = Tmax/Tsteps;

parfor k = 1:(k_max+1)
    for n = 1:N
        [~,~,~,~,~,~,~,~,historie] = pekarna(1,Inf,15,100,60/(mu_min+(k-1)*mu_step),100,0,Tmax);
        for ti = 1:Tsteps
            H = historie(historie(:,1)<ti*Tstep & historie(:,1)>(ti-1)*Tstep,2);
            fronta(k,n,ti) = mean(H);
        end
    end
end

stop = now;
dobaVypoctu = 86400 * (stop - start),

F = permute(mean(fronta,2),[1 3 2]);

%%
%plot(F');
surf(Tstep:Tstep:Tmax,mu_min+mu_step*(0:k_max),F)
xlabel('cas (h)')
ylabel('obslouzení za hodinu')
zlabel('vyvoj fronty')