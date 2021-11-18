%-------------------------------------------
% INC4103: �����ٸ� �ǽ�2
% MCS�� Ȯ�������� ����Ǵ� ��� 
%-------------------------------------------

% 3���� �����ٸ� ��å �����
% case1: max-min
% case2: proportional fair
% case3: round-robin

% �ϳ��� �ð� ������ �� ���� ����ڿ��� �Ҵ�ȴٰ� ����

clear;
close all;

N_slot = 1000;    % ��ü ���� ��
N_user = 4;       % ����� ��

% ���� ���� & �ʱ�ȭ  
% �� �����ٸ� ����� ����ں� ���� ���� ������ ��
bytes_sent_case1 = zeros(1,N_user);
bytes_sent_case2 = zeros(1,N_user);
bytes_sent_case3 = zeros(1,N_user);

% �� �����ٸ� ����� ����ں� ��� ó����
% (��,��)=(�ð�,�����)
avg_th_case1 = zeros(N_slot,N_user);
avg_th_case2 = zeros(N_slot,N_user);
avg_th_case3 = zeros(N_slot,N_user);

% �� ���Ժ� �����ٸ� ��� ���õ� ����� �ε���
user_index_case1 = zeros(N_slot,1);  
user_index_case2 = zeros(N_slot,1);  
user_index_case3 = zeros(N_slot,1);  

% �ʱⰪ�� random�ϰ� ������
user_index_case1(1) = ceil(rand*N_user);
user_index_case2(1) = ceil(rand*N_user);
user_index_case3(1) = ceil(rand*N_user);

% ����ں� �Ҵ�� (�����ٸ���) ������ �հ�
counter_user_index_case1 = zeros(1,N_user);  
counter_user_index_case2 = zeros(1,N_user);
counter_user_index_case3 = zeros(1,N_user);

% ���� �ӵ��� ä�� ���¿� ���� ������ �ϳ��� ������
TX_RATE = [8, 4, 1];
% �����1: ä�� ���� ����
% �����2&3: ä�� ���� ����
% �����4: ä�� ���� ����
channel_quality_prob = [0.2   0.6   0.2;  % �����1
                        0.2   0.6   0.2;  % �����2
                        0.2   0.6   0.2;  % �����3
                        0.2   0.6   0.2];  % �����4

for i = 2:N_slot
    
    % �� ����ں� MCS ����
    % �� ���Խð����� Ȯ�������� ����ȴٰ� ������    
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
           % �����ٸ� ��� ������ �Ҵ���� �����
           % ���� ������ ���� ���ۼӵ���ŭ ������Ű��
           % �Ҵ���� ���Լ��� 1 ���� 
           bytes_sent_case1(j) =  bytes_sent_case1(j)+inst_rate(j);
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
            bytes_sent_case2(j) =  bytes_sent_case2(j)+inst_rate(j);
            counter_user_index_case2(j) = counter_user_index_case2(j)+1;    
       end
       avg_th_case2(i,:) = max((bytes_sent_case2)/i,eps);
       % ��� ó������ 0�̸� ������ ����� ������ �߻��Ͽ�
       % ���� ������ (eps)�� �ٲ�       
   end
   [temp user_index_case2(i)] = max(inst_rate./avg_th_case2(i,:));
   % PF �����ٸ��� ���ۼӵ�/���ó�������� ���� ū ����� ����
   
   % case3: round-robin
   for j=1:N_user
        if (j==user_index_case3(i-1))
            bytes_sent_case3(j) =  bytes_sent_case3(j)+inst_rate(j);
            counter_user_index_case3(j) = counter_user_index_case3(j)+1;    
        end
        avg_th_case3(i,:) = (bytes_sent_case3)/i;
   end
   user_index_case3(i) = mod(i,N_user)+1;
   % RR �����ٸ��� ������� �ѹ��� 
   % mod�Լ� �̿�
   
end

% ����ں� ���� ó����
final_per_user_th = [avg_th_case1(N_slot,:); 
                    avg_th_case2(N_slot,:); 
                    avg_th_case3(N_slot,:)]
final_total_th = sum(final_per_user_th')'

% scheduling probability
scheduling_prob = [counter_user_index_case1 / N_slot;
                   counter_user_index_case2 / N_slot;
                   counter_user_index_case3 / N_slot]
               
figure;
subplot(3,1,1)
plot(avg_th_case1);
xlabel('time')
ylabel('throughput (bit/sec)');
title('Max-min scheduling');

subplot(3,1,2)
plot(avg_th_case2);
xlabel('time')
ylabel('throughput (bit/sec)');
title('proportional fair scheduling');


subplot(3,1,3)
plot(avg_th_case3);
xlabel('time')
ylabel('throughput (bit/sec)');
title('round-robin scheduling');
