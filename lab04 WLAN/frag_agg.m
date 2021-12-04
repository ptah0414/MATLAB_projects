%-------------------------------------------
%  INC4103: fragmentation & aggregation
%  by E.-C. Park
%-------------------------------------------
clear; clc;
close all;

% frags for fragmentation and A_MSDU/A_MPDU 
FRAG_ENABLE = 0;
A_MSDU_ENABLE = 0;
A_MPDU_ENABLE = 1;



BEB_ENABLE = 0;
    
%-------------------------------------------
% ASSUMPTIONS
%-------------------------------------------
% A1. Carrier sensing is perfect so that all the users can completely 
% detect busy channel
% A2. The bit error rate is constant
% A3. All the users always have data to send 

%------------------------------------------
% PARAMETERS & VARIABLES
%------------------------------------------
N_slot = 1000000;         % total number of slots
N_user = 3;             % number of users
%N_frag = 3*ones(1,N_user);     % number of fragments
N_frag = [1 1 1];

%N_agg = 4*ones(1,N_user);      % number of packets aggreagted
N_agg = [2 4 8];

%BER = 0;
BER = 10^-5;                 % bit error rate


TX_rate = 24*10^6*ones(1,N_user); 
                        % transmission rate 

CW_min = 16*ones(1,N_user);             % minimum contention window

L_pkt = 1000*ones(1,N_user);
L_frag = L_pkt./N_frag;
                        % packet size (byte)

if (A_MSDU_ENABLE == 1)
    FER = 1-(1-BER).^(L_pkt.*N_agg*8)
elseif (A_MPDU_ENABLE == 1) 
    FER = 1-(1-BER).^(L_pkt*8)    % frame error rate
elseif (FRAG_ENABLE == 1)
    FER = 1-(1-BER).^(L_frag*8)
end


% 802.11g MAC/PHY spec.
T_slot = 9*10^-6;      % time slot = 20 us
L_macH = 28;            % length of the MAC Header (bytes)
T_phyH = 44*10^-6;     % PHY Header transmission time (sec)
T_sifs = 10*10^-6;      % SIFS time (sec)
L_ack = 14;             % length of ACK (byte)
L_back = L_ack + 8;
Basic_rate = 6*10^6;    % basic rate for ACK (bit/sec)
T_ack = T_phyH + L_ack*8/Basic_rate;    
                        % ACK transmission time (sec)
T_back = T_phyH + L_ack*8/Basic_rate;                        
if (FRAG_ENABLE == 1)
    T_data = T_phyH + (L_macH + L_frag)*8./TX_rate; 
                        % data frame transmission time (sec)
    T_txslot = floor( N_frag.*(T_data + T_sifs + T_ack)/T_slot);   
            % number of slots required to transmit one packet (consisting
            % of N fragmetns)
elseif (A_MSDU_ENABLE == 1)
    T_data = T_phyH + (L_macH + N_agg .* L_pkt)*8./TX_rate; 
                        % data frame transmission time (sec)
    T_txslot = floor( (T_data + T_sifs + T_ack)/T_slot);   
elseif (A_MPDU_ENABLE == 1)
    T_data = T_phyH + N_agg.*(L_macH + L_pkt)*8./TX_rate; 
    T_txslot = floor( (T_data + T_sifs + T_back)/T_slot);   
end
AIFSN = 3*ones(1,N_user);  % AIFSN for EDCA

CW_max = 1024;              
            % when BEB is enabled, CW is doubled if collision occurs
            % its maximum value is CW_max
CW = CW_min.*ones(1,N_user);                % initial contention window 


%initial backoff counter & aifs
bc = ceil(rand(1,N_user).*CW);
aifs = AIFSN;


tx_state = zeros(N_slot,N_user);
% tx_state(i,j) = transmission status at time slot i for user j
STATE_BC  = 0;   % backoff state
STATE_TX  = 1;   % transmission state (without collision)
STATE_CS  = 2;   % carrier-sensing state
STATE_COL = 3;   % collision state

n_txnode = zeros(N_slot,1); % number of TX nodes


n_access = zeros(1,N_user);
    % number of channel access per user
n_collision = zeros(1,N_user);
    % number of collisions per user
n_success = zeros(1,N_user);
    % number of successful channel access without collision
    % n_access = n_collision + n_success

