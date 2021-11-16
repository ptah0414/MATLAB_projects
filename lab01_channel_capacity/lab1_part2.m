%-----------------------------------------------
%  INC4103: 간섭에 따른 채널 용량과 채널 공유 방식 비교
%-----------------------------------------------
clear;
close all;

% -----------------------------------
% 노드 배치
% -----------------------------------
%       flow1          flow2
%     A  --> B ----- C  --> D
%     |--R1--|---D---|--R2--|

%  거리 D에 따른 채널 용량 변화 관찰
%  예상: 거리 D가 증가할수록 간섭 완화 --> 채널 용량 증가

D = [1:50]';
R1 = 20;
R2 = 20;

B = 10*10^6;    % 채널 대역폭 [Hz]
P_noise_dB = -80;   % 잡음 전력 [dBm]

% -----------------------------------
% 1. 채널 모델
% -----------------------------------
% log-distance path-loss model with loss exponent of alpha
% PL1 = 50dB loss at d1 = 5m, and PL2 = 60dB at d2 = 10m
PL_ref = [50 60];   % reference PL [dB]
d_ref = [5 10];     % reference distance  [m]

P_tx = [200 200];         % 전송 전력 [mW]
P_tx_dB = 10*log10(P_tx);  % 전송 전력 [dBm]

% alpha: path-loss exponent
% path_loss_dB = PL0 + 10*alpha*log10(distance/d0);
path_loss_dB = 60;
PL0 = 50;
distance = 10;
d0 = 5;

alpha = (path_loss_dB - PL0)/(10*log10(distance/d0)); %(60 - 50)/(10*log10(10/5));


% 변수 초기화
P_rx_dB = zeros(1,2);           % 수신전력 (dBm)
P_int_dB = zeros(length(D),2);  % 간섭 신호 전력 (행 = 거리, 열 = 플로우)
SINR = zeros(length(D),2);
Capacity = zeros(length(D),2);


% -----------------------------------
% 2. SINR 계산 
% -----------------------------------
% 잡음은 무시하고 간섭 신호 전력만 고려함
% 송수신 노드가 바뀌면 이 부분 변경함

P_rx_dB(1) = P_tx_dB(1) - path_loss(R1, alpha, PL_ref(1), d_ref(1)); 
    % flow1의 수신전력 
P_rx_dB(2) = P_tx_dB(2) - path_loss(R2, alpha, PL_ref(1), d_ref(1)); 
    % flow2의 수신전력

for i = 1:length(D)
    % 간섭 전력 계산
    P_int_dB(i,1) = P_tx_dB(2) - path_loss(D(i), alpha, PL_ref(1), d_ref(1));
        % node B에서의 간섭 = 전송 노드 C에 대한 수신 전력
        % B와 C 사이의 거리 = D(i)
    P_int_dB(i,2) = P_tx_dB(1) - path_loss(R1+D(i)+R2, alpha, PL_ref(1), d_ref(1));
        % node D에서의 간섭 = 전송 노드 A에 대한 수신 전력
        % A와 D 사이의 거리 = R1+D(i)+R2
    
    % SINR 계산 (dB 단위가 아님에 유의)
    % 잡음은 무시해도 좋음
    SINR(i,:) = 10.^(P_rx_dB/10) ./ (10.^(P_int_dB(i,:)/10) + 10^(P_noise_dB/10));
    
    % Shannon capacity 계산 (단위: Mb/s)
    Capacity(i,:) = B*log2(1+SINR(i,:))/10^6;
end

SINR_dB = 10*log10(SINR(:,:));

figure;
plot(D, 10*log10(SINR(:,1)), 'r-', D, 10*log10(SINR(:,2)), 'g:');
legend('flow1', 'flow2');
xlabel('distance between nodes B and C (m)');
ylabel('SINR (dB)');
grid;

figure;
plot(D, Capacity(:,1), 'r-', D, Capacity(:,2), 'g:', D, Capacity(:,1)+Capacity(:,2),'b-.');
legend('flow1', 'flow2', 'total');
xlabel('distance between nodes B and C (m)');
ylabel('Capacity (Mb/s)');
grid;