clear;clc;
% figure; hold on;
line_width = 10;    % ���༱ ���� d

for j = 1:9
    needle_length = rand * 100;  % �ٴ� ���� L

    X_max = 100; % ���� ���� ũ�� 
    Y_max = 100; % ���� ���� ũ�� 

    
    if line_width < needle_length 
            % ���༱ �׸���
        N_grid = floor(Y_max/line_width)-1;
        grid_X = zeros(N_grid,1);
        grid_Y = [1:N_grid]'*line_width;
        
        
    %     for i=1:N_grid
    %         line([0,X_max],[grid_Y(i),grid_Y(i)], 'LineStyle', ':');
    %     end
        %axis([0, X_max, 0, Y_max]);
        %rectangle('Position',[0, 0, X_max, Y_max]);
        
        % �ٴ� ��ġ �׸���
        N_trial = 1000;
        line_count = 0;
        count = 0;

        for i = 1:N_trial
            pos_start = [rand*(X_max-2*needle_length)+needle_length, ...
                rand*(Y_max-2*needle_length)+needle_length];
            % pos_start = �ٴ� ���� ��ġ (1��=X ��ǥ, 2��=Y ��ǥ)
            theta = rand * 2*pi;
            pos_end = pos_start + needle_length*[cos(theta), sin(theta)];    
            % pos_end = �ٴ� �� ��ġ (1��=X ��ǥ, 2��=Y ��ǥ)
            %line([pos_start(1), pos_end(1)], [pos_start(2), pos_end(2)]);
            
            if abs(ceil(pos_end(2)/line_width) - ceil(pos_start(2)/line_width)) ~= 0
                line_count = line_count + abs(ceil(pos_end(2)/line_width) - ceil(pos_start(2)/line_width));
                count = count + 1;
            end
        end

        d = line_width;
        L = needle_length;
        N = needle_length/10;
        p = count/N_trial;

    disp("d: " + d +", L: " + L + ", N: " + N + ", p: " + p);
    %         X = needle_length/line_width;
    %         Y = count/N_trial;
    %         disp("X: " + X + ", Y: " + Y);
    %         plot(X, Y, "o");
        disp("���� ���� Ƚ���� ��밪: " + line_count/N_trial);
        disp("Np: " + N * p)
        disp("___");
        
        count = 0;    
    end
end