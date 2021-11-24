%-------------------------------------------
% INC4103: �����ٸ� �ǽ�3
% ä�� ���� ����ǰ� AMC ����� 
%-------------------------------------------

% 4���� �����ٸ� ��å �����
% case1: max-min
% case2: proportional fair
% case3: round-robin
% case4: max-SNR

% �ϳ��� �ð� ������ �� ���� ����ڿ��� �Ҵ�ȴٰ� ����

clear; clc;
close all;

N_slot = 1000;    % ��ü ���� ��
N_user = 4;       % ����� ��
distance = [200 300 400 500]; % ���������� �Ÿ�

% SNR���� ���� 4���� MCS ���
SNR_TH = [30 20 10];     % unit: dB
TX_RATE = [16 8 4 1]; % unit: bit/sec
% if SNR>=30 dB      --> 16 bit/sec (64QAM 2/3)
% if 20<= SNR <30 dB --> 8 bit/sec (16QAM 1/2)
% if 10<= SNR <20 dB --> 4 bit/sec (QPSK 1/2)
% if SNR < 10 dB     --> 1 bit/sec (BPSK 1/2)

% ä�� ���� �Ķ����
P_TX = 20;      % ���� ���� (dBm)
alpha = 3.5;    % path-loss exponent
PL_0 = 40;       % ���ذŸ�(D_0)������ ��� �ս�
D_0 = 10;        % ���ذŸ�
SHADOW_STD = 10;  % shadowing ǥ������;
NOISE = -80;     % ���� ���� (dBm)

% ���� ���� & �ʱ�ȭ  
% �� �����ٸ� ����� ����ں� ���� ���� ������ ��
bytes_sent_case1 = zeros(1,N_user);
bytes_sent_case2 = zeros(1,N_user);
bytes_sent_case3 = zeros(1,N_user);
bytes_sent_case4 = zeros(1,N_user);

% �� �����ٸ� ����� ����ں� ��� ó����
% (��,��)=(�ð�,�����)
avg_th_case1 = zeros(N_slot,N_user);
avg_th_case2 = zeros(N_slot,N_user);
avg_th_case3 = zeros(N_slot,N_user);
avg_th_case4 = zeros(N_slot,N_user);

% �� ���Ժ� �����ٸ� ��� ���õ� ����� �ε���
user_index_case1 = zeros(N_slot,1);  
user_index_case2 = zeros(N_slot,1);  
user_index_case3 = zeros(N_slot,1);  
user_index_case4 = zeros(N_slot,1);  

% �ʱⰪ�� random�ϰ� ������
user_index_case1(1) = ceil(rand*N_user);
user_index_case2(1) = ceil(rand*N_user);
user_index_case3(1) = ceil(rand*N_user);
user_index_case4(1) = ceil(rand*N_user);

% ����ں� �Ҵ�� (�����ٸ���) ������ �հ�
counter_user_index_case1 = zeros(1,N_user);  
counter_user_index_case2 = zeros(1,N_user);
counter_user_index_case3 = zeros(1,N_user);
counter_user_index_case4 = zeros(1,N_user);

