%% Chapter 2 — Section 2.2 配图生成脚本
% 生成 PCB 信号相关的 10 张讲义配图
close all; clearvars; clc;
out = 'E:\AI-Link Group\Chapter#2\';

%% ═══ 图1：LDO vs DCDC 输出纹波对比 ═══
fs   = 1e6;
t    = (0 : 1/fs : 2e-4 - 1/fs);   % 200 µs

% LDO：直流 + 极小宽带噪声
ldo = 3.3 + 0.00008 * randn(size(t));

% DCDC：直流 + 开关频率 300 kHz 的纹波 + 谐波
f_sw  = 300e3;
dcdc  = 3.3 + 0.015*sin(2*pi*f_sw*t) ...
            + 0.005*sin(2*pi*2*f_sw*t) ...
            + 0.002*sin(2*pi*3*f_sw*t) ...
            + 0.001*randn(size(t));

fig = figure('Position',[100 100 860 460],'Color','w');

ax1 = subplot(2,1,1);
plot(t*1e6, ldo,'Color',[0.15 0.45 0.75],'LineWidth',1.2);
yline(3.3,'k--','LineWidth',0.8);
ylabel('电压 (V)','FontSize',11);
title('线性稳压器（LDO）输出：纹波极小（< 100 µV），宽带白噪声','FontSize',11);
ylim([3.28 3.32]); grid on;
text(180, 3.319, sprintf('纹波 ≈ %d µV_{rms}', 80),'FontSize',10,'Color',[0.15 0.45 0.75],'HorizontalAlignment','right');

ax2 = subplot(2,1,2);
plot(t*1e6, dcdc,'Color',[0.85 0.25 0.1],'LineWidth',1.2);
yline(3.3,'k--','LineWidth',0.8);
ylabel('电压 (V)','FontSize',11);
xlabel('时间 (µs)','FontSize',11);
title(sprintf('开关稳压器（DCDC）输出：含开关频率（%d kHz）纹波及谐波', f_sw/1e3),'FontSize',11);
ylim([3.27 3.33]); grid on;
text(180, 3.328, sprintf('纹波 ≈ %d mV_{pp}', 30),'FontSize',10,'Color',[0.85 0.25 0.1],'HorizontalAlignment','right');

linkaxes([ax1 ax2],'x');
sgtitle('LDO vs DCDC：输出纹波特性对比（相同 3.3 V 输出）','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_power_ripple.png']); close(fig);

%% ═══ 图2：去耦电容效果 ═══
fs  = 50e6;
t   = (0 : 1/fs : 10e-6 - 1/fs);   % 10 µs

% 模拟逻辑翻转事件（3 次）
events = [1.5e-6, 4e-6, 7.5e-6];
tau_rise = 50e-9;

vcc_ideal = 3.3 * ones(size(t));
disturbance = zeros(size(t));
for ev = events
    idx = t >= ev;
    decay = exp(-(t(idx) - ev) / 0.4e-6);
    disturbance(idx) = disturbance(idx) - 0.35 * decay .* sin(2*pi*15e6*(t(idx)-ev));
end

vcc_no_dec  = vcc_ideal + disturbance + 0.005*randn(size(t));
vcc_with_dec = vcc_ideal + 0.08*disturbance + 0.003*randn(size(t));

fig = figure('Position',[100 100 860 460],'Color','w');

ax1 = subplot(2,1,1);
plot(t*1e6, vcc_no_dec,'Color',[0.85 0.25 0.1],'LineWidth',1.2);
yline(3.3,'k--','LineWidth',0.8);
for ev = events
    xline(ev*1e6,'Color',[0.5 0.5 1],'LineStyle',':','LineWidth',1);
end
ylabel('VCC (V)','FontSize',11);
title('无去耦电容：逻辑翻转时 VCC 出现大幅跌落（>300 mV）','FontSize',11);
ylim([2.85 3.55]); grid on;

