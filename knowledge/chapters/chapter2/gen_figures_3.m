%% Chapter 2 — Section 2.3 配图生成脚本
% 生成空气中的电磁波相关的 6 张讲义配图
close all; clearvars; clc;
out = 'E:\AI-Link Group\Chapter#2\';

%% ═══ 图1：电磁波结构（E、B 正交振荡，沿 k 传播）═══
z = linspace(0, 4*pi, 400);
E = sin(z);
B = sin(z);

fig = figure('Position',[100 100 900 480],'Color','w');
hold on; grid on; view(40, 22);

% 传播方向 z 轴上的水平参考线
plot3(z, zeros(size(z)), zeros(size(z)),'k-','LineWidth',1);

% 电场 E（沿 x 方向，红色）
for k = 1:14:length(z)
    plot3([z(k) z(k)],[0 E(k)],[0 0],'Color',[0.85 0.2 0.2],'LineWidth',1.3);
end
plot3(z, E, zeros(size(z)),'Color',[0.85 0.2 0.2],'LineWidth',2.5);

% 磁场 B（沿 y 方向，蓝色）
for k = 1:14:length(z)
    plot3([z(k) z(k)],[0 0],[0 B(k)],'Color',[0.2 0.45 0.85],'LineWidth',1.3);
end
plot3(z, zeros(size(z)), B,'Color',[0.2 0.45 0.85],'LineWidth',2.5);

% 传播方向箭头
quiver3(4*pi+0.3, 0, 0, 1.5, 0, 0, 0,'k','LineWidth',2.5,'MaxHeadSize',2);
text(4*pi+1.9, 0, 0,'  k （传播方向）','FontSize',12,'FontWeight','bold');

% E、B 标注
text(pi/2, 1.25, 0, 'E', 'Color',[0.85 0.2 0.2],'FontSize',16,'FontWeight','bold');
text(pi/2, 0, 1.25, 'B', 'Color',[0.2 0.45 0.85],'FontSize',16,'FontWeight','bold');

% 坐标轴标注
text(-0.5, 1.4, 0,'x','FontSize',13,'FontWeight','bold');
text(-0.5, 0, 1.4,'y','FontSize',13,'FontWeight','bold');
text(4*pi+0.4, -0.3,-0.3,'z','FontSize',13,'FontWeight','bold');

xlim([-0.5 4*pi+2.5]); ylim([-1.5 1.5]); zlim([-1.5 1.5]);
xlabel('z'); ylabel('E (x)'); zlabel('B (y)');
title('电磁波结构：电场 E 与磁场 B 相互正交，沿 k 方向以光速 c 传播','FontSize',12.5);
saveas(fig,[out 'fig2_em_wave_propagation.png']); close(fig);

%% ═══ 图2：近场 vs 远场 ═══
fig = figure('Position',[100 100 900 460],'Color','w');
hold on; axis equal; axis off;

% 天线（中心）
plot(0, 0,'ks','MarkerSize',16,'MarkerFaceColor','k');
text(0, -0.55,'天线','HorizontalAlignment','center','FontSize',11,'FontWeight','bold');

% 近场区域（红色阴影）
theta = linspace(0, 2*pi, 200);
r_near = 1.0;
fill(r_near*cos(theta), r_near*sin(theta), [1 0.85 0.85], ...
    'EdgeColor',[0.8 0.2 0.2],'LineWidth',1.5,'LineStyle','--');

% 过渡区
r_trans = 2.2;
fill(r_trans*cos(theta), r_trans*sin(theta), [1 0.95 0.8], ...
    'EdgeColor',[0.8 0.5 0.1],'LineWidth',1.5,'LineStyle','--');
% 把内部的近场重新覆盖一次以形成圆环
fill(r_near*cos(theta), r_near*sin(theta), [1 0.85 0.85], ...
    'EdgeColor',[0.8 0.2 0.2],'LineWidth',1.5,'LineStyle','--');

% 远场区
r_far = 4.0;
plot(r_far*cos(theta), r_far*sin(theta), 'Color',[0.1 0.5 0.2],'LineWidth',1.5,'LineStyle','--');

% 远场平面波示意
for x0 = [3.2 3.6 4.0 4.4]
    plot([x0 x0],[-0.4 0.4],'Color',[0.1 0.5 0.2],'LineWidth',1.4);
end
text(4.6, 0.7,'远场：','FontSize',10,'Color',[0.1 0.5 0.2],'FontWeight','bold');
text(4.6, 0.4,'平面波','FontSize',10,'Color',[0.1 0.5 0.2]);

% 近场示意：复杂场结构
for ang = 0:30:330
    rr = 0.4;
    plot(rr*cosd(ang) + 0.1*cosd(ang+90), rr*sind(ang)+0.1*sind(ang+90),'.',...
        'Color',[0.8 0.2 0.2],'MarkerSize',8);
