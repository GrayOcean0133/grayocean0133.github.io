%% Chapter 2 配图生成脚本
% 运行此脚本将在 Chapter#2 文件夹中生成所有讲义配图
close all; clearvars; clc;
out = 'E:\AI-Link Group\Chapter#2\';

%% ═══ 图1：正弦波基本参数解剖 ═══
f = 1; A = 1.0; T = 1/f;
t = linspace(0, 2.5*T, 2000);
x = A * sin(2*pi*f*t);

fig = figure('Position',[100 100 820 390],'Color','w');
plot(t, x,'Color',[0.15 0.45 0.75],'LineWidth',2.2); hold on;

% RMS 线
rms_val = A/sqrt(2);
yline(rms_val,'--','Color',[0.65 0 0.8],'LineWidth',1.6);
text(0.05, rms_val+0.09, sprintf('V_{rms} = A/\\surd2 ≈ %.2f', rms_val), ...
    'Color',[0.65 0 0.8],'FontSize',10.5);

% 峰值
tp = T/4;
plot([tp tp],[0 A],'r-','LineWidth',1.6);
plot(tp, A,'ro','MarkerSize',9,'MarkerFaceColor','r');
text(tp+0.04, A*0.5,'A（峰值）','Color','r','FontSize',11,'FontWeight','bold');

% 峰峰值（3T/4 处）
tpp = 3*T/4;
plot([tpp tpp],[-A A],'Color',[0 0.58 0],'LineWidth',1.6,'LineStyle','--');
plot(tpp,-A,'v','Color',[0 0.58 0],'MarkerFaceColor',[0 0.58 0],'MarkerSize',8);
plot(tpp, A,'^','Color',[0 0.58 0],'MarkerFaceColor',[0 0.58 0],'MarkerSize',8);
text(tpp+0.04, 0,'2A（峰峰值）','Color',[0 0.58 0],'FontSize',11,'FontWeight','bold');

% 周期
yT = -1.38;
plot([0 T],[yT yT],'k-','LineWidth',1.8);
plot([0 0],[yT-0.06 yT+0.06],'k-','LineWidth',1.8);
plot([T T],[yT-0.06 yT+0.06],'k-','LineWidth',1.8);
text(T/2, yT-0.16,'T（周期）','HorizontalAlignment','center',...
    'FontSize',11,'FontWeight','bold','Color','k');

yline(0,'k:','LineWidth',0.8,'Alpha',0.4);
xlim([0 2.5*T]); ylim([-1.65 1.4]);
xlabel('时间 (s)','FontSize',12); ylabel('幅度','FontSize',12);
title('x(t) = A·sin(2\pit/T)  —  正弦波基本参数','FontSize',13);
grid on; box on;
saveas(fig,[out 'fig2_sine_anatomy.png']); close(fig);

%% ═══ 图2：峰值 / 峰峰值 / RMS 对比 ═══
f = 1; A = 1.0;
t = linspace(0, 2/f, 1000);
x = A * sin(2*pi*f*t);
rms_val = A/sqrt(2);

fig = figure('Position',[100 100 820 400],'Color','w');
plot(t, x,'Color',[0.15 0.45 0.75],'LineWidth',2,'DisplayName','正弦波'); hold on;

fill([t fliplr(t)],[rms_val*ones(size(t)) zeros(size(t))], ...
    [0.65 0 0.8],'FaceAlpha',0.10,'EdgeColor','none','DisplayName','RMS 功率等效区');

yline( A,    '--','Color',[0.85 0.2 0.2],'LineWidth',1.8);
yline(-A,    '--','Color',[0.85 0.2 0.2],'LineWidth',1.8);
yline(rms_val,'--','Color',[0.65 0 0.8],'LineWidth',1.8);

text(0.05,  A+0.10, sprintf('V_p = A = %.1f  （峰值）', A), ...
    'Color',[0.85 0.2 0.2],'FontSize',11,'FontWeight','bold');
text(0.05, -A-0.15, sprintf('-V_p = -A = -%.1f', A), ...
    'Color',[0.85 0.2 0.2],'FontSize',11);
text(0.05, rms_val+0.09, sprintf('V_{rms} = %.3f  （有效值 / RMS）', rms_val), ...
    'Color',[0.65 0 0.8],'FontSize',11,'FontWeight','bold');

