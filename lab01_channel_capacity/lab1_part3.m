%-----------------------------------------------
%  INC4103: ����� �ý��� ���� ���� ��� ��
%-----------------------------------------------
clear;
close all;

N_sim = 10000;  % ��ü �ùķ��̼� ȸ��

B = 10*10^6;        % ä�� �뿪�� [Hz]
P_noise_dB = -80;   % ���� ���� [dBm]
% -----------------------------------
% 1. ä�� ��
% -----------------------------------
% log-distance path-loss model with loss exponent of alpha
% PL1 = 50 dB loss at d1 = 5m, and PL2 = 60dB at d2 = 10m
PL_ref = [50 60];   % ���� PL [dB]
d_ref = [5 10];     % ���� �Ÿ�  [m]

P_tx = [200 200];      % ���� ���� [mW]
P_tx_dB = 10*log10(P_tx);  % ���� ���� [dBm]

alpha = % �̺κ� �ϼ�;
% �� ���������κ��� ���


% ���� �ʱ�ȭ
P_rx_dB = zeros(1,2);   % ���� ���� (dBm)
P_int_dB = zeros(1,2);  % ���� ���� (dBm)
SNR = zeros(1,2);   % [SNR of MS1, SNR of MS2]
SINR = zeros(1,2);  % [SINR of MS1, SINR of MS2]
Capacity_case1 = 0;
    % case1: ��ü �뿪�� ��� (���� �߻�)
Capacity_case2 = 0;
    % case2: �뿪�� 1/2�� ��� (FDMA) ������ ����

% -----------------------------------
% 1. ��� ��ġ (����ǥ�� ���)
% x-��: �Ǽ�, y-��: ���
% -----------------------------------
D = 30;
R = 30;  % �� ���� Ŀ������

BS = [-D,D]; % BS1=(-D,0), BS2=(D,0)   

for i = 1:N_sim
    % �ܸ��� Ŀ�������� ���� ��ġ (���� ���)
    r = rand(1,2)*R; 
    theta = rand(1,2)*2*pi;
    MS = BS + r.*exp(j*theta);
        % x ��ǥ: MS = BS + r*cos(theta);
        % y ��ǥ: MS = BS + r*sin(theta);

% -----------------------------------
% 2. SINR ���
% -----------------------------------
% ������ �����ϰ� ������ �����.
    P_rx_dB(1) = % ���⸦ �ϼ��ϼ���.; 
    % MS1������ �������� = �۽� ���� - path loss
    P_rx_dB(2) = % ���⸦ �ϼ��ϼ���.; 
    % MS2������ ��������

% ���� ���� ���
P_int_dB(1) = % ���⸦ �ϼ��ϼ���;
    % MS1������ ���� = BS2 --> MS1
    % ������鿡�� �� �� (x,y) ������ �Ÿ� = abs(x-y)
P_int_dB(2) = % ���⸦ �ϼ��ϼ���;
    % MS2������ ���� = BS1 --> MS2        

    
% SNR & SINR ��� 
% dB ������ �ƴԿ� ������
SNR = % ���⸦ �ϼ��ϼ���;
SINR = % ���⸦ �ϼ��ϼ���;
    
% �뷮 ��� (������)
Capacity_case1 = Capacity_case1 + B*(log2(1+SINR(1)) + log2(1+SINR(2)))/10^6;   
    % Shannon capacity in Mb/s 
    % Case1: ������ �����鼭 ��ü �뿪�� ���
Capacity_case2 = Capacity_case2 + (B/2)*(log2(1+SNR(1)) + log2(1+SNR(2)))/10^6;   
    % Shannon capacity in Mb/s 
    % Case2: �뿪���� �������鼭 ���� ����

end

Capacity_case1 = Capacity_case1/N_sim
Capacity_case2 = Capacity_case2/N_sim

