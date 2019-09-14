% 变速 + 变调算法 
% filename: pcm 音频文件的完整路径
% sr: 采样率
% speed: 合成语音与原始语音的速度之比
% pitch: 合成语音与原始语音的基音频率之比
% peak: 共振峰频率的增减量
function s_syn = speechproc_pro(filename, sr, speed, pitch, peak)
    % 定义常数
    INT16_MAX_ABS = 32768;
    FL = 80;                % 帧长
    FL_out = round(FL/speed); % 输出语音帧长
    WL = 240;               % 窗长
    P = 10;                 % 预测系数个数
    s = readspeech(filename, 100000);     % 载入语音 s
    L = length(s);          % 读入语音长度
    FN = floor(L/FL)-2;     % 计算帧数
    L_out = FL_out*(FN+2); % 输出语音长度
    % 预测滤波器
    exc = zeros(L, 1);       % 激励信号（预测误差）
    zi_pre = zeros(P, 1);    % 预测滤波器的状态
    % 合成滤波器
    exc_syn = zeros(L_out,1);   % 合成的激励信号（脉冲串）
    s_syn = zeros(L_out,1);     % 合成语音
    zi_syn = zeros(P,1);    % 合成滤波器的状态
    
    hw = hamming(WL);       % 汉明窗
    
    pulse_pos = 2*FL_out+1;     % 激励信号的起始位置
    
    % 依次处理每帧语音
    for n = 3:FN
        % 计算预测系数（不需要掌握）
        s_w = s(n*FL-WL+1:n*FL).*hw;    % 汉明窗加权后的语音
        [A, E] = lpc(s_w, P);            % 用线性预测法计算 P 个预测系数
                                        % A是预测系数，E 会被用来计算合成激励的能量
        
        s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理

        % 用 filter 函数和 s_f 计算激励，注意保持滤波器状态
        [exc((n-1)*FL+1:n*FL), zi_pre] = filter(A, 1, s_f, zi_pre);

        % 注意下面只有在得到 exc 后才会计算正确
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % 计算基音周期 PT（不要求掌握）
        G = sqrt(E*PT);           % 计算合成激励的能量 G（不要求掌握）
      

        % 不改变预测系数，改变合成激励的长度、基音周期，改变共振峰频率，
        % 合成新语音。
        while pulse_pos <= n*FL_out
           exc_syn(pulse_pos) = G;
           pulse_pos = pulse_pos+round(PT/pitch);
        end
        A_new = rotate_poles(A, 2*pi*peak/sr);
        [s_syn((n-1)*FL_out+1:n*FL_out), zi_syn] = ...
            filter(1, A_new, exc_syn((n-1)*FL_out+1:n*FL_out), zi_syn);
    end
    s_syn = s_syn/INT16_MAX_ABS;
return

% 从 PCM 文件中读入语音
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% 计算一段语音的基音周期，不要求掌握
function PT = findpitch(s)
    [B, A] = butter(5, 700/4000);
    s = filter(B, A, s);
    R = zeros(143, 1);
    for k=1:143
        R(k) = s(144:223)'*s(144-k:223-k);
    end
    [R1, T1] = max(R(80:143));
    T1 = T1 + 79;
    R1 = R1/(norm(s(144-T1:223-T1))+1);
    [R2, T2] = max(R(40:79));
    T2 = T2 + 39;
    R2 = R2/(norm(s(144-T2:223-T2))+1);
    [R3, T3] = max(R(20:39));
    T3 = T3 + 19;
    R3 = R3/(norm(s(144-T3:223-T3))+1);
    Top = T1;
    Rop = R1;
    if R2 >= 0.85*Rop
        Rop = R2;
        Top = T2;
    end
    if R3 > 0.85*Rop
        Rop = R3;
        Top = T3;
    end
    PT = Top;
return
