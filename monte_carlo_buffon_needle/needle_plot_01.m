clear; clc;
X_max = 100; % ���� ���� ũ�� 
Y_max = 100; % ���� ���� ũ�� 
needle_length = 10;  % �ٴ� ����
line_width = 10;    % ���༱ ����

% ���༱ �׸���
N_grid = floor(Y_max/line_width)-1;
grid_X = zeros(N_grid,1);
grid_Y = [1:N_grid]'*line_width;
figure; hold on;

for i=1:N_grid
    line([0,X_max],[grid_Y(i),grid_Y(i)], 'LineStyle', ':');
end
axis([0, X_max, 0, Y_max]);
rectangle('Position',[0, 0, X_max, Y_max]);

% �ٴ� ��ġ �׸���
N_trial = 10000;
count = 0;

for i = 1:N_trial
    pos_start = [rand*(X_max-2*needle_length)+needle_length, ...
        rand*(Y_max-2*needle_length)+needle_length];
    % pos_start = �ٴ� ���� ��ġ (1��=X ��ǥ, 2��=Y ��ǥ)
    theta = rand * 2*pi;
    pos_end = pos_start + needle_length*[cos(theta), sin(theta)];    
    % pos_end = �ٴ� �� ��ġ (1��=X ��ǥ, 2��=Y ��ǥ)
    line([pos_start(1), pos_end(1)], [pos_start(2), pos_end(2)]);

    if abs(ceil(pos_end(2)/10) - ceil(pos_start(2)/10)) == 1
        count = count + 1;
    end

%     pause;  % ENTER �Է��� ����

end

disp("d: " + line_width +", L: " + needle_length + ", p: " + count/N_trial);