ax2 = subplot(2,1,2);
plot(t*1e6, vcc_with_dec,'Color',[0.15 0.65 0.3],'LineWidth',1.2);
yline(3.3,'k--','LineWidth',0.8);
for ev = events
    xline(ev*1e6,'Color',[0.5 0.5 1],'LineStyle',':','LineWidth',1);
end
ylabel('VCC (V)','FontSize',11);
xlabel('时间 (µs)','FontSize',11);
title('有去耦电容（100 nF，紧贴引脚）：VCC 跌落抑制至 <30 mV','FontSize',11);
ylim([2.85 3.55]); grid on;

linkaxes([ax1 ax2],'x');
sgtitle('去耦电容的作用：芯片逻辑翻转时的 VCC 瞬态响应','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_decoupling_effect.png']); close(fig);

%% ═══ 图3：单端 vs 差分信号抗共模噪声 ═══
fs = 100e3;
t  = (0 : 1/fs : 5e-3 - 1/fs);

sig      = sin(2*pi*1000*t);         % 1 kHz 有效信号
cm_noise = 0.6*sin(2*pi*50*t + 0.3) + 0.2*randn(size(t));  % 共模噪声

% 单端：接收端看到信号 + 共模噪声
se_rx = sig + cm_noise;

% 差分：D+ = sig/2 + cm，D- = -sig/2 + cm
dp = sig/2 + cm_noise;
dn = -sig/2 + cm_noise;
diff_rx = dp - dn;   % 共模消除，信号幅度恢复

fig = figure('Position',[100 100 900 500],'Color','w');

subplot(2,2,1);
plot(t*1e3, dp,'Color',[0.7 0.5 0.2],'LineWidth',1,'DisplayName','D+'); hold on;
plot(t*1e3, dn,'Color',[0.2 0.5 0.7],'LineWidth',1,'DisplayName','D-');
ylabel('幅度 (V)'); title('差分发送端（D+ / D−）','FontSize',11);
legend('FontSize',9); grid on; ylim([-1.5 1.5]);

subplot(2,2,2);
plot(t*1e3, sig,'Color',[0.5 0.5 0.5],'LineWidth',1,'DisplayName','原始信号'); hold on;
plot(t*1e3, se_rx,'Color',[0.85 0.25 0.1],'LineWidth',1,'DisplayName','单端接收（含噪声）');
ylabel('幅度 (V)'); title('单端接收：共模噪声直接叠加在信号上','FontSize',11);
legend('FontSize',9); grid on; ylim([-1.8 1.8]);

subplot(2,2,3);
plot(t*1e3, cm_noise,'Color',[0.85 0.25 0.1],'LineWidth',1);
ylabel('幅度 (V)'); xlabel('时间 (ms)');
title('共模噪声（50 Hz 工频 + 随机噪声）','FontSize',11);
grid on; ylim([-1.5 1.5]);

subplot(2,2,4);
plot(t*1e3, sig,'Color',[0.5 0.5 0.5],'LineWidth',1,'DisplayName','原始信号'); hold on;
plot(t*1e3, diff_rx,'Color',[0.15 0.65 0.3],'LineWidth',1.5,'DisplayName','差分接收（噪声消除）');
ylabel('幅度 (V)'); xlabel('时间 (ms)');
title('差分接收：D+ − D−，共模噪声抵消','FontSize',11);
legend('FontSize',9); grid on; ylim([-1.8 1.8]);

sgtitle('单端信号 vs 差分信号：共模噪声抑制能力对比','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_diff_vs_se.png']); close(fig);

%% ═══ 图4：UART 帧时序图 ═══
% 发送字节 0xA5 = 10100101b，1 起始位，8 数据位，1 停止位
data_bits = [1 0 1 0 0 1 0 1];  % LSB first: 0xA5

frame = [1, 1,  ...         % 空闲（高）
         0,     ...         % 起始位
         data_bits, ...     % 8 数据位（LSB first）
         1,     ...         % 停止位
         1, 1];             % 空闲恢复