% 峰峰值双箭头示意
text(1.60, 0, sprintf('\\leftrightarrow  V_{pp} = 2A = %.1f  （峰峰值）', 2*A), ...
    'FontSize',11,'Color',[0.1 0.6 0.1],'FontWeight','bold');

xlim([0 2/f]); ylim([-1.55 1.45]);
xlabel('时间 (s)','FontSize',12); ylabel('幅度（V）','FontSize',12);
title('幅度的三种定义：峰值 / 峰峰值 / 有效值（RMS）','FontSize',13);
legend('Location','southeast','FontSize',10);
grid on;
saveas(fig,[out 'fig2_amplitude_types.png']); close(fig);

%% ═══ 图3：相位差 ═══
f = 1; T = 1/f;
t = linspace(0, 2*T, 1000);
xA = sin(2*pi*f*t);
xB = sin(2*pi*f*t + pi/2);

fig = figure('Position',[100 100 820 390],'Color','w');
plot(t, xA,'b','LineWidth',2.2,'DisplayName','A:  sin(2\pift)'); hold on;
plot(t, xB,'r--','LineWidth',2.2,'DisplayName','B:  sin(2\pift + 90°)');
yline(0,'k:','LineWidth',0.8,'Alpha',0.4);

shift = T/4;
y_arr = -1.42;
plot([0 shift],[y_arr y_arr],'k-','LineWidth',2);
plot([0 0],    [y_arr-0.07 y_arr+0.07],'k-','LineWidth',2);
plot([shift shift],[y_arr-0.07 y_arr+0.07],'k-','LineWidth',2);
text(shift/2, y_arr-0.17,'B 超前 A：\DeltaT = T/4，\Delta\phi = 90°', ...
    'HorizontalAlignment','center','FontSize',11,'FontWeight','bold');

xlim([0 2*T]); ylim([-1.75 1.35]);
xlabel('时间 (s)','FontSize',12); ylabel('幅度','FontSize',12);
title('相位差示意：同频率、不同相位的两个信号','FontSize',13);
legend('Location','northeast','FontSize',11);
grid on;
saveas(fig,[out 'fig2_phase_diff.png']); close(fig);

%% ═══ 图4：包络 ═══
fs = 4000; t = (0:1/fs:1.5-1/fs);
fc = 60; fm = 2.5; m = 0.7;

env_pos = (1 + m*sin(2*pi*fm*t));
env_neg = -(1 + m*sin(2*pi*fm*t));
am_sig  = env_pos .* cos(2*pi*fc*t);

fig = figure('Position',[100 100 820 400],'Color','w');
plot(t, am_sig,'Color',[0.55 0.75 0.95],'LineWidth',0.8, ...
    'DisplayName','AM 信号（载波 60 Hz）'); hold on;
plot(t, env_pos,'r-','LineWidth',2.5,'DisplayName','正包络');
plot(t, env_neg,'r-','LineWidth',2.5,'HandleVisibility','off');
yline(0,'k:','LineWidth',0.8,'Alpha',0.4);

xlabel('时间 (s)','FontSize',12); ylabel('幅度','FontSize',12);
title('包络（Envelope）：高频载波（60 Hz）被低频信号（2.5 Hz）调幅后的外轮廓','FontSize',12);
legend('Location','northeast','FontSize',11);
xlim([0 1.5]); ylim([-2.2 2.2]);
grid on;
saveas(fig,[out 'fig2_envelope.png']); close(fig);

%% ═══ 图5：DC / AC 分解 ═══
fs = 500; t = (0:1/fs:2-1/fs);
dc  = 1.5;
ac  = sin(2*pi*3*t) + 0.5*sin(2*pi*9*t);
sig = dc + ac;

fig = figure('Position',[100 100 820 520],'Color','w');

ax1 = subplot(3,1,1);
plot(t, sig,'b','LineWidth',1.5); hold on;
yline(dc,'r--','LineWidth',1.6);
text(0.05, dc+0.2, sprintf('均值（DC）= %.1f V', dc),'Color','r','FontSize',10.5);
ylabel('幅度（V）'); title('原始信号 = 直流分量 + 交流分量'); grid on;

