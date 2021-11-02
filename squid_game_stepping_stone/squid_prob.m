M_bridge = 18;
N_user = 16;
times = 41000605;

survived_times = zeros(1, N_user);
survival_prob = zeros(1, N_user);

for i = 1:times
    result = squid_game(M_bridge, N_user);
    for j = 1:N_user
        survived_times(1, j) = survived_times(1, j) + result(j, 1);
    end
end

times
survived_times
survival_prob = survived_times/times*100 +"%"