% 构造阶梯波形
t_pts = []; v_pts = [];
for k = 1:length(frame)
    t_pts = [t_pts, k-1, k];
    v_pts = [v_pts, frame(k), frame(k)];
end

fig = figure('Position',[100 100 920 340],'Color','w');
plot(t_pts, v_pts,'b','LineWidth',2.5); hold on;
ylim([-0.4 1.55]); xlim([-0.2 length(frame)+0.5]);

% 标注各部分
x_labels = {'空闲', '起', '0', '1', '0', '1', '0', '0', '1', '0', '1', '停', '空闲'};

% 标注位置
centers = [0.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5];
label_str = {'空闲(HIGH)', '起始位\newline(LOW)', 'b0=1', 'b1=0', 'b2=1', 'b3=0', 'b4=0', 'b5=1', 'b6=0', 'b7=1', '停止位\newline(HIGH)', '空闲'};
colors_lbl = {[0.4 0.4 0.4], [0.85 0.2 0.2], [0.15 0.45 0.75], [0.15 0.45 0.75], ...
    [0.15 0.45 0.75], [0.15 0.45 0.75], [0.15 0.45 0.75], [0.15 0.45 0.75], ...
    [0.15 0.45 0.75], [0.15 0.45 0.75], [0.1 0.6 0.2], [0.4 0.4 0.4]};

for k = 1:length(centers)
    v_lbl = frame(round(centers(k))) + 0.18;
    if v_lbl < 0.3, v_lbl = -0.28; end
    text(centers(k), v_lbl, label_str{k}, 'HorizontalAlignment','center', ...
        'FontSize',8.5,'Color',colors_lbl{k},'FontWeight','bold');
end

% 分隔线
for k = 3:11
    plot([k k],[-0.05 1.05],':','Color',[0.65 0.65 0.65],'LineWidth',0.8);
end

% 数据段标注
annotation_y = 1.35;
plot([3 11],[annotation_y annotation_y],'k-','LineWidth',1.5);
plot([3 3],[annotation_y-0.04 annotation_y+0.04],'k-','LineWidth',1.5);
plot([11 11],[annotation_y-0.04 annotation_y+0.04],'k-','LineWidth',1.5);
text(7, annotation_y+0.06,'8 个数据位（LSB 先发，0xA5 = 10100101b）', ...
    'HorizontalAlignment','center','FontSize',10,'FontWeight','bold');

yline(0,'Color',[0.7 0.7 0.7],'LineStyle',':','LineWidth',0.8);
yline(1,'Color',[0.7 0.7 0.7],'LineStyle',':','LineWidth',0.8);
yticks([0 1]); yticklabels({'LOW (0)','HIGH (1)'});
xlabel('位时序（每格 = 1 bit 周期 = 1/波特率）','FontSize',11);
title('UART 帧格式：发送 0xA5（1 起始位 + 8 数据位 + 1 停止位，无校验）','FontSize',12);
grid on;
saveas(fig,[out 'fig2_uart_frame.png']); close(fig);

%% ═══ 图5：SPI 四线时序图 ═══
% 传输 2 个字节，模式0（CPOL=0, CPHA=0）
n_bits = 8;
data_mosi = [1 0 1 1 0 0 1 0];   % 0xB2
data_miso = [0 1 1 0 1 0 0 1];   % 0x69

% 时钟：每个数据位一个时钟周期
clk_t = []; clk_v = [];
for k = 0:n_bits-1
    clk_t = [clk_t, k, k+0.45, k+0.45, k+0.95, k+0.95];
    clk_v = [clk_v, 0, 0,      1,      1,       0      ];
end
clk_t = [clk_t, n_bits]; clk_v = [clk_v, 0];

% 片选：提前 0.5 拉低，结束后 0.5 拉高
cs_t = [-0.5, -0.5, 0, n_bits, n_bits, n_bits+0.5, n_bits+0.5];
cs_v = [1,    0,    0, 0,      1,       1,           1         ];