ax2 = subplot(3,1,2);
plot(t, dc*ones(size(t)),'r','LineWidth',2.5);
ylim([-0.5 3]); ylabel('幅度（V）');
title(sprintf('直流分量（DC = %.1f V）：对应频谱 0 Hz 处的分量', dc)); grid on;

ax3 = subplot(3,1,3);
plot(t, ac,'Color',[0 0.6 0],'LineWidth',1.5);
yline(0,'k:','LineWidth',0.8);
ylabel('幅度（V）'); xlabel('时间 (s)');
title('交流分量（AC）：均值 = 0，携带实际信息'); grid on;

linkaxes([ax1 ax2 ax3],'x');
saveas(fig,[out 'fig2_dc_ac.png']); close(fig);

%% ═══ 图6：脉冲信号解剖 ═══
VH = 3.3; VL = 0;
tr = 0.07; tf = 0.05; tw = 0.38; Tp = 0.80;

t_pts = [0, tr, tr+tw, tr+tw+tf, Tp, ...
         Tp+tr, Tp+tr+tw, Tp+tr+tw+tf, 2*Tp];
v_pts = [VL, VH, VH, VL, VL, VH, VH, VL, VL];

fig = figure('Position',[100 100 860 430],'Color','w');
plot(t_pts, v_pts,'b','LineWidth',2.8); hold on;

% VH / VL 参考线
yline(VH,'r:','LineWidth',1.2,'Alpha',0.7);
yline(VL,'k:','LineWidth',1.2,'Alpha',0.5);
text(-0.07, VH,    sprintf('V_H = %.1f V',VH),'Color','r','FontSize',10.5, ...
    'HorizontalAlignment','right','FontWeight','bold');
text(-0.07, VL+0.1, sprintf('V_L = %.1f V',VL),'Color',[0.3 0.3 0.3],'FontSize',10.5, ...
    'HorizontalAlignment','right');

% 上升时间 t_r
y_tr = VH + 0.40;
plot([0 tr],[y_tr y_tr],'Color',[0.85 0.4 0],'LineWidth',1.8);
plot([0 0], [VH VH+0.48],'Color',[0.85 0.4 0],'LineStyle',':','LineWidth',1);
plot([tr tr],[VH VH+0.48],'Color',[0.85 0.4 0],'LineStyle',':','LineWidth',1);
text(tr/2, y_tr+0.11,'t_r','HorizontalAlignment','center','FontSize',12, ...
    'Color',[0.85 0.4 0],'FontWeight','bold');

% 脉宽 t_w
y_tw = VH + 0.78;
plot([tr tr+tw],[y_tw y_tw],'k-','LineWidth',1.8);
plot([tr tr],    [VH+0.55 y_tw+0.06],'k:','LineWidth',1);
plot([tr+tw tr+tw],[VH+0.55 y_tw+0.06],'k:','LineWidth',1);
text((tr + tr+tw)/2, y_tw+0.13,'t_w（脉宽）','HorizontalAlignment','center', ...
    'FontSize',11,'FontWeight','bold');

% 下降时间 t_f
t_fall = tr + tw;
plot([t_fall t_fall+tf],[y_tr y_tr],'Color',[0 0.5 0.8],'LineWidth',1.8);
text((t_fall + t_fall+tf)/2, y_tr+0.11,'t_f','HorizontalAlignment','center', ...
    'FontSize',12,'Color',[0 0.5 0.8],'FontWeight','bold');

% 周期 T
D = tw/Tp*100;
y_Tp = -0.58;
plot([0 Tp],[y_Tp y_Tp],'Color',[0.3 0.3 0.3],'LineWidth',1.8);
plot([0 0], [y_Tp-0.08 y_Tp+0.08],'Color',[0.3 0.3 0.3],'LineWidth',1.8);
plot([Tp Tp],[y_Tp-0.08 y_Tp+0.08],'Color',[0.3 0.3 0.3],'LineWidth',1.8);
text(Tp/2, y_Tp-0.20, sprintf('T = %.2f s，占空比 D = t_w / T = %.0f%%', Tp, D), ...
    'HorizontalAlignment','center','FontSize',11,'Color',[0.3 0.3 0.3],'FontWeight','bold');

