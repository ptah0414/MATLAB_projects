%-----------------------------------------------
%  INC4103: ������ ���� ä�� �뷮�� ä�� ���� ��� ��
%-----------------------------------------------
clear;
close all;

% -----------------------------------
% ��� ��ġ
% -----------------------------------
%       flow1          flow2
%     A  --> B ----- C  --> D
%     |--R1--|---D---|--R2--|

%  �Ÿ� D�� ���� ä�� �뷮 ��ȭ ����
%  ����: �Ÿ� D�� �����Ҽ��� ���� ��ȭ --> ä�� �뷮 ����

D = [1:50]';
R1 = 20;
R2 = 20;

B = 10*10^6;    % ä�� �뿪�� [Hz]
P_noise_dB = -80;   % ���� ���� [dBm]

% -----------------------------------
% 1. ä�� ��
% -----------------------------------
% log-distance path-loss model with loss exponent of alpha
% PL1 = 50dB loss at d1 = 5m, and PL2 = 60dB at d2 = 10m
PL_ref = [50 60];   % reference PL [dB]
d_ref = [5 10];     % reference distance  [m]

P_tx = [200 200];         % ���� ���� [mW]
P_tx_dB = 10*log10(P_tx);  % ���� ���� [dBm]

% alpha: path-loss exponent
% path_loss_dB = PL0 + 10*alpha*log10(distance/d0);
path_loss_dB = 60;
PL0 = 50;
distance = 10;
d0 = 5;

alpha = (path_loss_dB - PL0)/(10*log10(distance/d0)); %(60 - 50)/(10*log10(10/5));


% ���� �ʱ�ȭ
P_rx_dB = zeros(1,2);           % �������� (dBm)
P_int_dB = zeros(length(D),2);  % ���� ��ȣ ���� (�� = �Ÿ�, �� = �÷ο�)
SINR = zeros(length(D),2);
Capacity = zeros(length(D),2);


% -----------------------------------
% 2. SINR ��� 
% -----------------------------------
% ������ �����ϰ� ���� ��ȣ ���¸� �����
% �ۼ��� ��尡 �ٲ�� �� �κ� ������

P_rx_dB(1) = P_tx_dB(1) - path_loss(R1, alpha, PL_ref(1), d_ref(1)); 
    % flow1�� �������� 
P_rx_dB(2) = P_tx_dB(2) - path_loss(R2, alpha, PL_ref(1), d_ref(1)); 
    % flow2�� ��������

for i = 1:length(D)
    % ���� ���� ���
    P_int_dB(i,1) = P_tx_dB(2) - path_loss(D(i), alpha, PL_ref(1), d_ref(1));
        % node B������ ���� = ���� ��� C�� ���� ���� ����
        % B�� C ������ �Ÿ� = D(i)
    P_int_dB(i,2) = P_tx_dB(1) - path_loss(R1+D(i)+R2, alpha, PL_ref(1), d_ref(1));
        % node D������ ���� = ���� ��� A�� ���� ���� ����
        % A�� D ������ �Ÿ� = R1+D(i)+R2
    
    % SINR ��� (dB ������ �ƴԿ� ����)
    % ������ �����ص� ����
    SINR(i,:) = 10.^(P_rx_dB/10) ./ (10.^(P_int_dB(i,:)/10) + 10^(P_noise_dB/10));
    
    % Shannon capacity ��� (����: Mb/s)
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