% 数据线（在 clk 上升沿之前建立）
mosi_t = []; mosi_v = [];
miso_t = []; miso_v = [];
for k = 1:n_bits
    mosi_t = [mosi_t, k-1, k];
    mosi_v = [mosi_v, data_mosi(k), data_mosi(k)];
    miso_t = [miso_t, k-1, k];
    miso_v = [miso_v, data_miso(k), data_miso(k)];
end

fig = figure('Position',[100 100 920 500],'Color','w');
signals = {cs_v; clk_v; mosi_v; miso_v};
t_sigs  = {cs_t; clk_t; mosi_t; miso_t};
labels  = {'CS（片选）','SCLK（时钟）','MOSI（主→从）','MISO（从→主）'};
clrs    = {[0.5 0.0 0.5],[0.3 0.3 0.3],[0.15 0.45 0.75],[0.85 0.35 0.1]};
offsets = [3.6, 2.4, 1.2, 0.0];

hold on;
for s = 1:4
    tv = t_sigs{s}; vv = signals{s} * 0.9 + offsets(s);
    plot(tv, vv,'Color',clrs{s},'LineWidth',2.2);
    text(-0.7, offsets(s)+0.45, labels{s},'HorizontalAlignment','right', ...
        'FontSize',10,'Color',clrs{s},'FontWeight','bold');
    yline(offsets(s),'Color',[0.75 0.75 0.75],'LineStyle',':','LineWidth',0.6);
end

% 标注各位
for k = 1:n_bits
    xline(k-0.5,'Color',[0.7 0.7 0.7],'LineStyle',':','LineWidth',0.7);
    text(k-0.5, 1.2+0.9, sprintf('b%d\n%d', k-1, data_mosi(k)), ...
        'HorizontalAlignment','center','FontSize',8.5,'Color',[0.15 0.45 0.75]);
    text(k-0.5, 0.0+0.9, sprintf('%d', data_miso(k)), ...
        'HorizontalAlignment','center','FontSize',8.5,'Color',[0.85 0.35 0.1]);
end

xlim([-1 n_bits+1]); ylim([-0.3 4.7]);
xticks(0:n_bits); xticklabels(arrayfun(@(x) sprintf('T%d',x), 0:n_bits,'UniformOutput',false));
yticks([]); xlabel('时钟周期','FontSize',11);
title(sprintf('SPI 时序图：CPOL=0, CPHA=0，发送 MOSI=0x%02X，接收 MISO=0x%02X',...
    bin2dec(num2str(data_mosi)), bin2dec(num2str(data_miso))),'FontSize',12);
grid on;
saveas(fig,[out 'fig2_spi_timing.png']); close(fig);

%% ═══ 图6：RC 低通滤波器幅频响应 ═══
R = 1e3; C = 3.3e-9;
fc = 1/(2*pi*R*C);

f = logspace(3, 8, 1000);
H_mag = 1 ./ sqrt(1 + (f/fc).^2);
H_dB  = 20*log10(H_mag);

fig = figure('Position',[100 100 820 420],'Color','w');
semilogx(f, H_dB,'b','LineWidth',2.2); hold on;

% -3dB 截止点
xline(fc,'r--','LineWidth',1.6);
plot(fc, -3,'ro','MarkerSize',10,'MarkerFaceColor','r');
text(fc*1.3, -3+1.5, sprintf('f_c = %.0f kHz\n(−3 dB)', fc/1e3), ...
    'Color','r','FontSize',11,'FontWeight','bold');

% -20dB/decade 斜率标注
f1 = 1e6; f2 = 1e7;
plot([f1 f2], [-20*log10(f1/fc)-3, -20*log10(f2/fc)-3],'k--','LineWidth',1.5);
text(3e6, -30,'−20 dB/十倍频','FontSize',10.5,'Color','k', ...
    'HorizontalAlignment','center','Rotation',-26);