xlim([-0.12 2*Tp+0.05]); ylim([-0.95 VH+1.15]);
xlabel('时间 (s)','FontSize',12); ylabel('电压 (V)','FontSize',12);
title(sprintf('脉冲信号参数解剖（V_H=%.1fV，t_w=%.0fms，D=%.0f%%，T=%.0fms）', ...
    VH, tw*1000, D, Tp*1000),'FontSize',13);
grid on;
saveas(fig,[out 'fig2_pulse_anatomy.png']); close(fig);

%% ═══ 图7：CW vs 脉冲 频域对比 ═══
fig = figure('Position',[100 100 900 400],'Color','w');

% 左：CW 单根谱线
subplot(1,2,1);
fc_cw = 50;
stem(fc_cw, 1,'filled','b','MarkerSize',12,'LineWidth',2.5); hold on;
plot([0 150],[0 0],'k-','LineWidth',0.8);
xlim([0 150]); ylim([0 1.45]);
xlabel('频率 (Hz)','FontSize',11); ylabel('幅度','FontSize',11);
title({'连续波（CW）','能量集中在单一频点'},'FontSize',12);
text(fc_cw, 1.15, sprintf('f_c = %d Hz', fc_cw), ...
    'HorizontalAlignment','center','FontSize',11.5,'Color','b','FontWeight','bold');
grid on;

% 右：脉冲 sinc 宽谱
subplot(1,2,2);
tw_v = 0.01;
f_ax = linspace(-200, 200, 4000);
X_sinc = abs(tw_v * sinc(f_ax * tw_v));

plot(f_ax, X_sinc,'r-','LineWidth',2); hold on;
xline( 1/tw_v,'k--','LineWidth',1.5);
xline(-1/tw_v,'k--','LineWidth',1.5);
text( 1/tw_v + 5, 0.0055, sprintf('1/t_w\n= %d Hz', round(1/tw_v)), ...
    'FontSize',9.5,'Color','k');
text(-1/tw_v - 5, 0.0055, sprintf('-1/t_w\n= -%d Hz', round(1/tw_v)), ...
    'FontSize',9.5,'Color','k','HorizontalAlignment','right');

fill([f_ax fliplr(f_ax)],[X_sinc zeros(size(f_ax))], ...
    'r','FaceAlpha',0.12,'EdgeColor','none');

xlim([-200 200]); ylim([0 tw_v*1.3]);
xlabel('频率 (Hz)','FontSize',11); ylabel('幅度','FontSize',11);
title({'脉冲信号（sinc 频谱）','能量分散在宽频带'},'FontSize',12);
grid on;

sgtitle('CW 信号 vs 脉冲信号：频域的本质区别','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_cw_vs_pulse_spectrum.png']); close(fig);

%% ═══ 图8：时域 vs 频域（同一信号的两张地图）═══
fs = 2000; t = (0:1/fs:1-1/fs); N = length(t);
x = sin(2*pi*50*t) + 0.6*sin(2*pi*120*t) + 0.3*sin(2*pi*300*t);

X   = fft(x);
amp = abs(X(1:N/2+1)) / (N/2);
amp(1) = amp(1)/2;
f_ax = (0:N/2)*fs/N;

fig = figure('Position',[100 100 920 440],'Color','w');

subplot(1,2,1);
plot(t(1:200), x(1:200),'Color',[0.15 0.45 0.75],'LineWidth',1.6);
xlabel('时间 (s)','FontSize',11); ylabel('幅度','FontSize',11);
title({'时域（示波器视图）','看到波形，但读不出频率组成'},'FontSize',12);
grid on;

subplot(1,2,2);
stem(f_ax, amp,'filled','Color',[0.85 0.25 0.1],'MarkerSize',4,'LineWidth',1.2);
xlabel('频率 (Hz)','FontSize',11); ylabel('幅度','FontSize',11);
title({'频域（FFT / 频谱仪视图）','50 Hz + 120 Hz + 300 Hz 三根谱线一目了然'},'FontSize',12);
xlim([0 400]); grid on;
text(50,  1.06,'50 Hz', 'HorizontalAlignment','center','FontSize',10.5, ...
    'Color',[0.85 0.25 0.1],'FontWeight','bold');
