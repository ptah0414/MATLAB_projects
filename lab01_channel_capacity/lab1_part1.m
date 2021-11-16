% INC4103 Lab01: Part 1
% SNR, BER, ä�ο뷮 ����

clear;
close all;

% 1. Path-loss model
PL0 = 50;       % ���ذŸ������� path-loss [dB]
d0 = 5;         % ���ذŸ� [m]
PL1 = 60;       % �־��� �Ÿ������� path-loss [dB]
d1 = 10;        % �־��� �Ÿ� [m]

% alpha: path-loss exponent
% path_loss_dB = PL0 + 10*alpha*log10(distance/d0);
path_loss_dB = PL1; % 60
distance = d1;

alpha = (path_loss_dB - PL0)/(10*log10(distance/d0)); %(60 - 50)/(10*log10(10/5));


Ptx_dB = 20;   % ���� ���� [dBm]
Pnoise_dB = -80;% ���� ���� [dBm]


% 2. Error model
L = 1000*8;         % ������ ũ�� [bit]
B = 20*10^6;        % �뿪�� [Hz]
R = [6 12 24 48]*10^6; % ���ۼӵ� [bit/sec]
    % 4���� MCS ���: BPSK 1/2, QPSK 1/2, 16QAM 1/2, 64QAM 2/3
M = [2 4 16 64];      % BER ������ �Ķ����
b = (1/2)*log2(M);    % BER ������ �Ķ����

target_FER = 0.01; % target FER for AMC (1%)


% 3. Calculate SNR
d = [1:150]';      %  �ۼ��� ��� �Ÿ� [m]
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

Eb_No = zeros(length(d), length(R));    % Eb/No (2���� �迭, 1����=�Ÿ�, 2����=MCS)
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

% 5. �ִ� Ŀ�������� �ּ� SNR�� ���ϱ�
max_coverage = zeros(length(R), 1); % �� MCS�� �ִ� Ŀ������ (4*1)
min_SNR_req = zeros(length(R), 1);  % �� MCS�� �ּ� �䱸 SNR

% P_fer = 0.01
% BPSK  145m 1.4202dB
% QPSK  141m 1.8238dB
% 16QAM 134m 2.5584dB
% 64QAM 127m 3.3324dB

% d = 127;      %  �ۼ��� ��� �Ÿ� [m]
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
%     max_coverage(i) = % ���⸦ �ϼ��ϼ���.
%         % �־��� MCS���� FER ���� target FER ���ϰ� �Ǵ� �ִ� �Ÿ�
%     min_SNR_req(i) = % ���⸦ �ϼ��ϼ���.
%         % �־��� MCS���� FER ���� target FER ���ϰ� �Ǵ� �ּ� SNR�� (dB)
% end