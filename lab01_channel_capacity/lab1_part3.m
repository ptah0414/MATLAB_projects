%-----------------------------------------------
%  INC4103: 셀룰라 시스템 다중 접속 방식 비교
%-----------------------------------------------
clear;
close all;

N_sim = 10000;  % 전체 시뮬레이션 회수

B = 10*10^6;        % 채널 대역폭 [Hz]
P_noise_dB = -80;   % 잡음 전력 [dBm]
% -----------------------------------
% 1. 채널 모델
% -----------------------------------
% log-distance path-loss model with loss exponent of alpha
% PL1 = 50 dB loss at d1 = 5m, and PL2 = 60dB at d2 = 10m
PL_ref = [50 60];   % 기준 PL [dB]
d_ref = [5 10];     % 기준 거리  [m]

P_tx = [200 200];      % 전송 전력 [mW]
P_tx_dB = 10*log10(P_tx);  % 전송 전력 [dBm]

alpha = % 이부분 완성;
% 두 측정값으로부터 계산


% 변수 초기화
P_rx_dB = zeros(1,2);   % 수신 전력 (dBm)
P_int_dB = zeros(1,2);  % 간섭 전력 (dBm)
SNR = zeros(1,2);   % [SNR of MS1, SNR of MS2]
SINR = zeros(1,2);  % [SINR of MS1, SINR of MS2]
Capacity_case1 = 0;
    % case1: 전체 대역폭 사용 (간섭 발생)
Capacity_case2 = 0;
    % case2: 대역폭 1/2만 사용 (FDMA) 간섭은 무시

% -----------------------------------
% 1. 노드 배치 (극좌표계 사용)
% x-축: 실수, y-축: 허수
% -----------------------------------
D = 30;
R = 30;  % 각 셀의 커버리지

BS = [-D,D]; % BS1=(-D,0), BS2=(D,0)   

for i = 1:N_sim
    % 단말은 커버리지내 임의 배치 (복소 평면)
    r = rand(1,2)*R; 
    theta = rand(1,2)*2*pi;
    MS = BS + r.*exp(j*theta);
        % x 좌표: MS = BS + r*cos(theta);
        % y 좌표: MS = BS + r*sin(theta);

% -----------------------------------
% 2. SINR 계산
% -----------------------------------
% 잡음은 무시하고 간섭만 고려함.
    P_rx_dB(1) = % 여기를 완성하세요.; 
    % MS1에서의 수신전력 = 송신 전력 - path loss
    P_rx_dB(2) = % 여기를 완성하세요.; 
    % MS2에서의 수신전력

% 간섭 전력 계산
P_int_dB(1) = % 여기를 완성하세요;
    % MS1에서의 간섭 = BS2 --> MS1
    % 복소평면에서 두 점 (x,y) 사이의 거리 = abs(x-y)
P_int_dB(2) = % 여기를 완성하세요;
    % MS2에서의 간섭 = BS1 --> MS2        

    
% SNR & SINR 계산 
% dB 단위가 아님에 유의함
SNR = % 여기를 완성하세요;
SINR = % 여기를 완성하세요;
    
% 용량 계산 (누적값)
Capacity_case1 = Capacity_case1 + B*(log2(1+SINR(1)) + log2(1+SINR(2)))/10^6;   
    % Shannon capacity in Mb/s 
    % Case1: 간섭이 있으면서 전체 대역폭 사용
Capacity_case2 = Capacity_case2 + (B/2)*(log2(1+SNR(1)) + log2(1+SNR(2)))/10^6;   
    % Shannon capacity in Mb/s 
    % Case2: 대역폭을 나눠쓰면서 간섭 없음

end

Capacity_case1 = Capacity_case1/N_sim
Capacity_case2 = Capacity_case2/N_sim

