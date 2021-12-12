%-------------------------------------------
%  INC4103: IEEE 802.11 DCF & EDCA
% (1) Derive throghput model of DCF
% (2) Understand service differentiation of EDCA
% (3) Understand throughput-fairness of DCF
%-------------------------------------------
clear; clc;
close all;

BEB_ENABLE = 0;
    
%-------------------------------------------
% ASSUMPTIONS
%-------------------------------------------
% A1. Carrier sensing is perfect so that all the users can completely 
% detect busy channel
% A2. There is no transmssion failure due to poor quality of wireless
% channel, i.e., transmission failure only occurs due to collision
% A3. All the users always have data to send 

%------------------------------------------
% PARAMETERS & VARIABLES
%------------------------------------------
N_slot = 1000000;         % total number of slots
N_user = 2;             % number of users

R_data = 24*10^6*ones(1,N_user); 
%R_data = [12 24 48]*10^6;
                        % transmission rate 

%CW_min = 8*ones(1,N_user);             % minimum contention window
CW_min = [8 262144];

AIFSN = 2*ones(1,N_user);  % AIFSN for EDCA, default = 3 considering DIFS
%AIFSN = [2 10];

L_data = 1000*ones(1,N_user);
                        % data frame size (byte)
%L_data = [500 1000 2000];

% 802.11g MAC/PHY spec.
T_slot = 9*10^-6;      % time slot = 20 us
L_macH = 28;            % length of the MAC Header (bytes)
T_phyH = 44*10^-6;     % PHY Header transmission time (sec)
T_sifs = 10*10^-6;      % SIFS time (sec)
L_ack = 14;             % length of ACK (byte)
R_ack = 6*10^6;    % basic rate for ACK (bit/sec)
T_ack = T_phyH + L_ack*8/R_ack;    
                        % ACK transmission time (sec)
T_data = T_phyH + (L_macH + L_data)*8./R_data; 
                        % data frame transmission time (sec)

T_txslot = floor( (T_data + T_sifs + T_ack)/T_slot);   
            % number of slots required to transmit one data frame

CW_max = 1024;              
            % when BEB is enabled, CW is doubled if collision occurs
            % its maximum value is CW_max
CW = CW_min.*ones(1,N_user);                % initial contention window 


%initial backoff counter & aifs
bc = ceil(rand(1,N_user).*CW);
aifs = AIFSN;
aifs_reset = zeros(1,N_user);

tx_state = zeros(N_slot,N_user);
% tx_state(i,j) = transmission status at time slot i for user j
STATE_BC  = 0;   % backoff state
STATE_TX  = 1;   % transmission state (without collision)
STATE_CS  = 2;   % carrier-sensing state
STATE_COL = 3;   % collision state

n_txnode = 0; % number of TX nodes


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
                %if (aifs_reset(j) == 1)
                    bc(j) = bc(j) -1; 
                %elseif (aifs_reset(j) == 0)
                %    bc(j) = 0;
                %end
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
                %aifs_reset(j) = 1;
                % reset aifs after sensing busy channel
            end
        end

        % check collision
        if (n_txnode == 1)
            % only one node accesses channel, i.e., no collision
            for (j=1:N_user)
                if (tx_state(i,j) == STATE_TX)
                    n_success(j) = n_success(j) + 1;
                    %aifs_reset(j) = 0;
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
                    %aifs_reset(j) = 1;
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
        i=i+1;  % increase time index by 1 (if n_txnode = 0)        
    end 
    
end

%------------------------------------------------------------------


%------------------------------
% statistics
%------------------------------
n_access 
t_access = n_access.*T_data
    % channel access time
%n_collision
%n_success
%per_user_access = n_access/(sum(n_access))

per_user_th = (n_success .* L_data * 8) / (N_slot*T_slot) / 10^6  % Mb/s
total_th = sum(per_user_th) % Mb/s
fairness_index = total_th^2 / (N_user * sum(per_user_th.*per_user_th))

%collision_prob = sum(n_collision)/sum(n_access)
%utilization = sum(sum(tx_state==1)) / N_slot