end

% 标注
text(0, 1.35,'近场','HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color',[0.8 0.2 0.2]);
text(0, 1.15,'(r < λ/2π)','HorizontalAlignment','center','FontSize',9,'Color',[0.8 0.2 0.2]);

text(1.55, 1.7,'过渡区','HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color',[0.8 0.5 0.1]);
text(2.5, 2.7,'远场 (r > 2D²/λ)','HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color',[0.1 0.5 0.2]);

% 距离箭头
annotation('arrow',[0.5 0.74],[0.5 0.5],'Color','k','LineWidth',1.5);
text(2, -0.25,'r →','FontSize',10);

xlim([-5 7]); ylim([-4.5 4.5]);
title('天线辐射的近场 / 过渡区 / 远场分区','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_near_far_field.png']); close(fig);

%% ═══ 图3：电磁波谱 ═══
fig = figure('Position',[100 100 1000 360],'Color','w');
hold on;

% 频率范围（log10）
f_log_min = 3;     % 1 kHz
f_log_max = 20;    % 100 EHz

% 各频段（log10 起 - log10 止 - 颜色 - 名称 - 应用）
bands = {
    3,  4.5, [0.30 0.30 0.55], 'ELF/VLF', '潜艇';
    4.5,7,   [0.20 0.40 0.70], 'LF/MF',   'AM 广播';
    7,  7.5, [0.10 0.55 0.80], 'HF',      '短波';
    7.5,8.5, [0.10 0.70 0.65], 'VHF',     'FM/电视';
    8.5,9.5, [0.30 0.75 0.30], 'UHF',     '手机/WiFi';
    9.5,10.5,[0.80 0.80 0.10], 'SHF',     '微波/卫星';
    10.5,11.5,[0.95 0.60 0.10],'EHF',     '毫米波/5G';
    11.5,12.5,[0.90 0.40 0.15],'THz',     '6G 候选';
    12.5,14.5,[0.80 0.20 0.20],'IR',      '红外/光通信';
    14.5,15,[0.95 0.95 0.20], 'Vis',      '可见光';
    15, 17, [0.50 0.20 0.60], 'UV',       '紫外';
    17, 20, [0.30 0.05 0.30], 'X / γ',    'X 射线 / γ 射线';
};

for k = 1:size(bands,1)
    fill([bands{k,1} bands{k,2} bands{k,2} bands{k,1}], ...
         [0 0 1 1], bands{k,3},'EdgeColor','k','LineWidth',0.8);
    xc = (bands{k,1} + bands{k,2}) / 2;
    text(xc, 0.6, bands{k,4},'HorizontalAlignment','center', ...
        'FontSize',9,'FontWeight','bold','Color','w');
    text(xc, 0.25, bands{k,5},'HorizontalAlignment','center', ...
        'FontSize',8,'Color','w');
end

% 横坐标：频率刻度
ticks = 3:20;
tick_lbl = arrayfun(@(x) sprintf('10^{%d}',x), ticks,'UniformOutput',false);
xticks(ticks); xticklabels(tick_lbl);
yticks([]);
xlim([f_log_min f_log_max]); ylim([-0.45 1.4]);

% 上方刻度线：典型频率
key_f = [6, 8, 9.38, 9.70, 10.45, 14.7];
key_l = {'AM 1 MHz','FM 100 MHz','WiFi 2.4G','WiFi 5G','5G 28 GHz','可见光'};
for k = 1:length(key_f)
    plot([key_f(k) key_f(k)],[1 1.15],'k-','LineWidth',1);
    text(key_f(k), 1.20, key_l{k},'HorizontalAlignment','center','FontSize',8.5,'Rotation',25);
end

xlabel('频率 (Hz)','FontSize',12);
title('电磁波谱：从 kHz 射频到 EHz γ 射线（同一物理本质，区别只在频率）','FontSize',12.5);
box on;
saveas(fig,[out 'fig2_em_spectrum.png']); close(fig);

%% ═══ 图4：天线方向图（全向 vs 定向）═══
fig = figure('Position',[100 100 900 400],'Color','w');

% 左：偶极子（sin²θ 方向图）
subplot(1,2,1);
theta = linspace(0, 2*pi, 360);
r_dip = abs(sin(theta));   % 偶极子方向图（俯视/侧视）
polarplot(theta, r_dip,'Color',[0.15 0.45 0.75],'LineWidth',2.2);
title({'半波偶极子（全向天线）','侧视：sin(θ) 方向图，增益 ≈ 2.15 dBi'},'FontSize',11);
rlim([0 1.05]);