text(120, 0.66,'120 Hz','HorizontalAlignment','center','FontSize',10.5, ...
    'Color',[0.85 0.25 0.1],'FontWeight','bold');
text(300, 0.37,'300 Hz','HorizontalAlignment','center','FontSize',10.5, ...
    'Color',[0.85 0.25 0.1],'FontWeight','bold');

sgtitle('同一信号的两张地图：时域 ↔ 频域（傅里叶变换相互转换）', ...
    'FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_time_freq_domains.png']); close(fig);

%% ═══ 图9：AM 调制 ═══
fs = 8000; t = (0:1/fs:0.5-1/fs);
fc = 500; fm = 20; m = 0.7;
s_t     = sin(2*pi*fm*t);
carrier = cos(2*pi*fc*t);
am_sig  = (1 + m*s_t) .* carrier;

fig = figure('Position',[100 100 860 560],'Color','w');

subplot(3,1,1);
plot(t, s_t,'Color',[0 0.5 0.8],'LineWidth',1.8);
ylabel('幅度'); title('① 基带信号 s(t)：20 Hz 正弦波（携带信息）');
xlim([0 0.5]); ylim([-1.3 1.3]); grid on;

subplot(3,1,2);
plot(t, carrier,'Color',[0.55 0.55 0.55],'LineWidth',0.8);
ylabel('幅度'); title('② 载波 cos(2\pif_c t)：500 Hz（传输媒介，幅度恒定）');
xlim([0 0.5]); ylim([-1.3 1.3]); grid on;

subplot(3,1,3);
env_p = 1 + m*s_t;
env_n = -(1 + m*s_t);
plot(t, am_sig,'Color',[0.55 0.75 0.95],'LineWidth',0.8,'DisplayName','AM 信号'); hold on;
plot(t, env_p,'r-','LineWidth',2.2,'DisplayName','包络 = 基带形状');
plot(t, env_n,'r-','LineWidth',2.2,'HandleVisibility','off');
ylabel('幅度'); xlabel('时间 (s)');
title('③ AM 调制后：[1 + m·s(t)]·cos(2\pif_c t)，包络还原基带信号');
legend('Location','southeast','FontSize',10);
xlim([0 0.5]); grid on;

sgtitle('幅度调制（AM）：信息编码在载波幅度的包络中','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_am_modulation.png']); close(fig);

%% ═══ 图10：FM 调制 ═══
fs = 16000; t = (0:1/fs:0.5-1/fs);
fc = 800; fm = 15; kf = 200;
s_t   = sin(2*pi*fm*t);
phase = 2*pi*fc*t + 2*pi*kf*cumsum(s_t)/fs;
fm_sig = cos(phase);

fig = figure('Position',[100 100 860 450],'Color','w');

subplot(2,1,1);
plot(t, s_t,'Color',[0 0.5 0.8],'LineWidth',1.8);
ylabel('幅度'); title('① 基带信号 s(t)：15 Hz 正弦波');
xlim([0 0.5]); ylim([-1.3 1.3]); grid on;

subplot(2,1,2);
plot(t, fm_sig,'Color',[0.1 0.65 0.3],'LineWidth',0.9);
ylabel('幅度'); xlabel('时间 (s)');
title('② FM 调制后：载波频率随基带信号变化（幅度恒定，信息在频率里）');
xlim([0 0.5]); ylim([-1.3 1.3]); grid on;
% 标注频率变化
text(0.025,  0.82,'← 频率较高\n（基带为正）','FontSize',10,'Color',[0.7 0 0]);
text(0.29,  -0.72,'← 频率较低\n（基带为负）','FontSize',10,'Color',[0 0 0.7]);

sgtitle('频率调制（FM）：信息编码在载波瞬时频率的偏移中','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_fm_modulation.png']); close(fig);

%% ═══ 图11：PSK / QAM 星座图 ═══
fig = figure('Position',[100 100 900 340],'Color','w');

% BPSK
subplot(1,3,1);
pts = [-1+0i; 1+0i];
scatter(real(pts), imag(pts), 220,'b','filled'); hold on;
for k = 1:numel(pts)
    text(real(pts(k)), imag(pts(k))+0.18, num2str(k-1), ...
        'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');
