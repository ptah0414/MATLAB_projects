%-------------------------------------------
% INC4103: �����ٸ� �ǽ�1
% MCS�� ������ ��� 
%-------------------------------------------

% 3���� �����ٸ� ��å �����
% case1: max-min
% case2: proportional fair
% case3: round-robin

% �ϳ��� �ð� ������ �� ���� ����ڿ��� �Ҵ�ȴٰ� ����

clear;
close all;

N_slot = 1000;    % ��ü ���� ��
N_user = 3;       % ����� ��

% ���� ���� & �ʱ�ȭ  
% �� �����ٸ� ����� ����ں� ���� ���� ������ ��
bytes_sent_case1 = zeros(1,N_user);
bytes_sent_case2 = zeros(1,N_user);
bytes_sent_case3 = zeros(1,N_user);

% �� �����ٸ� ����� ����ں� ��� ó���� (���� ���)
% (��,��)=(�ð�,�����)
avg_th_case1 = zeros(N_slot,N_user);
avg_th_case2 = zeros(N_slot,N_user);
avg_th_case3 = zeros(N_slot,N_user);

% ä�� ���´� ������ �ʴ´ٰ� ����
% 3���� ����� �����
%   - User1: SNR=30dB --> Rate = 8 bit/sec
%   - User2: SNR=10dB --> Rate = 4 bit/sec
%   - User3: SNR= 5dB --> Rate = 1 bit/sec
inst_rate = [8 4 1]; % �� ����ں� ���Դ� ���� ����Ʈ ��

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


for i = 2:N_slot
    
   % case1: max-min   
   for j=1:N_user
       if (j==user_index_case1(i-1))
           % i��° ������ �Ҵ�޴� ����� j�� 
           % ���� (i-1)��° ���� �ð������� ��� ó�����κ��� ����ϰ�
           % ����� j�� ���� ������ ���� ���ۼӵ���ŭ ������Ű��
           % �Ҵ���� ���Լ��� 1 ���� 
           bytes_sent_case1(j) =  bytes_sent_case1(j)+inst_rate(j);
           counter_user_index_case1(j) = counter_user_index_case1(j)+1;           
       end
       % ����ں� ó���� ������Ʈ 
       % i��° ���� �ð����� �����Ͽ� ������ ������ ��
       avg_th_case1(i,:) = (bytes_sent_case1)/i;
       % ���� ���� �ð��� �����ٸ� ����� ����
       [temp user_index_case1(i)] = min(avg_th_case1(i,:));   
       % max-min�� ��� ó������ ���� ���� ����ڸ� ������
       % ����, ���� �ּҰ��� �����ٸ� �� �� ù��°
       % min()�Լ��� return���� 2���ε�, 
       % ù��°�� �ּҰ�, �ι�°�� �ּҰ��� ������ �ε���
    end
   
   % case2: proportional fair   
   for j=1:N_user
       if (j==user_index_case2(i-1))
            bytes_sent_case2(j) =  bytes_sent_case2(j)+inst_rate(j);
            counter_user_index_case2(j) = counter_user_index_case2(j)+1;    
       end
       avg_th_case2(i,:) = max((bytes_sent_case2)/i,eps);
       % ��� ó������ 0�̸� ������ ����� ������ �߻��Ͽ�
       % ���� ������ (eps)�� ��ü       
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

% ���� ó����
avg_th_case1(N_slot,:);
avg_th_case2(N_slot,:);
avg_th_case3(N_slot,:);

% �����ٸ� Ȯ��
% = �Ҵ���� ���Լ� / ��ü ���Լ�
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