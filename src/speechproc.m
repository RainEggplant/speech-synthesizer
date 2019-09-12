function speechproc()

    % ���峣��
    INT16_MAX_ABS = 32768;
    sr = 8000;
    FL = 80;                % ֡��
    WL = 240;               % ����
    P = 10;                 % Ԥ��ϵ������
    s = readspeech('../resources/voice.pcm', 100000);     % �������� s
    L = length(s);          % ������������
    FN = floor(L/FL)-2;     % ����֡��
    % Ԥ����ؽ��˲���
    exc = zeros(L,1);       % �����źţ�Ԥ����
    zi_pre = zeros(P,1);    % Ԥ���˲�����״̬
    s_rec = zeros(L,1);     % �ؽ�����
    zi_rec = zeros(P,1);
    % �ϳ��˲���
    exc_syn = zeros(L,1);   % �ϳɵļ����źţ����崮��
    s_syn = zeros(L,1);     % �ϳ�����
    zi_syn = zeros(P,1);    % �ϳ��˲�����״̬
    % ����������˲���
    exc_syn_t = zeros(L,1);   % �ϳɵļ����źţ����崮��
    s_syn_t = zeros(L,1);     % �ϳ�����
    zi_syn_t = zeros(P,1);    % �ϳ��˲�����״̬����������٣�
    % ���ٲ�����˲����������ٶȼ���һ����
    FL_v = FL*2;
    exc_syn_v = zeros(2*L,1);   % �ϳɵļ����źţ����崮��
    s_syn_v = zeros(2*L,1);     % �ϳ�����
    zi_syn_v = zeros(P,1);      % �ϳ��˲�����״̬�����ٲ������
    
    hw = hamming(WL);       % ������
    
    pulse_pos = 2*FL+1;     % �����źŵ���ʼλ��
    pulse_pos_v = 2*FL_v+1;
    pulse_pos_t = 2*FL+1;  
    
    % ���δ���ÿ֡����
    for n = 3:FN

        % ����Ԥ��ϵ��������Ҫ���գ�
        s_w = s(n*FL-WL+1:n*FL).*hw;    % ��������Ȩ�������
        [A, E] = lpc(s_w, P);            % ������Ԥ�ⷨ���� P ��Ԥ��ϵ��
                                        % A��Ԥ��ϵ����E �ᱻ��������ϳɼ���������

        if n == 27
            % (3) �ڴ�λ��д���򣬹۲�Ԥ��ϵͳ���㼫��ͼ
            figure;
            zplane(A, 1);
            title('27 ֡ʱԤ��ϵͳ���㡢����ֲ�ͼ');
        end
        
        s_f = s((n-1)*FL+1:n*FL);       % ��֡�����������Ҫ����������

        % (4) �ڴ�λ��д������ filter ���� s_f ���㼤����ע�Ᵽ���˲���״̬
        [exc((n-1)*FL+1:n*FL), zi_pre] = filter(A, 1, s_f, zi_pre);
        
        % (5) �ڴ�λ��д������ filter ������ exc �ؽ�������ע�Ᵽ���˲���״̬
        [s_rec((n-1)*FL+1:n*FL), zi_rec] = ... 
            filter(1, A, exc((n-1)*FL+1:n*FL), zi_rec);

        % ע������ֻ���ڵõ� exc ��Ż������ȷ
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % ����������� PT����Ҫ�����գ�
        G = sqrt(E*PT);           % ����ϳɼ��������� G����Ҫ�����գ�
      
        % (10) �ڴ�λ��д�������ɺϳɼ��������ü����� filter ���������ϳ�����
        while pulse_pos <= n*FL
           exc_syn(pulse_pos) = G;
           pulse_pos = pulse_pos+PT;
        end
        [s_syn((n-1)*FL+1:n*FL), zi_syn] = ...
            filter(1, A, exc_syn((n-1)*FL+1:n*FL), zi_syn);

        % (11) ���ı�������ں�Ԥ��ϵ�������ϳɼ����ĳ�������һ��������Ϊ filter
        % ������õ��µĺϳ���������һ���ǲ����ٶȱ����ˣ�������û�б䡣
        while pulse_pos_v <= n*FL_v
           exc_syn_v(pulse_pos_v) = G;
           pulse_pos_v = pulse_pos_v+PT;
        end
        [s_syn_v((n-1)*FL_v+1:n*FL_v), zi_syn_v] = ...
            filter(1, A, exc_syn_v((n-1)*FL_v+1:n*FL_v), zi_syn_v);

        % (13) ���������ڼ�Сһ�룬�������Ƶ������ 150Hz�����ºϳ�������������ɶ���ܡ�
        while pulse_pos_t <= n*FL
           exc_syn_t(pulse_pos_t) = G;
           pulse_pos_t = pulse_pos_t+round(PT/2);
        end
        A_150 = rotate_poles(A, 2*pi*150/sr);
        [s_syn_t((n-1)*FL+1:n*FL), zi_syn_t] = ...
            filter(1, A_150, exc_syn_t((n-1)*FL+1:n*FL), zi_syn_t);
    end

    % (6) �ڴ�λ��д������һ�� s, exc �� s_rec �к����𣬽�����������
    sound([s; s_rec; exc] / INT16_MAX_ABS, sr);
    
    % �����߲���
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
    
    % �����߾ֲ�����
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
    
    % ���� s �� exc ��Ƶ��ͼ
    S = fft(s);
    EXC = fft(exc);
    freq = sr*(0:(L/2))/L;
    figure;
    subplot(2, 1, 1);
    plot(freq, abs(S(1:L/2+1)));
    ylabel('s(n) Ƶ��');
    
    subplot(2, 1, 2);
    plot(freq, abs(EXC(1:L/2+1)));
    ylabel('e(n) Ƶ��');
    pause(6);
    
    % ���� s_syn �� ���� s, s_syn ����
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
    
    % ���� s_syn_v
    sound(s_syn_v/INT16_MAX_ABS, sr);
    pause(4);
    
    % ���� s_syn_t ������ s, s_syn_t ����
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
    
    
    % ���������ļ�
    writespeech('exc.pcm', exc);
    writespeech('rec.pcm', s_rec);
    writespeech('exc_syn.pcm', exc_syn);
    writespeech('syn.pcm', s_syn);
    writespeech('exc_syn_t.pcm', exc_syn_t);
    writespeech('syn_t.pcm', s_syn_t);
    writespeech('exc_syn_v.pcm', exc_syn_v);
    writespeech('syn_v.pcm', s_syn_v);
return

% �� PCM �ļ��ж�������
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% д������ PCM �ļ���
function writespeech(filename,s)
    fid = fopen(filename, 'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% ����һ�������Ļ������ڣ���Ҫ������
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