end
xline(0,'k:'); yline(0,'k:');
xlim([-1.8 1.8]); ylim([-1.5 1.5]);
xlabel('I（同相）','FontSize',10); ylabel('Q（正交）','FontSize',10);
title('BPSK（2 态，1 bit/符号）','FontSize',11);
axis square; grid on;

% QPSK
subplot(1,3,2);
angles = pi/4 + (0:3)*pi/2;
pts = exp(1j*angles).';
lbls = {'00','01','11','10'};
scatter(real(pts), imag(pts), 220,'r','filled'); hold on;
for k = 1:4
    text(real(pts(k))*1.35, imag(pts(k))*1.35, lbls{k}, ...
        'HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color','r');
end
xline(0,'k:'); yline(0,'k:');
xlim([-1.8 1.8]); ylim([-1.8 1.8]);
xlabel('I（同相）','FontSize',10); ylabel('Q（正交）','FontSize',10);
title('QPSK（4 态，2 bits/符号）','FontSize',11);
axis square; grid on;

% 16-QAM
subplot(1,3,3);
[I,Q] = meshgrid([-3 -1 1 3], [-3 -1 1 3]);
pts = (I(:) + 1j*Q(:)) / 3;
scatter(real(pts), imag(pts), 80,[0 0.5 0],'filled');
xline(0,'k:'); yline(0,'k:');
xlim([-1.6 1.6]); ylim([-1.6 1.6]);
xlabel('I（同相）','FontSize',10); ylabel('Q（正交）','FontSize',10);
title('16-QAM（16 态，4 bits/符号）','FontSize',11);
axis square; grid on;

sgtitle('数字调制星座图：BPSK → QPSK → 16-QAM','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_qam_constellation.png']); close(fig);

%% ═══ 图12：寄生 AM 调制的频谱特征 ═══
fig = figure('Position',[100 100 820 380],'Color','w');

fc_par   = 100;
f_ripple = 8;
f_ax     = linspace(60, 140, 5000);

% 各谱线（用窄高斯模拟冲激）
bw_spike = 0.04;
main = exp(-((f_ax - fc_par).^2) / bw_spike^2);
sb1  = 0.15 * exp(-((f_ax - (fc_par - f_ripple)).^2) / bw_spike^2);
sb2  = 0.15 * exp(-((f_ax - (fc_par + f_ripple)).^2) / bw_spike^2);
sb3  = 0.05 * exp(-((f_ax - (fc_par - 2*f_ripple)).^2) / bw_spike^2);
sb4  = 0.05 * exp(-((f_ax - (fc_par + 2*f_ripple)).^2) / bw_spike^2);
noise_floor = 0.006 * (1 + 0.4*rand(size(f_ax)));
total = main + sb1 + sb2 + sb3 + sb4 + noise_floor;

plot(f_ax, total,'Color',[0.15 0.45 0.75],'LineWidth',1.5); hold on;

xline(fc_par,'r--','LineWidth',1.3,'Alpha',0.7);
text(fc_par, 1.09, sprintf('载波  f_c = %d Hz', fc_par), ...
    'HorizontalAlignment','center','FontSize',10.5,'Color','r','FontWeight','bold');
text(fc_par - f_ripple, 0.22, sprintf('f_c − %d Hz', f_ripple), ...
    'HorizontalAlignment','center','FontSize',10,'Color',[0.7 0.35 0]);
text(fc_par + f_ripple, 0.22, sprintf('f_c + %d Hz', f_ripple), ...
    'HorizontalAlignment','center','FontSize',10,'Color',[0.7 0.35 0]);
text(fc_par, 0.10, sprintf('↑ 寄生边带间距 = 纹波频率 %d Hz', f_ripple), ...
    'HorizontalAlignment','center','FontSize',10,'Color',[0.5 0.2 0]);

xlabel('频率 (Hz)','FontSize',12); ylabel('幅度（线性）','FontSize',12);
title(sprintf('寄生 AM 调制：载波两侧出现纹波频率（%d Hz）的对称边带', f_ripple),'FontSize',12);
ylim([0 1.22]); grid on;
saveas(fig,[out 'fig2_parasitic_spectrum.png']); close(fig);

fprintf('=== 所有 %d 张图已生成完毕，保存在 %s ===\n', 12, out);