i=2;

%------------------------------------------------------------------
% START SIMULATION
%------------------------------------------------------------------
while(i < N_slot-1)
    
    % check if channel is idle
    if (n_txnode == 0)
        for j=1:N_user
            if (aifs(j) > 0)
                aifs(j) = aifs(j) - 1;
                % wait for AIFS
            end
        end
        for j=1:N_user
            if (aifs(j) == 0)
                bc(j) = bc(j) -1; 
            end
        end
        % decrement backoff counter by 1 for users after waiting for AIFSN
    end
    % if channel is busy, do not change aifs & backoff counter 
    
    % check whether BC = 0
    for j=1:N_user
        if (bc(j) == 0)
            tx_state(i:(i+T_txslot(j)-1),j) = STATE_TX;
            % set sate from i to i+T_txslot-1 = STATE_TX
            n_txnode = n_txnode + 1;          
            n_access(j) = n_access(j)+1;

            bc(j) = ceil(rand*CW(j));
            aifs(j) = AIFSN(j);
            % re-select a new random backoff & aifs
        end
    end
    
    % update state     
    % if channel is busy
    if (n_txnode ~= 0 )
        % if at least one node is in transmision state
        max_duration = max( T_txslot.*(tx_state(i,:)==STATE_TX) );
        for (j=1:N_user)
            if (tx_state(i,j) ~= STATE_TX)
                tx_duration = i+max_duration-1;
                tx_state(i:tx_duration,j) = STATE_CS;
                % set state = carrier sensing
                aifs(j) = AIFSN(j);
                % reset aifs after sensing busy channel
            end
        end

        % check collision
        if (n_txnode == 1)
            % only one node accesses channel, i.e., no collision
            for (j=1:N_user)
                if (tx_state(i,j) == STATE_TX)
                    if (FRAG_ENABLE == 1)
                        n_success(j) = n_success(j) + sum(rand(1,N_frag(j))>FER(j));
                    elseif (A_MSDU_ENABLE == 1)
                        flag_success = rand > FER(j);
                        n_success(j) = n_success(j) + flag_success;                       
                        if ( (flag_success == 0) && (BEB_ENABLE == 1))
                            CW(j) = min(CW(j) * 2, CW_max); 
                        end                    
                    elseif (A_MPDU_ENABLE == 1)
                        n_success(j) = n_success(j) + sum(rand(1,N_agg(j))>FER(j));
                    end
                    % BEB here...
                    if (BEB_ENABLE == 1)
                        CW(j) = CW_min(j);
                    end
                end
            end
        elseif (n_txnode > 1)
            % more than two nodes access channel => collision
            for (j=1:N_user)
                if (tx_state(i,j) == STATE_TX)
                    tx_duration = i+T_txslot(j)-1;
                    tx_state(i:tx_duration,j) = STATE_COL;
                    % set state = collision
                    n_collision(j) = n_collision(j)+1;
                    % BEB here.....
                    if (BEB_ENABLE == 1)
                        CW(j) = min(CW(j) * 2, CW_max); 
                    end
                end
            end        
        end % end for collision-check
      
        i = i + max_duration+1;   % increase time index by T_txslot
        n_txnode = 0;
    else
        i=i+1;  % increase time index by 1        
    end % end for busy-channel
    
end

%------------------------------------------------------------------


%------------------------------
% statistics
%------------------------------
%n_access 
%n_collision
if (FRAG_ENABLE == 1)
    per_user_th = (n_success .* L_frag * 8) / (N_slot*T_slot) / 10^6  % Mb/s
elseif (A_MSDU_ENABLE == 1)
    per_user_th = (n_success .* N_agg .* L_pkt * 8) / (N_slot*T_slot) / 10^6  % Mb/s
elseif (A_MPDU_ENABLE == 1)
    per_user_th = (n_success .* L_pkt * 8) / (N_slot*T_slot) / 10^6  % Mb/s
end
total_th = sum(per_user_th) % Mb/s
%fairness_index = total_th^2 / (N_user * sum(per_user_th.*per_user_th))
    % fraction of time slot occupied without collision
%collision_prob = sum(n_collision)/sum(n_access)
%utilization = sum(sum(tx_state==1)) / N_slot