xlabel('频率 (Hz)','FontSize',12); ylabel('增益 (dB)','FontSize',12);
title(sprintf('RC 低通滤波器幅频响应（R = %d Ω，C = %.1f nF，f_c = %.0f kHz）', ...
    R, C*1e9, fc/1e3),'FontSize',12);
ylim([-60 5]); grid on;
saveas(fig,[out 'fig2_rc_lowpass.png']); close(fig);

%% ═══ 图7：铁氧体磁珠阻抗 vs 频率 ═══
% 典型磁珠（600Ω@100MHz）的阻抗曲线（R 和 jX 分量）
f = logspace(4, 9, 500);
f_peak = 100e6;

% 等效模型：串联 R(f) + jX(f)
% R（损耗，在谐振频率峰值）
R_part = 600 ./ (1 + ((log10(f) - log10(f_peak))/0.55).^2);
% X（感性，低频主导；高频转容性）
X_part = 600 * (f/f_peak) ./ (1 + (f/f_peak).^2) .* sign(1 - f/f_peak);
Z_total = sqrt(R_part.^2 + X_part.^2);

fig = figure('Position',[100 100 820 420],'Color','w');
semilogx(f, Z_total,'b','LineWidth',2.5,'DisplayName','|Z| 总阻抗'); hold on;
semilogx(f, R_part, 'r--','LineWidth',1.8,'DisplayName','R（损耗分量）');
semilogx(f, abs(X_part),'Color',[0 0.6 0],'LineStyle','--','LineWidth',1.8,'DisplayName','|X|（电抗分量）');

xline(f_peak,'Color',[0.4 0.4 0.4],'LineStyle',':','LineWidth',1.5);
plot(f_peak, 600,'bo','MarkerSize',10,'MarkerFaceColor','b');
text(f_peak*1.4, 620,'600 Ω @ 100 MHz','FontSize',10.5,'Color','b','FontWeight','bold');

xlabel('频率 (Hz)','FontSize',12); ylabel('阻抗 (Ω)','FontSize',12);
title('铁氧体磁珠阻抗特性（典型 600Ω@100MHz 型号）','FontSize',12);
legend('Location','northwest','FontSize',10);
xlim([1e4 1e9]); ylim([0 750]); grid on;
saveas(fig,[out 'fig2_ferrite_impedance.png']); close(fig);

%% ═══ 图8：LC 滤波器 vs RC 滤波器对比 ═══
R = 100; C = 100e-9; L = C*R^2;  % 同截止频率
fc = 1/(2*pi*sqrt(L*C));         % LC 截止频率（= RC 截止频率）

f = logspace(3, 7, 1000);

% RC -20dB/decade
H_RC = 20*log10(1 ./ sqrt(1 + (f*2*pi*R*C).^2));

% LC（二阶，Q=1/sqrt(2)对应无振铃，Q=5产生明显峰值）
Q_high = 5;
w0 = 2*pi*fc;
w  = 2*pi*f;
H_LC_Q1 = 20*log10(abs(w0^2 ./ (w0^2 - w.^2 + 1j*w0/Q_high*w)));

fig = figure('Position',[100 100 820 430],'Color','w');
semilogx(f, H_RC,'b','LineWidth',2.2,'DisplayName','RC 低通（−20 dB/十倍频）'); hold on;
semilogx(f, H_LC_Q1,'r','LineWidth',2.2,'DisplayName',sprintf('LC 低通（−40 dB/十倍频，Q=%.0f）',Q_high));

xline(fc,'Color',[0.4 0.4 0.4],'LineStyle','--','LineWidth',1.3);
text(fc*1.3, -45, sprintf('f_c = %.1f kHz', fc/1e3),'FontSize',10.5,'FontWeight','bold');

% 斜率标注
f_s1 = 2e5; f_s2 = 2e6;
slope_rc = -20*log10(f_s2/f_s1);
text(sqrt(f_s1*f_s2), H_RC(find(f>=sqrt(f_s1*f_s2),1))-4, ...
    '−20 dB','FontSize',10,'Color','b','Rotation',-20);
