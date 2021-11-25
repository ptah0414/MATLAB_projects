%-------------------------------------------
%  INC4103: Random backoff
%  - random backoff 메커니즘 이해
%
%-------------------------------------------
clear;
close all;

DEBUG_MODE = 0;
    % debug mode에서는 동작을 이해하기 위해 전체 슬롯수를 작게 설정하고
    % 각 단말의 동작 상태를 그래프로 표현함.

BEB_ENABLE = 1;
    % binary exponential backoff 설정 여부

%-------------------------------------------
% 가정
%-------------------------------------------
% A1. 다른 단말의 동작을 정확이 감지함 (hidden node 없음)
% A2. 전송 충돌을 제외한 전송 실패는 없음
% A3. 모든 단말은 항상 전송할 패킷을 가지고 있음

%------------------------------------------
% 파라미터와 변수 선언/초기화
%------------------------------------------
N_slot = 1000000;       % 전체 슬롯 수
N_user = 10;             % 사용자 수
CW_min = 16*ones(1,N_user);   % contention window 최소값
%CW_min = [16 32 64 64];
L_pkt = 1000*ones(1,N_user);
                        % 패킷 크기 (byte)
%L_pkt = [500, 1000, 1000, 2000];                        

TX_rate = 24*10^6*ones(1,N_user);      
                        % 전송 속도 (24 Mb/s)
%TX_rate = [24 24 12 6]*10^6; 

T_slot = 10*10^-6;      % time slot 크기 = 10 us
T_txslot = floor(8*L_pkt./TX_rate./T_slot);   
            % 패킷 하나를 전송하는데 소요되는 슬롯 개수

CW_max = 1024;              
            % CW의 최대값 
            % BEB 가 사용되는 경우, 충돌시 CW값 2배 증가 최대값=CW_max
CW = CW_min;                % 초기 CW값

if (DEBUG_MODE == 1)
    N_user = 3;
    T_txslot = [5 5 5];    
    N_slot = 50;
    DEBUG_BC =[2 5 4;
               7 8 3;
               4 2 8;
               5 5 7;
               3 8 4];
           % DEBUG_BC(i,j) 
           % j번째 사용자가 i번째 패킷 전송시 사용하는 backoff counter           % 
    DEBUG_BC_INDEX = [1 1 1];       
           % 각 사용자가 현재 몇번째 패킷을 전송 시도하는지 
end


% 초기 백오프 카운터 값 설정
bc = zeros(1,N_user);
if (DEBUG_MODE == 0)
    bc = ceil(rand(1,N_user).*CW);
    % [1~CW]사이의 임의의 값
else
    bc = DEBUG_BC(1,:);
end



tx_state = zeros(N_slot,N_user);
% tx_state(i,j) = i번째 slot에서 j번째 사용자의 상태
STATE_BC  = 0;   % 백오프 상태 (idle channel)
STATE_TX  = 1;   % 전송 성공 (충돌없음)
STATE_CS  = 2;   % 채널 센싱 (busy channel)
STATE_COL = 3;   % 전송 충돌

n_txnode = zeros(N_slot,1); % i번째 슬롯에서 전송 단말 수

n_access = zeros(1,N_user);
    % 단말별 전송 시도 회수
n_collision = zeros(1,N_user);
    % 단말별 전송 충돌 회수
n_success = zeros(1,N_user);
    % 단말별 전송 성공 회수
    % n_access = n_collision + n_success

i=2;

