%-------------------------------------------
% INC4103: 스케줄링 실습1
% MCS가 고정된 경우 
%-------------------------------------------

% 3가지 스케줄링 정책 고려함
% case1: max-min
% case2: proportional fair
% case3: round-robin

% 하나의 시간 슬롯은 한 명의 사용자에게 할당된다고 가정

clear;
close all;

N_slot = 1000;    % 전체 슬롯 수
N_user = 3;       % 사용자 수

% 변수 선언 & 초기화  
% 각 스케줄링 기법별 사용자별 누적 전송 데이터 양
bytes_sent_case1 = zeros(1,N_user);
bytes_sent_case2 = zeros(1,N_user);
bytes_sent_case3 = zeros(1,N_user);

% 각 스케줄링 기법별 사용자별 평균 처리율 (누적 평균)
% (행,열)=(시간,사용자)
avg_th_case1 = zeros(N_slot,N_user);
avg_th_case2 = zeros(N_slot,N_user);
avg_th_case3 = zeros(N_slot,N_user);

% 채널 상태는 변하지 않는다고 가정
% 3명의 사용자 고려함
%   - User1: SNR=30dB --> Rate = 8 bit/sec
%   - User2: SNR=10dB --> Rate = 4 bit/sec
%   - User3: SNR= 5dB --> Rate = 1 bit/sec
inst_rate = [8 4 1]; % 각 사용자별 슬롯당 전송 바이트 양

% 매 슬롯별 스케줄링 결과 선택된 사용자 인덱스
user_index_case1 = zeros(N_slot,1);  
user_index_case2 = zeros(N_slot,1);  
user_index_case3 = zeros(N_slot,1);  

% 초기값은 random하게 설정함
user_index_case1(1) = ceil(rand*N_user);
user_index_case2(1) = ceil(rand*N_user);
user_index_case3(1) = ceil(rand*N_user);

% 사용자별 할당된 (스케줄링된) 슬롯의 합계
counter_user_index_case1 = zeros(1,N_user);  
counter_user_index_case2 = zeros(1,N_user);
counter_user_index_case3 = zeros(1,N_user);


for i = 2:N_slot
    
   % case1: max-min   
   for j=1:N_user
       if (j==user_index_case1(i-1))
           % i번째 슬롯을 할당받는 사용자 j는 
           % 이전 (i-1)번째 슬롯 시간동안의 평균 처리율로부터 계산하고
           % 사용자 j는 전송 데이터 양을 전송속도만큼 증가시키고
           % 할당받은 슬롯수를 1 증가 
           bytes_sent_case1(j) =  bytes_sent_case1(j)+inst_rate(j);
           counter_user_index_case1(j) = counter_user_index_case1(j)+1;           
       end
       % 사용자별 처리율 업데이트 
       % i번째 슬롯 시간까지 누적하여 전송한 데이터 양
       avg_th_case1(i,:) = (bytes_sent_case1)/i;
       % 다음 슬롯 시간의 스케줄링 사용자 결정
       [temp user_index_case1(i)] = min(avg_th_case1(i,:));   
       % max-min은 평균 처리율이 가장 낮은 사용자를 선택함
       % 만약, 같은 최소값을 가진다면 그 중 첫번째
       % min()함수의 return값은 2개인데, 
       % 첫번째가 최소값, 두번째가 최소값을 가지는 인덱스
    end
   
   % case2: proportional fair   
   for j=1:N_user
       if (j==user_index_case2(i-1))
            bytes_sent_case2(j) =  bytes_sent_case2(j)+inst_rate(j);
            counter_user_index_case2(j) = counter_user_index_case2(j)+1;    
       end
       avg_th_case2(i,:) = max((bytes_sent_case2)/i,eps);
       % 평균 처리율이 0이면 나눗셈 연산시 오류가 발생하여
       % 아주 작은값 (eps)로 대체       
   end
   [temp user_index_case2(i)] = max(inst_rate./avg_th_case2(i,:));
   % PF 스케줄링은 전송속도/평균처리율값이 가장 큰 사용자 선택
   
   % case3: round-robin
   for j=1:N_user
        if (j==user_index_case3(i-1))
            bytes_sent_case3(j) =  bytes_sent_case3(j)+inst_rate(j);
            counter_user_index_case3(j) = counter_user_index_case3(j)+1;    
        end
        avg_th_case3(i,:) = (bytes_sent_case3)/i;
   end
   user_index_case3(i) = mod(i,N_user)+1;
   % RR 스케줄링은 순서대로 한번씩 
   % mod함수 이용
   
end

% 최종 처리율
avg_th_case1(N_slot,:);
avg_th_case2(N_slot,:);
avg_th_case3(N_slot,:);

% 스케줄링 확률
% = 할당받은 슬롯수 / 전체 슬롯수
scheduling_prob1 = counter_user_index_case1 / N_slot;
scheduling_prob2 = counter_user_index_case2 / N_slot;
scheduling_prob3 = counter_user_index_case3 / N_slot;

avg_th = [avg_th_case1(N_slot,:), sum(avg_th_case1(N_slot,:))
    avg_th_case2(N_slot,:), sum(avg_th_case2(N_slot,:))
    avg_th_case3(N_slot,:), sum(avg_th_case3(N_slot,:))]

scheduling_probability = [scheduling_prob1
    scheduling_prob2
    scheduling_prob3]

figure;

T = [1:N_slot];
plot(avg_th_case1);
hold on; plot(T,sum(avg_th_case1'),'k');
xlabel('time'); ylabel('throughput (bit/sec)');
legend('user1', 'user2', 'user3', 'total');
title('Max-min scheduling');
axis([1 N_slot, 0 6]);

figure;
stem(user_index_case1);
xlabel('time'); ylabel('index of user scheduled');
title('Max-min scheduling');
axis([1 30 0 3]);

figure;
plot(avg_th_case2);
hold on; plot(T,sum(avg_th_case2'),'k');
xlabel('time'); ylabel('throughput (bit/sec)');
legend('user1', 'user2', 'user3', 'total');
title('Proportional fair scheduling');
axis([1 N_slot, 0 6]);

figure;
stem(user_index_case2);
xlabel('time'); ylabel('index of user scheduled');
title('Proportional fair scheduling');
axis([1 30 0 3]);

figure;
plot(avg_th_case3);
hold on; plot(T,sum(avg_th_case3'),'k');
xlabel('time'); ylabel('throughput (bit/sec)');
legend('user1', 'user2', 'user3', 'total');
title('Round-robin scheduling');
axis([1 N_slot, 0 6]);

figure;
stem(user_index_case3);
xlabel('time'); ylabel('index of user scheduled');
title('Round-robin scheduling');
axis([1 30 0 3]);