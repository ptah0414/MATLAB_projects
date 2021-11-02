clear; clc;
figure; hold on;

for j = 1:1000
    X_max = 100; % 방의 가로 크기 
    Y_max = 100; % 방의 세로 크기 
    needle_length = rand * 10;  % 바늘 길이 L
    line_width = rand * 10;    % 평행선 간격 d

    if line_width > needle_length 
            % 평행선 그리기
        N_grid = floor(Y_max/line_width)-1;
        grid_X = zeros(N_grid,1);
        grid_Y = [1:N_grid]'*line_width;
        
        
    %     for i=1:N_grid
    %         line([0,X_max],[grid_Y(i),grid_Y(i)], 'LineStyle', ':');
    %     end
        %axis([0, X_max, 0, Y_max]);
        %rectangle('Position',[0, 0, X_max, Y_max]);
        
        % 바늘 위치 그리기
        N_trial = 1000;
        count = 0;
        block = 1;
    
        for i = 1:N_trial
            pos_start = [rand*(X_max-2*needle_length)+needle_length, ...
                rand*(Y_max-2*needle_length)+needle_length];
            % pos_start = 바늘 시작 위치 (1열=X 좌표, 2열=Y 좌표)
            theta = rand * 2*pi;
            pos_end = pos_start + needle_length*[cos(theta), sin(theta)];    
            % pos_end = 바늘 끝 위치 (1열=X 좌표, 2열=Y 좌표)
            %line([pos_start(1), pos_end(1)], [pos_start(2), pos_end(2)]);
            
            if abs(ceil(pos_end(2)/line_width) - ceil(pos_start(2)/line_width)) == block
                count = count + 1;
            end
        end
        disp("d: " + line_width +", L: " + needle_length + ", p: " + count/N_trial);
        X = needle_length/line_width;
        Y = count/N_trial;
        disp("X: " + X + ", Y: " + Y);
        plot(X, Y, "o");
    
        count = 0;    
    end
end