for i = 2:N_slot
    
    % �� ����ں� MCS ����
    % �� ���Խð����� ä�� ���� ����ȴٰ� ����
    % SNR�� ��� : path-loss�� shadowing ���
    % 1) path-loss model: path-loss exponent = alpha 
    % 2) shadowing: log-normal distribution, STD = SHADOWING    
    for j = 1:N_user        
        path_loss = PL_0 + 10*alpha*log10(distance(j)/D_0);
        shadowing = randn*SHADOW_STD;
        p_rx(j) = P_TX - (path_loss + shadowing);        
        snr(j) = p_rx(j) - NOISE;  % dB
                        
        for k = 1:length(SNR_TH)
            if (snr(j) >= SNR_TH(k))
                inst_rate(i,j) = TX_RATE(k);
                break;
            end
        end
        if (snr(j) < min(SNR_TH))
            inst_rate(i,j) = min(TX_RATE);
        end
    end
    
   % case1: max-min   
   for j=1:N_user
       if (j==user_index_case1(i-1))
           % �����ٸ� ��� ������ �Ҵ���� �����
           % ���� ������ ���� ���ۼӵ���ŭ ������Ű��
           % �Ҵ���� ���Լ��� 1 ���� 
           bytes_sent_case1(j) =  bytes_sent_case1(j)+inst_rate(i,j);
           counter_user_index_case1(j) = counter_user_index_case1(j)+1;           
       end
       % ����ں� ó���� ������Ʈ
       avg_th_case1(i,:) = (bytes_sent_case1)/i;
       % ���� ���� �ð��� �����ٸ� ����� ����
       [temp user_index_case1(i)] = min(avg_th_case1(i,:));   
       % max-min�� ��� ó������ ���� ���� ����ڸ� ������
       % ����, ���� �ּҰ��� �����ٸ� �� �� ù��°       
    end
   
   % case2: proportional fair   
   for j=1:N_user
       if (j==user_index_case2(i-1))
            bytes_sent_case2(j) =  bytes_sent_case2(j)+inst_rate(i,j);
            counter_user_index_case2(j) = counter_user_index_case2(j)+1;    
       end
       avg_th_case2(i,:) = max((bytes_sent_case2)/i,eps);       
   end
   [temp user_index_case2(i)] = max(inst_rate(i,:)./avg_th_case2(i,:));
   % PF �����ٸ��� ���ۼӵ�/���ó�������� ���� ū ����� ����
   
   % case3: round-robin
   for j=1:N_user
        if (j==user_index_case3(i-1))
            bytes_sent_case3(j) =  bytes_sent_case3(j)+inst_rate(i,j);
            counter_user_index_case3(j) = counter_user_index_case3(j)+1;    
        end
        avg_th_case3(i,:) = (bytes_sent_case3)/i;
   end
   user_index_case3(i) = mod(i,N_user)+1;
   % RR �����ٸ��� ������� �ѹ��� 
   % mod�Լ� �̿�
   
   % case4: max-SNR
   for j=1:N_user
        if (j==user_index_case4(i-1))
            bytes_sent_case4(j) =  bytes_sent_case4(j)+inst_rate(i,j);
            counter_user_index_case4(j) = counter_user_index_case4(j)+1;    
        end
        avg_th_case4(i,:) = (bytes_sent_case4)/i;
   end
   [temp user_index_case4(i)] = max(snr);
   % max-SNR �����ٸ��� SNR���� ���� ū ����� ����
   
end

% �� ����ں� ���ۼӵ� ����
% rate_dist: (��,��)=(�����,�ش� MCS�� ����Ȯ��)
for j=1:N_user
    rate_dist(j,:) = [sum(inst_rate(:,j)==TX_RATE(1)), 
                      sum(inst_rate(:,j)==TX_RATE(2)),
                      sum(inst_rate(:,j)==TX_RATE(3)),
                      sum(inst_rate(:,j)==TX_RATE(4))]/N_slot;
end

rate_dist

% final throughput per user
% ����ں� ���� ó����
final_per_user_th = [avg_th_case1(N_slot,:); 
                    avg_th_case2(N_slot,:); 
                    avg_th_case3(N_slot,:);
                    avg_th_case4(N_slot,:)]
final_total_th = sum(final_per_user_th')'

% scheduling probability
scheduling_prob = [counter_user_index_case1 / N_slot;
                   counter_user_index_case2 / N_slot;
                   counter_user_index_case3 / N_slot;
                   counter_user_index_case4 / N_slot]
figure;
subplot(2,2,1);
plot(avg_th_case1);
xlabel('time')
ylabel('throughput (bit/sec)');
title('Max-min scheduling');
grid; axis([0 N_slot 0 15]);

subplot(2,2,2);
plot(avg_th_case2);
xlabel('time')
ylabel('throughput (bit/sec)');
title('proportional fair scheduling');
grid; axis([0 N_slot 0 15]);

subplot(2,2,3);
plot(avg_th_case3);
xlabel('time')
ylabel('throughput (bit/sec)');
title('round-robin scheduling');
grid; axis([0 N_slot 0 15]);

subplot(2,2,4);
plot(avg_th_case4);
xlabel('time')
ylabel('throughput (bit/sec)');
title('max-SNR scheduling');
grid; axis([0 N_slot 0 15]);
