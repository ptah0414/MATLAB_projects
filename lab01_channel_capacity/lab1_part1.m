% INC4103 Lab01: Part 1
% SNR, BER, 채널용량 관찰

clear;
close all;

% 1. Path-loss model
PL0 = 50;       % 기준거리에서의 path-loss [dB]
d0 = 5;         % 기준거리 [m]
PL1 = 60;       % 주어진 거리에서의 path-loss [dB]
d1 = 10;        % 주어진 거리 [m]

% alpha: path-loss exponent
% path_loss_dB = PL0 + 10*alpha*log10(distance/d0);
path_loss_dB = PL1; % 60
distance = d1;

alpha = (path_loss_dB - PL0)/(10*log10(distance/d0)); %(60 - 50)/(10*log10(10/5));


Ptx_dB = 20;   % 전송 전력 [dBm]
Pnoise_dB = -80;% 잡음 전력 [dBm]


% 2. Error model
L = 1000*8;         % 프레임 크기 [bit]
B = 20*10^6;        % 대역폭 [Hz]
R = [6 12 24 48]*10^6; % 전송속도 [bit/sec]
    % 4가지 MCS 고려: BPSK 1/2, QPSK 1/2, 16QAM 1/2, 64QAM 2/3
M = [2 4 16 64];      % BER 계산식의 파라미터
b = (1/2)*log2(M);    % BER 계산식의 파라미터

target_FER = 0.01; % target FER for AMC (1%)


% 3. Calculate SNR
d = [1:150]';      %  송수신 노드 거리 [m]
PL_dB = PL0 + 10*alpha*log10(d/d0);   % path-loss [dB]

Prx_dB = Ptx_dB - PL_dB; % receiving power [dB]
    % PL = Ptx / Prx
    % PL(dB) = Ptx(dB) - Prx(dB)
    % Prx(dB) = Ptx(dB) - PL(dB)
SNR_dB = Prx_dB - Pnoise_dB;
    % SNR = Prx / Pnoise
    % SNR(dB) = Prx(dB) - Pnoise(dB)

% Plot SNR versus distance
figure; plot(d,SNR_dB);
xlabel('distance (m)');
ylabel('SNR (dB)');
grid;


% 4. Calculate BER/FER
SNR = 10.^SNR_dB/10;
    % SNR in linear scale, 
    % Note: SNR_dB = 10*log10(SNR) 
    % SNR = 10 ^ (SNR_dB/10)

Eb_No = zeros(length(d), length(R));    % Eb/No (2차원 배열, 1번열=거리, 2번열=MCS)
P_ber = zeros(length(d), length(R));    % bit error rate
P_fer = zeros(length(d), length(R));    % frame error rate

% calculate BER for a given MCS
for i = 1:length(R)
    Eb_No(:,i) = SNR * B / R(i);
    P_ber(:,i) = (1-1/sqrt(M(i)))*erfc(sqrt(3*b(i)/(M(i)-1)*Eb_No(:,i))); 
    P_fer(:,i) = 1-(1-P_ber(:,i)).^L;
end

% plot FER vs SNR
figure; 
semilogy(d,P_fer(:,1),'r-', d,P_fer(:,2),'g:', d,P_fer(:,3),'b-.', d, P_fer(:,4), 'k-.');
xlabel('distance (m)');
ylabel('frame error rate');
legend('BPSK 1/2', 'QPSK 1/2', '16QAM 1/2', '64QAM 2/3');
grid;


% 5. Plot capacity 
C = zeros(length(d), length(R));

for i = 1:length(R)
    C(:,i) = (1-P_fer(:,i))*R(i)/10^6;   % effective capacity [Mb/s]
end

figure; 
plot(d,C(:,1), 'r-', d, C(:,2), 'g:', d, C(:,3), 'b-.', d, C(:,4), 'k-.');
xlabel('distance (m)');
ylabel('effective capacity (Mb/s)');
legend('BPSK 1/2', 'QPSK 1/2', '16QAM 1/2', '64QAM 2/3');
grid;

% 5. 최대 커버리지와 최소 SNR값 구하기
max_coverage = zeros(length(R), 1); % 각 MCS별 최대 커버리지 (4*1)
min_SNR_req = zeros(length(R), 1);  % 각 MCS별 최소 요구 SNR

% P_fer = 0.01
% BPSK  145m 1.4202dB
% QPSK  141m 1.8238dB
% 16QAM 134m 2.5584dB
% 64QAM 127m 3.3324dB

% d = 127;      %  송수신 노드 거리 [m]
% PL_dB = PL0 + 10*alpha*log10(d/d0);   % path-loss [dB]
% 
% Prx_dB = Ptx_dB - PL_dB; % receiving power [dB]
%     % PL = Ptx / Prx
%     % PL(dB) = Ptx(dB) - Prx(dB)
%     % Prx(dB) = Ptx(dB) - PL(dB)
% SNR_dB = Prx_dB - Pnoise_dB;
%     % SNR = Prx / Pnoise
%     % SNR(dB) = Prx(dB) - Pnoise(dB)



% for i = 1:length(R)
%     max_coverage(i) = % 여기를 완성하세요.
%         % 주어진 MCS에서 FER 값이 target FER 이하가 되는 최대 거리
%     min_SNR_req(i) = % 여기를 완성하세요.
%         % 주어진 MCS에서 FER 값이 target FER 이하가 되는 최소 SNR값 (dB)
% end