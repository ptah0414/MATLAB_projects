%-------------------------------------------
%  INC4103: Random backoff
%  - random backoff ��Ŀ���� ����
%
%-------------------------------------------
clear;
close all;

DEBUG_MODE = 0;
    % debug mode������ ������ �����ϱ� ���� ��ü ���Լ��� �۰� �����ϰ�
    % �� �ܸ��� ���� ���¸� �׷����� ǥ����.

BEB_ENABLE = 1;
    % binary exponential backoff ���� ����

%-------------------------------------------
% ����
%-------------------------------------------
% A1. �ٸ� �ܸ��� ������ ��Ȯ�� ������ (hidden node ����)
% A2. ���� �浹�� ������ ���� ���д� ����
% A3. ��� �ܸ��� �׻� ������ ��Ŷ�� ������ ����

%------------------------------------------
% �Ķ���Ϳ� ���� ����/�ʱ�ȭ
%------------------------------------------
N_slot = 1000000;       % ��ü ���� ��
N_user = 10;             % ����� ��
CW_min = 16*ones(1,N_user);   % contention window �ּҰ�
%CW_min = [16 32 64 64];
L_pkt = 1000*ones(1,N_user);
                        % ��Ŷ ũ�� (byte)
%L_pkt = [500, 1000, 1000, 2000];                        

TX_rate = 24*10^6*ones(1,N_user);      
                        % ���� �ӵ� (24 Mb/s)
%TX_rate = [24 24 12 6]*10^6; 

T_slot = 10*10^-6;      % time slot ũ�� = 10 us
T_txslot = floor(8*L_pkt./TX_rate./T_slot);   
            % ��Ŷ �ϳ��� �����ϴµ� �ҿ�Ǵ� ���� ����

CW_max = 1024;              
            % CW�� �ִ밪 
            % BEB �� ���Ǵ� ���, �浹�� CW�� 2�� ���� �ִ밪=CW_max
CW = CW_min;                % �ʱ� CW��

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
           % j��° ����ڰ� i��° ��Ŷ ���۽� ����ϴ� backoff counter           % 
    DEBUG_BC_INDEX = [1 1 1];       
           % �� ����ڰ� ���� ���° ��Ŷ�� ���� �õ��ϴ��� 
end


% �ʱ� ����� ī���� �� ����
bc = zeros(1,N_user);
if (DEBUG_MODE == 0)
    bc = ceil(rand(1,N_user).*CW);
    % [1~CW]������ ������ ��
else
    bc = DEBUG_BC(1,:);
end



tx_state = zeros(N_slot,N_user);
% tx_state(i,j) = i��° slot���� j��° ������� ����
STATE_BC  = 0;   % ����� ���� (idle channel)
STATE_TX  = 1;   % ���� ���� (�浹����)
STATE_CS  = 2;   % ä�� ���� (busy channel)
STATE_COL = 3;   % ���� �浹

n_txnode = zeros(N_slot,1); % i��° ���Կ��� ���� �ܸ� ��

n_access = zeros(1,N_user);
    % �ܸ��� ���� �õ� ȸ��
n_collision = zeros(1,N_user);
    % �ܸ��� ���� �浹 ȸ��
n_success = zeros(1,N_user);
    % �ܸ��� ���� ���� ȸ��
    % n_access = n_collision + n_success

i=2;

%------------------------------------------------------------------
% �ùķ��̼� ����
%------------------------------------------------------------------
while(i < N_slot-1)
    
    % ä���� idle���� üũ (n_txnode=0�̸� idle)
    if (n_txnode == 0)
        bc = bc -1;
        % ��� �ܸ��� ����� ī���� 1�� ����
    end
    % ä���� busy�� ���, ����� ī���� ��ȭ ����
    
    % ����� ī���� �� üũ
    for j=1:N_user
        if (bc(j) == 0)
            %tx_state(i:(i+T_txslot-1),j) = STATE_TX;
            % bug fix, 2018/04/06 Park
            tx_state(i:(i+T_txslot(j)-1),j) = STATE_TX;
            % set sate from i to i+T_txslot-1 = STATE_TX
            % ���´� �ϴ� STATE_TX�� �����ϰ�
            % ���� ���� �浹���ο� ���� STATE_COL���� ����
            n_txnode = n_txnode + 1;          
            n_access(j) = n_access(j)+1;
            
            % ���� ���� ���ο� ����� ī���� ����
            if (DEBUG_MODE == 0)
                bc(j) = ceil(rand*CW(j));                
            else
                DEBUG_BC_INDEX(j) = DEBUG_BC_INDEX(j)+1;
                bc(j) = DEBUG_BC(DEBUG_BC_INDEX(j),j);
            end            
        end
    end
    
    % ���� ������Ʈ
    % ä���� busy�� ��� --> �ٸ� �ܸ��� carrier sensing
    if (n_txnode ~= 0 )
        % �ϳ� �̻��� �ܸ��� �����ϰ� �ִ� ���
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
                % ���� ��带 ������ �ٸ� �ܸ��� ���� = carrier sensing
            end
        end

        % �浹 ���� üũ
        if (n_txnode == 1)
            % �ϳ��� �ܸ��� �����ϴ� ��� = ���� ����
            for (j=1:N_user)
                if (tx_state(i,j) == STATE_TX)
                    n_success(j) = n_success(j) + 1;
                    % BEB ���� : ���� ������ CW = CW_min
                    if (BEB_ENABLE == 1)
                        CW(j) = CW_min(j);
                    end
                end
            end
        elseif (n_txnode > 1)
            % �� �̻��� �ܸ��� ���� => ���� �浹
            for (j=1:N_user)
                if (tx_state(i,j) == STATE_TX)
                    tx_duration = i+max_tx_time-1;
                    tx_state(i:tx_duration,j) = STATE_COL;
                    % ���� �ܸ��� ���¸� STATE_COL���� ����
                    n_collision(j) = n_collision(j)+1;
                    % BEB ����: ���� �浹�� CW = 2*CW
                    if (BEB_ENABLE == 1)
                        CW(j) = min(CW(j) * 2, CW_max); 
                    end
                end
            end        
        end 
      
        %i = i + max(T_txslot)+1;   % increase time index by T_txslot
        % bug fix, 2018/04/06 Park
        i = i + max_tx_time+1;   
        % ���۴ܸ��� �����ϴ� ��� ������ ���� �ð���ŭ ���
        n_txnode = 0;
    else
        i=i+1;  % ���� �ܸ��� ���� ��� �ð� 1 ����
    end % end for busy-channel
    
end
% �ùķ��̼� ����
%------------------------------------------------------------------

% �ܸ��� ���� ǥ��
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
% �ùķ��̼� ���: ���۽õ�/�浹/���� ȸ��
%------------------------------
n_access 
n_collision
n_success

if (DEBUG_MODE ~= 1)
per_user_th = (n_success .* L_pkt * 8) / (N_slot*T_slot) / 10^6  
 % �� �ܸ��� throughput (Mb/s)
total_th = sum(per_user_th) % ��ü throughput (Mb/s)
fairness_index = total_th^2 / (N_user * sum(per_user_th.*per_user_th))
    % fairness index ���
collision_prob = sum(n_collision)/sum(n_access) 
    % ���� �浹 Ȯ��
utilization = sum(sum(tx_state==1)) / N_slot
    % ��ü �ð���� ���� ������ �ҿ��� �ð� ����
end