% 右：定向天线（窄主瓣）
subplot(1,2,2);
% 主瓣（高斯型）+ 旁瓣
main_lobe = exp(-((theta - 0)/0.35).^2) + exp(-((theta - 2*pi)/0.35).^2);
side_lobe = 0.18 * abs(cos(3*theta));
r_dir = main_lobe + 0.15*side_lobe;
r_dir = r_dir / max(r_dir);
polarplot(theta, r_dir,'Color',[0.85 0.25 0.1],'LineWidth',2.2);
title({'定向天线（如 Yagi、抛物面）','窄主瓣 + 小旁瓣，增益 ≈ 15 ~ 25 dBi'},'FontSize',11);
rlim([0 1.05]);

sgtitle('天线方向图：全向 vs 定向','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig2_antenna_pattern.png']); close(fig);

%% ═══ 图5：自由空间路径损耗 ═══
fig = figure('Position',[100 100 860 420],'Color','w');

d = logspace(0, 5, 500);   % 1 m ~ 100 km
freqs = [100e6, 1e9, 2.4e9, 5e9, 28e9];
labels = {'100 MHz','1 GHz','2.4 GHz (WiFi)','5 GHz (WiFi)','28 GHz (5G mmWave)'};
colors = [0.15 0.45 0.75;
          0.20 0.65 0.30;
          0.85 0.55 0.10;
          0.85 0.25 0.10;
          0.55 0.15 0.55];

hold on;
for k = 1:length(freqs)
    f = freqs(k);
    FSPL = 20*log10(d) + 20*log10(f) - 147.55;  % d 为 m，f 为 Hz
    semilogx(d, FSPL,'Color',colors(k,:),'LineWidth',2,'DisplayName',labels{k});
end
set(gca,'XScale','log');

% 关键距离参考线
for d_ref = [10, 100, 1000]
    xline(d_ref,'Color',[0.7 0.7 0.7],'LineStyle',':','LineWidth',0.8);
end

xlabel('距离 d (m)','FontSize',12);
ylabel('路径损耗 FSPL (dB)','FontSize',12);
title('自由空间路径损耗：频率每翻倍 +6 dB，距离每翻倍 +6 dB','FontSize',12);
legend('Location','southeast','FontSize',10);
xlim([1 1e5]); ylim([20 160]);
grid on;
saveas(fig,[out 'fig2_path_loss.png']); close(fig);

%% ═══ 图6：多径衰落（小尺度衰落）═══
% 模拟：多条多径分量叠加，接收端沿空间移动时的信号强度
fc = 2.4e9;
c  = 3e8;
lambda = c / fc;

% 多径分量：每条有不同幅度、相位、到达角
N_paths = 8;
rng(42);  % 可复现
amps   = [1.0, 0.7, 0.55, 0.45, 0.35, 0.30, 0.25, 0.20];
phases = 2*pi*rand(1, N_paths);
aoas   = pi*(rand(1, N_paths) - 0.5);  % 到达角 -π/2 ~ π/2

% 接收点沿 x 移动
x_rx = linspace(0, 10*lambda, 2000);
rx_field = zeros(size(x_rx));
for k = 1:N_paths
    rx_field = rx_field + amps(k) * exp(1j*(phases(k) + 2*pi/lambda * x_rx * sin(aoas(k))));
end
rx_pow_dB = 20*log10(abs(rx_field) / max(abs(rx_field)));

fig = figure('Position',[100 100 860 420],'Color','w');
plot(x_rx/lambda, rx_pow_dB,'Color',[0.15 0.45 0.75],'LineWidth',1.4); hold on;
yline(0,'r--','LineWidth',1.2);
text(0.2, 1.5,'相长干涉峰','Color','r','FontSize',9.5);

% 标注深衰落点
[neg_pks, locs] = findpeaks(-rx_pow_dB, 'MinPeakProminence',5);
plot(x_rx(locs)/lambda, -neg_pks, 'vk','MarkerSize',8,'MarkerFaceColor','k');
if ~isempty(locs)
    text(x_rx(locs(1))/lambda+0.2, -neg_pks(1)-1, ...
        '← 深衰落点（相消干涉）','Color','k','FontSize',9.5);
end

xlabel('接收位置（以波长 λ 为单位）','FontSize',12);
ylabel('归一化接收功率 (dB)','FontSize',12);
title({sprintf('多径衰落：%d 条路径叠加，f = %.1f GHz （λ ≈ %.1f cm）', N_paths, fc/1e9, lambda*100), ...
       '接收端移动 λ/2（≈ 6 cm）就可能从最强变到最弱'},'FontSize',11.5);
grid on; ylim([-35 5]);
saveas(fig,[out 'fig2_multipath_fading.png']); close(fig);

fprintf('=== Section 2.3 全部 %d 张图已生成，保存在 %s ===\n', 6, out);
