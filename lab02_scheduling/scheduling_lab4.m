%-------------------------------------------
% INC4103: 스케줄링 실습4
% 사용자별 최소 요구 전송 속도가 있는 경우
%-------------------------------------------

% 3가지 스케줄링 정책 고려함
% case1: max-min
% case2: proportional fair

% 하나의 시간 슬롯은 한 명의 사용자에게 할당된다고 가정

clear;
close all;
clc;


N_slot = 1000;    % 전체 슬롯 수
N_user = 3;       % 사용자 수

% 변수 선언 & 초기화  
% 각 스케줄링 기법별 사용자별 누적 전송 데이터 양
bytes_sent_case1 = zeros(1,N_user);
bytes_sent_case2 = zeros(1,N_user);

% 각 스케줄링 기법별 사용자별 평균 처리율
% (행,열)=(시간,사용자)
avg_th_case1 = zeros(N_slot,N_user);
avg_th_case2 = zeros(N_slot,N_user);

% 매 슬롯별 스케줄링 결과 선택된 사용자 인덱스
user_index_case1 = zeros(N_slot,1);  
user_index_case2 = zeros(N_slot,1);  

% 초기값은 random하게 설정함
user_index_case1(1) = ceil(rand*N_user);
user_index_case2(1) = ceil(rand*N_user);

% 사용자별 할당된 (스케줄링된) 슬롯의 합계
counter_user_index_case1 = zeros(1,N_user);  
counter_user_index_case2 = zeros(1,N_user);

% 전송 속도는 채널 상태에 따라 다음중 하나로 결정됨
TX_RATE = [8, 4, 1];
% 사용자1: 채널 상태 좋음
% 사용자2&3: 채널 상태 보통
% 사용자4: 채널 상태 나쁨
channel_quality_prob = [1.0   0.0   0.0;  % 사용자1
                        0.0   1.0   0.0;  % 사용자2
                        0.0   0.0   1.0]; % 사용자3


% minimum required tput
R_min = [0 0 0];
% R_min = [0.5 0.5 0.5];
% R_min = [0.8 0.4 0.1];
% R_min = [1 1 1];

for i = 2:N_slot
    
    % 각 사용자별 MCS 결정
    % 매 슬롯시간마다 확률적으로 변경된다고 가정함    
    for j=1:N_user
        p = rand;
        if (p < channel_quality_prob(j,1))
            inst_rate(j) = TX_RATE(1);
        elseif (p < channel_quality_prob(j,1)+channel_quality_prob(j,2))
            inst_rate(j) = TX_RATE(2);
        else
            inst_rate(j) = TX_RATE(3);
        end
    end
    
   % case1: max-min   
   for j=1:N_user
       if (j==user_index_case1(i-1))
           % 스케줄링 결과 슬롯을 할당받은 사용자
           % 전송 데이터 양을 전송속도만큼 증가시키고
           % 할당받은 슬롯수를 1 증가 
           bytes_sent_case1(j) =  bytes_sent_case1(j)+inst_rate(j);
           counter_user_index_case1(j) = counter_user_index_case1(j)+1;           
       end
       % 사용자별 처리율 업데이트
       avg_th_case1(i,:) = (bytes_sent_case1)/i;
       % 다음 슬롯 시간의 스케줄링 사용자 결정
       [temp user_index_case1(i)] = min(avg_th_case1(i,:)-R_min);   
       % max-min은 평균 처리율이 가장 낮은 사용자를 선택함
       % 만약, 같은 최소값을 가진다면 그 중 첫번째       
    end
   
   % case2: proportional fair   
   for j=1:N_user
       if (j==user_index_case2(i-1))
            bytes_sent_case2(j) =  bytes_sent_case2(j)+inst_rate(j);
            counter_user_index_case2(j) = counter_user_index_case2(j)+1;    
       end
       avg_th_case2(i,:) = max((bytes_sent_case2)/i,eps);
       % 평균 처리율이 0이면 나눗셈 연산시 오류가 발생하여
       % 아주 작은값 (eps)로 바꿈       
   end
   [temp user_index_case2(i)] = max(inst_rate./max((avg_th_case2(i,:)-R_min), eps));
   % PF 스케줄링은 전송속도/평균처리율값이 가장 큰 사용자 선택   
end

% 사용자별 최종 처리율
final_per_user_th = [avg_th_case1(N_slot,:); 
                    avg_th_case2(N_slot,:)]
final_total_th = sum(final_per_user_th')'

% scheduling probability
scheduling_prob = [counter_user_index_case1 / N_slot;
                   counter_user_index_case2 / N_slot]
               
figure;
subplot(2,1,1)
plot(avg_th_case1);
xlabel('time')
ylabel('throughput (bit/sec)');
title('Max-min scheduling');

subplot(2,1,2)
plot(avg_th_case2);
xlabel('time')
ylabel('throughput (bit/sec)');
title('proportional fair scheduling');
