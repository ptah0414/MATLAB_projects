%-------------------------------------------
% INC4103: 스케줄링 실습3
% 채널 상태 변경되고 AMC 고려함 
%-------------------------------------------

% 4가지 스케줄링 정책 고려함
% case1: max-min
% case2: proportional fair
% case3: round-robin
% case4: max-SNR

% 하나의 시간 슬롯은 한 명의 사용자에게 할당된다고 가정

clear; clc;
close all;

N_slot = 1000;    % 전체 슬롯 수
N_user = 4;       % 사용자 수
distance = [200 300 400 500]; % 기지국과의 거리

% SNR값에 따라 4가지 MCS 고려
SNR_TH = [30 20 10];     % unit: dB
TX_RATE = [16 8 4 1]; % unit: bit/sec
% if SNR>=30 dB      --> 16 bit/sec (64QAM 2/3)
% if 20<= SNR <30 dB --> 8 bit/sec (16QAM 1/2)
% if 10<= SNR <20 dB --> 4 bit/sec (QPSK 1/2)
% if SNR < 10 dB     --> 1 bit/sec (BPSK 1/2)

% 채널 관련 파라미터
P_TX = 20;      % 전송 전력 (dBm)
alpha = 3.5;    % path-loss exponent
PL_0 = 40;       % 기준거리(D_0)에서의 경로 손실
D_0 = 10;        % 기준거리
SHADOW_STD = 10;  % shadowing 표준편차;
NOISE = -80;     % 잡음 전력 (dBm)

% 변수 선언 & 초기화  
% 각 스케줄링 기법별 사용자별 누적 전송 데이터 양
bytes_sent_case1 = zeros(1,N_user);
bytes_sent_case2 = zeros(1,N_user);
bytes_sent_case3 = zeros(1,N_user);
bytes_sent_case4 = zeros(1,N_user);

% 각 스케줄링 기법별 사용자별 평균 처리율
% (행,열)=(시간,사용자)
avg_th_case1 = zeros(N_slot,N_user);
avg_th_case2 = zeros(N_slot,N_user);
avg_th_case3 = zeros(N_slot,N_user);
avg_th_case4 = zeros(N_slot,N_user);

% 매 슬롯별 스케줄링 결과 선택된 사용자 인덱스
user_index_case1 = zeros(N_slot,1);  
user_index_case2 = zeros(N_slot,1);  
user_index_case3 = zeros(N_slot,1);  
user_index_case4 = zeros(N_slot,1);  

% 초기값은 random하게 설정함
user_index_case1(1) = ceil(rand*N_user);
user_index_case2(1) = ceil(rand*N_user);
user_index_case3(1) = ceil(rand*N_user);
user_index_case4(1) = ceil(rand*N_user);

% 사용자별 할당된 (스케줄링된) 슬롯의 합계
counter_user_index_case1 = zeros(1,N_user);  
counter_user_index_case2 = zeros(1,N_user);
counter_user_index_case3 = zeros(1,N_user);
counter_user_index_case4 = zeros(1,N_user);

for i = 2:N_slot
    
    % 각 사용자별 MCS 결정
    % 매 슬롯시간마다 채널 상태 변경된다고 가정
    % SNR값 계산 : path-loss와 shadowing 고려
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
           % 스케줄링 결과 슬롯을 할당받은 사용자
           % 전송 데이터 양을 전송속도만큼 증가시키고
           % 할당받은 슬롯수를 1 증가 
           bytes_sent_case1(j) =  bytes_sent_case1(j)+inst_rate(i,j);
           counter_user_index_case1(j) = counter_user_index_case1(j)+1;           
       end
       % 사용자별 처리율 업데이트
       avg_th_case1(i,:) = (bytes_sent_case1)/i;
       % 다음 슬롯 시간의 스케줄링 사용자 결정
       [temp user_index_case1(i)] = min(avg_th_case1(i,:));   
       % max-min은 평균 처리율이 가장 낮은 사용자를 선택함
       % 만약, 같은 최소값을 가진다면 그 중 첫번째       
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
   % PF 스케줄링은 전송속도/평균처리율값이 가장 큰 사용자 선택
   
   % case3: round-robin
   for j=1:N_user
        if (j==user_index_case3(i-1))
            bytes_sent_case3(j) =  bytes_sent_case3(j)+inst_rate(i,j);
            counter_user_index_case3(j) = counter_user_index_case3(j)+1;    
        end
        avg_th_case3(i,:) = (bytes_sent_case3)/i;
   end
   user_index_case3(i) = mod(i,N_user)+1;
   % RR 스케줄링은 순서대로 한번씩 
   % mod함수 이용
   
   % case4: max-SNR
   for j=1:N_user
        if (j==user_index_case4(i-1))
            bytes_sent_case4(j) =  bytes_sent_case4(j)+inst_rate(i,j);
            counter_user_index_case4(j) = counter_user_index_case4(j)+1;    
        end
        avg_th_case4(i,:) = (bytes_sent_case4)/i;
   end
   [temp user_index_case4(i)] = max(snr);
   % max-SNR 스케줄링은 SNR값이 가장 큰 사용자 선택
   
end

% 각 사용자별 전송속도 분포
% rate_dist: (행,열)=(사용자,해당 MCS의 분포확률)
for j=1:N_user
    rate_dist(j,:) = [sum(inst_rate(:,j)==TX_RATE(1)), 
                      sum(inst_rate(:,j)==TX_RATE(2)),
                      sum(inst_rate(:,j)==TX_RATE(3)),
                      sum(inst_rate(:,j)==TX_RATE(4))]/N_slot;
end

rate_dist

% final throughput per user
% 사용자별 최종 처리율
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
