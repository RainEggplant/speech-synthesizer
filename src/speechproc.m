function speechproc()

    % 定义常数
    INT16_MAX_ABS = 32768;
    sr = 8000;
    FL = 80;                % 帧长
    WL = 240;               % 窗长
    P = 10;                 % 预测系数个数
    s = readspeech('../resources/voice.pcm', 100000);     % 载入语音 s
    L = length(s);          % 读入语音长度
    FN = floor(L/FL)-2;     % 计算帧数
    % 预测和重建滤波器
    exc = zeros(L,1);       % 激励信号（预测误差）
    zi_pre = zeros(P,1);    % 预测滤波器的状态
    s_rec = zeros(L,1);     % 重建语音
    zi_rec = zeros(P,1);
    % 合成滤波器
    exc_syn = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn = zeros(L,1);     % 合成语音
    zi_syn = zeros(P,1);    % 合成滤波器的状态
    % 变调不变速滤波器
    exc_syn_t = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn_t = zeros(L,1);     % 合成语音
    zi_syn_t = zeros(P,1);    % 合成滤波器的状态（变调不变速）
    % 变速不变调滤波器（假设速度减慢一倍）
    FL_v = FL*2;
    exc_syn_v = zeros(2*L,1);   % 合成的激励信号（脉冲串）
    s_syn_v = zeros(2*L,1);     % 合成语音
    zi_syn_v = zeros(P,1);      % 合成滤波器的状态（变速不变调）
    
    hw = hamming(WL);       % 汉明窗
    
    pulse_pos = 2*FL+1;     % 激励信号的起始位置
    pulse_pos_v = 2*FL_v+1;
    pulse_pos_t = 2*FL+1;  
    
    % 依次处理每帧语音
    for n = 3:FN

        % 计算预测系数（不需要掌握）
        s_w = s(n*FL-WL+1:n*FL).*hw;    % 汉明窗加权后的语音
        [A, E] = lpc(s_w, P);            % 用线性预测法计算 P 个预测系数
                                        % A是预测系数，E 会被用来计算合成激励的能量

        if n == 27
            % (3) 在此位置写程序，观察预测系统的零极点图
            figure;
            zplane(A, 1);
            title('27 帧时预测系统的零、极点分布图');
        end
        
        s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理

        % (4) 在此位置写程序，用 filter 函数 s_f 计算激励，注意保持滤波器状态
        [exc((n-1)*FL+1:n*FL), zi_pre] = filter(A, 1, s_f, zi_pre);
        
        % (5) 在此位置写程序，用 filter 函数和 exc 重建语音，注意保持滤波器状态
        [s_rec((n-1)*FL+1:n*FL), zi_rec] = ... 
            filter(1, A, exc((n-1)*FL+1:n*FL), zi_rec);

        % 注意下面只有在得到 exc 后才会计算正确
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % 计算基音周期 PT（不要求掌握）
        G = sqrt(E*PT);           % 计算合成激励的能量 G（不要求掌握）
      
        % (10) 在此位置写程序，生成合成激励，并用激励和 filter 函数产生合成语音
        while pulse_pos <= n*FL
           exc_syn(pulse_pos) = G;
           pulse_pos = pulse_pos+PT;
        end
        [s_syn((n-1)*FL+1:n*FL), zi_syn] = ...
            filter(1, A, exc_syn((n-1)*FL+1:n*FL), zi_syn);

        % (11) 不改变基音周期和预测系数，将合成激励的长度增加一倍，再作为 filter
        % 的输入得到新的合成语音，听一听是不是速度变慢了，但音调没有变。
        while pulse_pos_v <= n*FL_v
           exc_syn_v(pulse_pos_v) = G;
           pulse_pos_v = pulse_pos_v+PT;
        end
        [s_syn_v((n-1)*FL_v+1:n*FL_v), zi_syn_v] = ...
            filter(1, A, exc_syn_v((n-1)*FL_v+1:n*FL_v), zi_syn_v);

        % (13) 将基音周期减小一半，将共振峰频率增加 150Hz，重新合成语音，听听是啥感受～
        while pulse_pos_t <= n*FL
           exc_syn_t(pulse_pos_t) = G;
           pulse_pos_t = pulse_pos_t+round(PT/2);
        end
        A_150 = rotate_poles(A, 2*pi*150/sr);
        [s_syn_t((n-1)*FL+1:n*FL), zi_syn_t] = ...
            filter(1, A_150, exc_syn_t((n-1)*FL+1:n*FL), zi_syn_t);
    end

    % (6) 在此位置写程序，听一听 s, exc 和 s_rec 有何区别，解释这种区别
    sound([s; s_rec; exc] / INT16_MAX_ABS, sr);
    
    % 画三者波形
    time = [0:L-1] / sr;
    figure;
    ax1 = subplot(3, 1, 1);
    plot(time, s);
    ylabel('s(n)');
    
    ax2 = subplot(3, 1, 2);
    plot(time, s_rec);
    ylabel('$\hat{s}(n)$', 'Interpreter', 'latex');

    ax3 = subplot(3, 1, 3);
    plot(time, exc);
    ylabel('e(n)');
    
    linkaxes([ax1, ax2, ax3],'xy')
    ylim([-INT16_MAX_ABS, INT16_MAX_ABS]);
    
    % 画三者局部波形
    part_time = 0.6:1/sr:0.78;
    sample_range = 0.6*sr:0.78*sr;
    figure;
    ax1 = subplot(3, 1, 1);
    plot(part_time, s(sample_range));
    ylabel('s(n)');
    
    ax2 = subplot(3, 1, 2);
    plot(part_time, s_rec(sample_range));
    ylabel('$\hat{s}(n)$', 'Interpreter', 'latex');
    
    ax3 = subplot(3, 1, 3);
    plot(part_time, exc(sample_range));
    ylabel('e(n)');
    
    linkaxes([ax1, ax2, ax3],'xy')
    xlim([0.6, 0.78]);
    ylim([-1.2e4, 1.2e4]);
    
    % 画出 s 和 exc 的频谱图
    S = fft(s);
    EXC = fft(exc);
    freq = sr*(0:(L/2))/L;
    figure;
    subplot(2, 1, 1);
    plot(freq, abs(S(1:L/2+1)));
    ylabel('s(n) 频谱');
    
    subplot(2, 1, 2);
    plot(freq, abs(EXC(1:L/2+1)));
    ylabel('e(n) 频谱');
    pause(6);
    
    % 试听 s_syn 并 画出 s, s_syn 波形
    figure;
    ax1 = subplot(2, 1, 1);
    plot(time, s);
    ylabel('s(n)');
    
    ax2 = subplot(2, 1, 2);
    plot(time, s_syn);
    ylabel('$\tilde{s}(n)$', 'Interpreter', 'latex');
    
    linkaxes([ax1, ax2],'xy')
    ylim([-INT16_MAX_ABS, INT16_MAX_ABS]);
    sound(s_syn/INT16_MAX_ABS, sr);
    pause(2);
    
    % 试听 s_syn_v
    sound(s_syn_v/INT16_MAX_ABS, sr);
    pause(4);
    
    % 试听 s_syn_t 并画出 s, s_syn_t 波形
    sound(s_syn_t/INT16_MAX_ABS, sr);
    figure;
    ax1 = subplot(2, 1, 1);
    plot(time, s);
    ylabel('s(n)');
    
    ax2 = subplot(2, 1, 2);
    plot(time, s_syn_t);
    ylabel('s\_syn\_t(n)');
    
    linkaxes([ax1, ax2],'xy')
    ylim([-INT16_MAX_ABS, INT16_MAX_ABS]);
    
    
    % 保存所有文件
    writespeech('exc.pcm', exc);
    writespeech('rec.pcm', s_rec);
    writespeech('exc_syn.pcm', exc_syn);
    writespeech('syn.pcm', s_syn);
    writespeech('exc_syn_t.pcm', exc_syn_t);
    writespeech('syn_t.pcm', s_syn_t);
    writespeech('exc_syn_v.pcm', exc_syn_v);
    writespeech('syn_v.pcm', s_syn_v);
return

% 从 PCM 文件中读入语音
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% 写语音到 PCM 文件中
function writespeech(filename,s)
    fid = fopen(filename, 'w');
    fwrite(fid, s, 'int16');
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