text(sqrt(f_s1*f_s2)*1.5, H_LC_Q1(find(f>=sqrt(f_s1*f_s2)*1.5,1))-5, ...
    '−40 dB','FontSize',10,'Color','r','Rotation',-38);

text(fc*0.6, 3, '← 谐振峰值（Q=5）','FontSize',10,'Color','r');

xlabel('频率 (Hz)','FontSize',12); ylabel('增益 (dB)','FontSize',12);
title('LC 滤波器 vs RC 滤波器：截止特性对比','FontSize',12);
legend('Location','southwest','FontSize',10);
ylim([-80 10]); grid on;
saveas(fig,[out 'fig2_lc_vs_rc.png']); close(fig);

%% ═══ 图9：ADC 量化过程 ═══
fs_adc = 50e3;
t_adc  = (0 : 1/fs_adc : 1e-3 - 1/fs_adc);

N_bits = 4;   % 4 bit 便于显示量化阶梯
Vref   = 3.3;
LSB    = Vref / 2^N_bits;

f_sig = 1500;
analog_in = 1.65 + 1.5*sin(2*pi*f_sig*t_adc);  % 以中点为中心
digital_out = floor(analog_in / LSB) * LSB;      % 量化后

fig = figure('Position',[100 100 820 480],'Color','w');

ax1 = subplot(2,1,1);
plot(t_adc*1e3, analog_in,'b','LineWidth',2,'DisplayName','模拟输入');
ylabel('电压 (V)','FontSize',11);
title(sprintf('模拟输入信号（正弦波，%.0f Hz）',f_sig),'FontSize',11);
ylim([0 Vref+0.1]); grid on;

% 量化电平参考线
for k = 0:2^N_bits
    yline(k*LSB,'Color',[0.75 0.75 0.75],'LineStyle',':','LineWidth',0.5);
end

ax2 = subplot(2,1,2);
stairs(t_adc*1e3, digital_out,'r','LineWidth',1.5,'DisplayName','数字输出（量化）'); hold on;
plot(t_adc*1e3, analog_in,'--','Color',[0.5 0.7 1.0],'LineWidth',1,'DisplayName','原始模拟（参考）');

% 标注 LSB
idx_show = find(t_adc > 0.1e-3 & t_adc < 0.15e-3, 1);
if ~isempty(idx_show)
    lv = digital_out(idx_show);
    plot([t_adc(idx_show)*1e3 t_adc(idx_show)*1e3],[lv lv+LSB],'k-','LineWidth',1.5);
    text(t_adc(idx_show)*1e3 + 0.01, lv+LSB/2, sprintf(' 1 LSB = %.0f mV',LSB*1000),...
        'FontSize',10,'FontWeight','bold');
end

ylabel('电压 (V)','FontSize',11); xlabel('时间 (ms)','FontSize',11);
title(sprintf('%d bit ADC 量化输出（%d 个电平，LSB = %.0f mV）', ...
    N_bits, 2^N_bits, LSB*1000),'FontSize',11);
legend('Location','northeast','FontSize',9);
ylim([0 Vref+0.1]); grid on;

linkaxes([ax1 ax2],'x');
sgtitle('ADC 量化过程：连续模拟信号 → 离散数字编码','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_adc_quantization.png']); close(fig);

%% ═══ 图10：地回流路径示意 ═══
fig = figure('Position',[100 100 900 420],'Color','w');

%── 左图：完整地平面 ──
ax1 = subplot(1,2,1);
hold on; axis equal; axis off;

% 地平面
fill([0 6 6 0],[0 0 1.2 1.2],[0.85 0.92 0.85],'EdgeColor','k','LineWidth',1.5);
text(3, 0.6,'地平面（完整）','HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color',[0 0.4 0]);

