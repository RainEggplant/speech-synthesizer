% ���� + ����㷨 
% filename: pcm ��Ƶ�ļ�������·��
% sr: ������
% speed: �ϳ�������ԭʼ�������ٶ�֮��
% pitch: �ϳ�������ԭʼ�����Ļ���Ƶ��֮��
% peak: �����Ƶ�ʵ�������
function s_syn = speechproc_pro(filename, sr, speed, pitch, peak)
    % ���峣��
    INT16_MAX_ABS = 32768;
    FL = 80;                % ֡��
    FL_out = round(FL/speed); % �������֡��
    WL = 240;               % ����
    P = 10;                 % Ԥ��ϵ������
    s = readspeech(filename, 100000);     % �������� s
    L = length(s);          % ������������
    FN = floor(L/FL)-2;     % ����֡��
    L_out = FL_out*(FN+2); % �����������
    % Ԥ���˲���
    exc = zeros(L, 1);       % �����źţ�Ԥ����
    zi_pre = zeros(P, 1);    % Ԥ���˲�����״̬
    % �ϳ��˲���
    exc_syn = zeros(L_out,1);   % �ϳɵļ����źţ����崮��
    s_syn = zeros(L_out,1);     % �ϳ�����
    zi_syn = zeros(P,1);    % �ϳ��˲�����״̬
    
    hw = hamming(WL);       % ������
    
    pulse_pos = 2*FL_out+1;     % �����źŵ���ʼλ��
    
    % ���δ���ÿ֡����
    for n = 3:FN
        % ����Ԥ��ϵ��������Ҫ���գ�
        s_w = s(n*FL-WL+1:n*FL).*hw;    % ��������Ȩ�������
        [A, E] = lpc(s_w, P);            % ������Ԥ�ⷨ���� P ��Ԥ��ϵ��
                                        % A��Ԥ��ϵ����E �ᱻ��������ϳɼ���������
        
        s_f = s((n-1)*FL+1:n*FL);       % ��֡�����������Ҫ����������

        % �� filter ������ s_f ���㼤����ע�Ᵽ���˲���״̬
        [exc((n-1)*FL+1:n*FL), zi_pre] = filter(A, 1, s_f, zi_pre);

        % ע������ֻ���ڵõ� exc ��Ż������ȷ
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % ����������� PT����Ҫ�����գ�
        G = sqrt(E*PT);           % ����ϳɼ��������� G����Ҫ�����գ�
      

        % ���ı�Ԥ��ϵ�����ı�ϳɼ����ĳ��ȡ��������ڣ��ı乲���Ƶ�ʣ�
        % �ϳ���������
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

% �� PCM �ļ��ж�������
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
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