%------------------------------------------------------------------
% 시뮬레이션 시작
%------------------------------------------------------------------
while(i < N_slot-1)
    
    % 채널이 idle한지 체크 (n_txnode=0이면 idle)
    if (n_txnode == 0)
        bc = bc -1;
        % 모든 단말이 백오프 카운터 1씩 감소
    end
    % 채널이 busy인 경우, 백오프 카운터 변화 없음
    
    % 백오프 카운터 값 체크
    for j=1:N_user
        if (bc(j) == 0)
            %tx_state(i:(i+T_txslot-1),j) = STATE_TX;
            % bug fix, 2018/04/06 Park
            tx_state(i:(i+T_txslot(j)-1),j) = STATE_TX;
            % set sate from i to i+T_txslot-1 = STATE_TX
            % 상태는 일단 STATE_TX로 설정하고
            % 이후 전송 충돌여부에 따라 STATE_COL으로 변경
            n_txnode = n_txnode + 1;          
            n_access(j) = n_access(j)+1;
            
            % 전송 이후 새로운 백오프 카운터 설정
            if (DEBUG_MODE == 0)
                bc(j) = ceil(rand*CW(j));                
            else
                DEBUG_BC_INDEX(j) = DEBUG_BC_INDEX(j)+1;
                bc(j) = DEBUG_BC(DEBUG_BC_INDEX(j),j);
            end            
        end
    end
    
    % 상태 업데이트
    % 채널이 busy한 경우 --> 다른 단말은 carrier sensing
    if (n_txnode ~= 0 )
        % 하나 이상의 단말이 전송하고 있는 경우
        % bug fix, 2018/04/06 Park
        % determine tx_duration
        %max_tx_time = 0;
        %for (j=1:N_user)
        %    if (tx_state(i,j) == STATE_TX)
        %        if (max_tx_time < T_txslot(j))
        %            max_tx_time = T_txslot(j);
        %        end                
        %    end
        %end
        max_tx_time = max ( (tx_state(i,:) == STATE_TX).*T_txslot );
        
        for (j=1:N_user)
            if (tx_state(i,j) ~= STATE_TX)
                %tx_duration = i+max(T_txslot)-1;
                % bug fix, 2018/04/06 Park
                tx_duration = i+max_tx_time-1;
                tx_state(i:tx_duration,j) = STATE_CS;
                % 전송 노드를 제외한 다른 단말의 상태 = carrier sensing
            end
        end

        % 충돌 여부 체크
        if (n_txnode == 1)
            % 하나의 단말만 전송하는 경우 = 전송 성공
            for (j=1:N_user)
                if (tx_state(i,j) == STATE_TX)
                    n_success(j) = n_success(j) + 1;
                    % BEB 동작 : 전송 성공시 CW = CW_min
                    if (BEB_ENABLE == 1)
                        CW(j) = CW_min(j);
                    end
                end
            end
        elseif (n_txnode > 1)
            % 둘 이상의 단말이 전송 => 전송 충돌
            for (j=1:N_user)
                if (tx_state(i,j) == STATE_TX)
                    tx_duration = i+max_tx_time-1;
                    tx_state(i:tx_duration,j) = STATE_COL;
                    % 전송 단말의 상태를 STATE_COL으로 변경
                    n_collision(j) = n_collision(j)+1;
                    % BEB 동작: 전송 충돌시 CW = 2*CW
                    if (BEB_ENABLE == 1)
                        CW(j) = min(CW(j) * 2, CW_max); 
                    end
                end
            end        
        end 
      
        %i = i + max(T_txslot)+1;   % increase time index by T_txslot
        % bug fix, 2018/04/06 Park
        i = i + max_tx_time+1;   
        % 전송단말이 존재하는 경우 슬롯이 전송 시간만큼 경과
        n_txnode = 0;
    else
        i=i+1;  % 전송 단말이 없는 경우 시간 1 증가
    end % end for busy-channel
    
end
% 시뮬레이션 종료
%------------------------------------------------------------------

% 단말별 상태 표시
if (DEBUG_MODE == 1)
    
figure;
axis([0 N_slot 0 N_user+1]);
title('User state');
hold on;
for i = 1:N_slot
    for j = 1:N_user
        switch tx_state(i,j),
        case STATE_BC,   plot(i,j,'g+');
        case STATE_TX,   plot(i,j,'bs'); 
        case STATE_CS,   plot(i,j,'kv'); 
        case STATE_COL,  plot(i,j,'rx'); 
        end
    end
end
hold off;
xlabel('slot index');
ylabel('station index');
end

%------------------------------
% 시뮬레이션 결과: 전송시도/충돌/성공 회수
%------------------------------
n_access 
n_collision
n_success

if (DEBUG_MODE ~= 1)
per_user_th = (n_success .* L_pkt * 8) / (N_slot*T_slot) / 10^6  
 % 각 단말별 throughput (Mb/s)
total_th = sum(per_user_th) % 전체 throughput (Mb/s)
fairness_index = total_th^2 / (N_user * sum(per_user_th.*per_user_th))
    % fairness index 계산
collision_prob = sum(n_collision)/sum(n_access) 
    % 전송 충돌 확률
utilization = sum(sum(tx_state==1)) / N_slot
    % 전체 시간대비 전송 성공에 소요한 시간 비율
end