% 信号走线
fill([0 6 6 0],[1.6 1.6 2.0 2.0],[0.7 0.85 1],'EdgeColor','b','LineWidth',1.5);
text(3, 1.8,'信号走线','HorizontalAlignment','center','FontSize',11,'Color','b','FontWeight','bold');

% 发送端
fill([-0.8 0 0 -0.8],[0 0 2 2],[0.95 0.95 0.8],'EdgeColor','k','LineWidth',1);
text(-0.4, 1,'TX','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');

% 接收端
fill([6 6.8 6.8 6],[0 0 2 2],[0.95 0.95 0.8],'EdgeColor','k','LineWidth',1);
text(6.4, 1,'RX','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');

% 信号电流（向右）
annotation('arrow',[0.12 0.43],[0.65 0.65],'Color','b','LineWidth',2,'HeadWidth',12);
text(3, 2.3,'信号电流 →','HorizontalAlignment','center','FontSize',10,'Color','b');

% 回流电流（向左，在地平面正下方）
annotation('arrow',[0.43 0.12],[0.44 0.44],'Color',[0 0.5 0],'LineWidth',2,'HeadWidth',12);
text(3, 0.2,'← 回流（走线正下方，最小面积）','HorizontalAlignment','center','FontSize',9.5,'Color',[0 0.5 0]);

title('完整地平面：回流路径最优','FontSize',12,'FontWeight','bold','Color',[0 0.5 0]);

%── 右图：切割地平面 ──
ax2 = subplot(1,2,2);
hold on; axis equal; axis off;

% 地平面（左半）
fill([0 2.4 2.4 0],[0 0 1.2 1.2],[0.85 0.92 0.85],'EdgeColor','k','LineWidth',1.5);
% 地平面（右半，有缺口）
fill([3.6 6 6 3.6],[0 0 1.2 1.2],[0.85 0.92 0.85],'EdgeColor','k','LineWidth',1.5);
% 缺口标注
text(3, 0.6,'缺口!','HorizontalAlignment','center','FontSize',11,'Color','r','FontWeight','bold');

% 信号走线
fill([0 6 6 0],[1.6 1.6 2.0 2.0],[0.7 0.85 1],'EdgeColor','b','LineWidth',1.5);
text(3, 1.8,'信号走线（跨越缺口）','HorizontalAlignment','center','FontSize',10,'Color','b','FontWeight','bold');

% 发送/接收端
fill([-0.8 0 0 -0.8],[0 0 2 2],[0.95 0.95 0.8],'EdgeColor','k','LineWidth',1);
text(-0.4, 1,'TX','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');
fill([6 6.8 6.8 6],[0 0 2 2],[0.95 0.95 0.8],'EdgeColor','k','LineWidth',1);
text(6.4, 1,'RX','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');

% 信号电流
annotation('arrow',[0.62 0.93],[0.65 0.65],'Color','b','LineWidth',2,'HeadWidth',12);

% 回流绕道（大环路）
px = [2.4, 2.4, 0.5, 0.5, 3, 5.5, 5.5, 3.6];
py = [0.6, -0.5, -0.5, -1.2, -1.2, -1.2, -0.5, 0.6];
% 简化为绕道箭头文字说明
annotation('arrow',[0.93 0.62],[0.27 0.27],'Color',[0.8 0 0],'LineWidth',2,'HeadWidth',12,'LineStyle','--');
text(3, -0.25,'← 回流被迫绕行（大回路 = 大天线 = 强 EMI）','HorizontalAlignment','center','FontSize',9,'Color',[0.8 0 0]);

title({'切割地平面：回流路径被迫绕行','EMI 辐射急剧增加'},'FontSize',12,'FontWeight','bold','Color',[0.8 0 0]);

sgtitle('地平面与信号回流路径：完整 vs 切割','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_ground_return.png']); close(fig);

fprintf('=== Section 2.2 全部 %d 张图已生成，保存在 %s ===\n', 10, out);
