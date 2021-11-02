%실습 3 오징어게임
%함수 1:한 번의 시행에서 각 말들의 성공 여부
%입력: 다리 개수와 말의 개수
%출력: 각 말의 최종 성공 여부

function final_result = squid_game(M_bridge, N_user)

    % 입출력 파라미터
    % M_bridge: 다리 개수
    % N_user: 게임 참가자
    % final_result: 최종 게임 결과(1이면 성공, 0이면 실패)
    
    % 상태 변수
    num_success = zeros(N_user, 1);
    % n번째 말이 성공적으로 건넌 다리의 수(k라 한다면)
    % n+1번째 말은 k+1번째 다리는 1의 확률로 성공함
    selected_bridge = NaN(N_user, M_bridge);
    final_result = zeros(N_user, 1);
    safe_bridge = rand(M_bridge, 1) > 0.5;
    % 각 단계에서 안전한 징검다리는 1/2 확률로 0 또는 1
    %safe_bridge = [0 0 1 1 0 0 0 1];
    
    %최초의 말이 진행한 다리의 개수 
    for i=1:M_bridge
        selected_bridge(1, i) = (rand > 0.5);
        if selected_bridge(1, i) == safe_bridge(i)
            num_success(1) = num_success(1) + 1;
        else
            % 잘못된 선택을 하면 해당 말은 게임 종료
            break;
        end
    end
    
    if num_success(1) == M_bridge % 첫 번째 말이 18개 모두 성공
        final_result(1:N_user) = 1; % 전원 성공
        return;
    elseif num_success(1) == M_bridge - 1 % 첫 번쨰 말이17개 성공
        final_result(1) = 0; % 첫 번째 말은 실패
        final_result(2:N_user) = 1; % 나머지 말들은 성공
        return;
    end
    
    % 2번째 말부터 선택 반복
    for i = 2:N_user
        % 이전 말의 올바른 선택을 그대로 따름
        for j = 1:num_success(i - 1)
            selected_bridge(i, j) = selected_bridge(i-1, j);
        end
    
        % 이전 말의 마지막 틀린 선택을 정정
        if selected_bridge(i-1, num_success(i-1) + 1) == 0
            selected_bridge(i, num_success(i-1) + 1) = 1;
        else
            selected_bridge(i, num_success(i-1) + 1) = 0; 
        end
        num_success(i) = num_success(i-1) + 1;
    
        % 이전 말의 마지막 선택 정정 이후 임의 선택 반복
        for j = num_success(i-1)+2:M_bridge % 정정 이후부터 끝까지 탐색 
            selected_bridge(i, j) = (rand) > 0.5; % 유리 선택
            if selected_bridge(i, j) == safe_bridge(j) 
                % 안전한 다리 선택
                num_success(i) = num_success(i) + 1;
            else
                % 선택 실패 시 i번쨰 말 게임 종료
                break;
            end
        end
    
        % i번째 말 게임 종료
        if num_success(i) == M_bridge
            % 모두 성공하고 게임 종료, 이후 말들도 모두 성공
            for j = i+1:N_user
                selected_bridge(j,:) = selected_bridge(i,:);
            end
            num_success(i+1:N_user) = M_bridge;
            final_result(i:N_user) = 1;
            break;
        elseif num_success(i) == M_bridge - 1
            % 마지막 다리를 제외하고 모두 성공, 게임 종료
            for j = i+1:N_user
                selected_bridge(j, 1:M_bridge-1) = selected_bridge(i, 1:M_bridge-1);
                if selected_bridge(i,M_bridge) == 0 % 이전 말이 0을 선택해 탈락했다면
                    selected_bridge(j, M_bridge) = 1; % 현재 말은 1을 선택
                else % 이전 말이 1을 선택해 탈락했다면
                    selected_bridge(j, M_bridge) = 0; % 현재 말은 0을 선택
                end
            end
            num_success(i+1:N_user) = M_bridge;
            final_result(i+1:N_user) = 1;
            break;
        end
    end
