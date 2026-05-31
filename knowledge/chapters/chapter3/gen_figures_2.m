%% Chapter 3 配图生成脚本（3.3 现代常用电路元器件）
% 运行此脚本将在 Chapter#3 文件夹中生成元器件伏安特性配图
close all; clearvars; clc;
out = 'E:\AI-Link Group\Chapter#3\';

Vt = 0.02585;   % 热电压 @ 300K

%% ═══ 图6：电容器 —— 充放电与交流相位（i = C·dv/dt）═══
fig = figure('Position',[100 100 880 560],'Color','w');

% --- 上：直流阶跃充电 ---
subplot(2,1,1);
R = 1e3; C = 1e-6; tau = R*C;             % τ = 1 ms
t = 0 : tau/300 : 5*tau;
Vs = 5;
v = Vs*(1 - exp(-t/tau));                  % 电容电压
i = (Vs/R)*exp(-t/tau)*1000;               % 电流（mA）

yyaxis left
plot(t*1e3, v,'Color',[0.15 0.45 0.75],'LineWidth',2.4); hold on;
yline(Vs,'k--','LineWidth',0.8);
ylabel('电容电压 v_C (V)','FontSize',11); ylim([0 6]);
yyaxis right
plot(t*1e3, i,'Color',[0.85 0.25 0.1],'LineWidth',2.4);
ylabel('电流 i (mA)','FontSize',11); ylim([0 6]);
xlabel('时间 (ms)','FontSize',11);
title('直流阶跃：充电瞬间电流最大，充满后电流 → 0（电容"隔直"）','FontSize',11.5);
grid on;

% --- 下：交流稳态相位（电流超前电压 90°）---
subplot(2,1,2);
f = 1; w = 2*pi*f; t2 = 0:0.001:2;
v2 = sin(w*t2);
i2 = cos(w*t2);                            % i = C dv/dt ∝ cos，超前 90°
plot(t2, v2,'Color',[0.15 0.45 0.75],'LineWidth',2.4,'DisplayName','电压 v(t)'); hold on;
plot(t2, i2,'Color',[0.85 0.25 0.1],'LineWidth',2.4,'DisplayName','电流 i(t)');
yline(0,'k:','LineWidth',0.8,'Alpha',0.5,'HandleVisibility','off');
text(0.05,1.18,'电流超前电压 90°','FontSize',10.5,'Color',[0.85 0.25 0.1],'FontWeight','bold');
xlabel('时间（周期）','FontSize',11); ylabel('归一化幅度','FontSize',11);
title('交流稳态：电流超前电压 90°（容性，i = C·dv/dt）','FontSize',11.5);
legend('Location','northeast','FontSize',10); xlim([0 2]); ylim([-1.35 1.4]); grid on;

sgtitle('电容器的伏安关系：电流由电压的"变化率"决定','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig3_vi_capacitor.png']); close(fig);

%% ═══ 图7：电感器 —— 通断与交流相位（v = L·di/dt）═══
fig = figure('Position',[100 100 880 560],'Color','w');

% --- 上：直流阶跃（电流缓升，电压尖峰）---
subplot(2,1,1);
R = 100; L = 0.1; tau = L/R;               % τ = 1 ms
t = 0 : tau/300 : 5*tau;
Vs = 5;
i = (Vs/R)*(1 - exp(-t/tau))*1000;         % 电流（mA）
v = Vs*exp(-t/tau);                        % 电感两端电压

yyaxis left
plot(t*1e3, i,'Color',[0.85 0.25 0.1],'LineWidth',2.4); hold on;
yline(Vs/R*1000,'k--','LineWidth',0.8);
ylabel('电流 i (mA)','FontSize',11); ylim([0 60]);
yyaxis right
plot(t*1e3, v,'Color',[0.15 0.45 0.75],'LineWidth',2.4);
ylabel('电感电压 v_L (V)','FontSize',11); ylim([0 6]);
xlabel('时间 (ms)','FontSize',11);
title('直流阶跃：电流不能突变，缓慢上升；稳态后电感"短路"（通直）','FontSize',11.5);
grid on;

% --- 下：交流稳态相位（电流滞后电压 90°）---
subplot(2,1,2);
f = 1; w = 2*pi*f; t2 = 0:0.001:2;
v2 = sin(w*t2);
i2 = -cos(w*t2);                           % i = (1/L)∫v ∝ -cos，滞后 90°
plot(t2, v2,'Color',[0.15 0.45 0.75],'LineWidth',2.4,'DisplayName','电压 v(t)'); hold on;
plot(t2, i2,'Color',[0.85 0.25 0.1],'LineWidth',2.4,'DisplayName','电流 i(t)');
yline(0,'k:','LineWidth',0.8,'Alpha',0.5,'HandleVisibility','off');
text(0.05,1.18,'电流滞后电压 90°','FontSize',10.5,'Color',[0.85 0.25 0.1],'FontWeight','bold');
xlabel('时间（周期）','FontSize',11); ylabel('归一化幅度','FontSize',11);
title('交流稳态：电流滞后电压 90°（感性，v = L·di/dt）','FontSize',11.5);
legend('Location','northeast','FontSize',10); xlim([0 2]); ylim([-1.35 1.4]); grid on;

sgtitle('电感器的伏安关系：电压由电流的"变化率"决定','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig3_vi_inductor.png']); close(fig);

%% ═══ 图8：R / L / C 的 i-v 李萨如图对比 ═══
w = 2*pi; t = 0:0.001:1;
v = sin(w*t);
iR =  v;                 % 电阻：同相 → 直线
iC =  cos(w*t);          % 电容：超前 90° → 椭圆（逆时针）
iL = -cos(w*t);          % 电感：滞后 90° → 椭圆（顺时针）

fig = figure('Position',[100 100 1020 360],'Color','w');
ttl = {'电阻 R：i 与 v 同相 → 直线（纯耗能）', ...
       '电容 C：i 超前 90° → 椭圆（储能）', ...
       '电感 L：i 滞后 90° → 椭圆（储能）'};
dat = {iR, iC, iL}; col = {[0.10 0.60 0.20],[0.85 0.25 0.1],[0.15 0.45 0.75]};

for s = 1:3
    subplot(1,3,s); hold on;
    plot(v, dat{s},'Color',col{s},'LineWidth',2.6);
    plot(v(1), dat{s}(1),'ko','MarkerFaceColor','k','MarkerSize',6);   % 起点
    plot(v(260), dat{s}(260),'>','Color',col{s},'MarkerFaceColor',col{s},'MarkerSize',8); % 方向
    xline(0,'k:','Alpha',0.4); yline(0,'k:','Alpha',0.4);
    axis square; axis([-1.3 1.3 -1.3 1.3]);
    xlabel('电压 v','FontSize',10.5); ylabel('电流 i','FontSize',10.5);
    title(ttl{s},'FontSize',10.5); grid on;
end
sgtitle('i-v 轨迹：电阻是直线（同相），电容/电感是椭圆（90° 相移）','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig3_rlc_lissajous.png']); close(fig);

%% ═══ 图9：稳压（齐纳）二极管伏安特性 ═══
Vz   = 5.1;                       % 稳压值
Is   = 1e-13;                     % 正向饱和电流
rz   = 15;                        % 击穿区动态电阻（Ω），决定击穿陡度
V = -7 : 0.0005 : 0.9;
I = Is.*(exp(V./Vt) - 1);                          % 正向 + 反向漏电流
bd = V < -Vz;                                      % 进入反向击穿区
I(bd) = I(bd) - (-V(bd) - Vz)/rz;                  % 击穿：电压钉在 -V_Z，电流陡升
I = I * 1000;                                      % mA

fig = figure('Position',[100 100 800 520],'Color','w'); hold on;
plot(V, I,'Color',[0.15 0.45 0.75],'LineWidth',2.6);
xline(0,'k:','LineWidth',0.8,'Alpha',0.5);
yline(0,'k:','LineWidth',0.8,'Alpha',0.5,'HandleVisibility','off');
xline(-Vz,'r--','LineWidth',1.4,'Alpha',0.8);

text(-Vz, 12, sprintf('稳压值 V_Z = %.1f V', Vz),'Color','r','FontSize',11,...
    'FontWeight','bold','HorizontalAlignment','center');
text(-6.6,-14,'反向击穿区：','Color',[0.4 0.4 0.4],'FontSize',10);
text(-6.6,-18,'电压几乎钉在 -V_Z，电流大范围变化','Color',[0.4 0.4 0.4],'FontSize',9.5);
text(0.62,16,'正向：同普通二极管','Color',[0.85 0.25 0.1],'FontSize',10,'HorizontalAlignment','right');

xlim([-7 1]); ylim([-25 20]);
xlabel('电压 U (V)','FontSize',12); ylabel('电流 I (mA)','FontSize',12);
title('稳压二极管：工作在反向击穿区，输出稳定电压','FontSize',13);
grid on; box on;
saveas(fig,[out 'fig3_vi_zener.png']); close(fig);

%% ═══ 图10：LED 伏安特性（不同颜色，开启电压不同）═══
nVt = 2*Vt;                       % LED 理想因子较大
Vf  = [1.8 2.0 2.2 3.0];          % 红/黄/绿/蓝 开启电压
nm  = {'红 (≈1.8 V)','黄 (≈2.0 V)','绿 (≈2.2 V)','蓝 (≈3.0 V)'};
cl  = {[0.85 0.10 0.10],[0.90 0.75 0.05],[0.10 0.65 0.20],[0.15 0.30 0.90]};

V = 0 : 0.001 : 3.6;
fig = figure('Position',[100 100 800 520],'Color','w'); hold on;
for k = 1:numel(Vf)
    Is = 0.02 / exp(Vf(k)/nVt);                    % 令 V=Vf 时 ≈20 mA
    I  = Is .* (exp(V./nVt) - 1) * 1000;           % mA
    plot(V, I,'Color',cl{k},'LineWidth',2.6,'DisplayName',['LED ' nm{k}]);
end
yline(20,'k:','LineWidth',0.8,'Alpha',0.6,'HandleVisibility','off');
text(0.1, 21.2,'典型工作电流 ≈ 20 mA','FontSize',9.5,'Color',[0.3 0.3 0.3]);

xlim([0 3.6]); ylim([0 30]);
xlabel('正向电压 U (V)','FontSize',12); ylabel('正向电流 I (mA)','FontSize',12);
title('发光二极管（LED）伏安特性：开启电压随发光波长升高','FontSize',13);
legend('Location','northwest','FontSize',10.5); grid on; box on;
saveas(fig,[out 'fig3_vi_led.png']); close(fig);

%% ═══ 图11：BJT 输出特性曲线（I_C ~ V_CE）═══
beta = 100; VA = 80;              % 电流放大倍数、厄利电压
Vce = 0 : 0.02 : 10;
Ib_list = (10:10:50)*1e-6;        % 基极电流 10~50 µA

fig = figure('Position',[100 100 820 520],'Color','w'); hold on;
cmap = parula(numel(Ib_list)+1);
for k = 1:numel(Ib_list)
    Ib = Ib_list(k);
    Ic = beta*Ib .* (1 + Vce/VA) .* (1 - exp(-Vce/0.15));   % 饱和+放大+厄利
    plot(Vce, Ic*1000,'Color',cmap(k,:),'LineWidth',2.4,...
        'DisplayName',sprintf('I_B = %d µA', round(Ib*1e6)));
end
% 饱和区 / 放大区分界
xline(0.3,'k--','LineWidth',1,'Alpha',0.6,'HandleVisibility','off');
text(0.45, 5.6,'\leftarrow 饱和区','FontSize',10,'Color',[0.3 0.3 0.3]);
text(4.5, 1.0,'放大区（I_C \approx \beta·I_B，受 V_{CE} 影响很小）','FontSize',10,'Color',[0.3 0.3 0.3]);

xlim([0 10]); ylim([0 6.5]);
xlabel('集电极-发射极电压 V_{CE} (V)','FontSize',12);
ylabel('集电极电流 I_C (mA)','FontSize',12);
title('双极型晶体管（BJT）输出特性：I_B 控制 I_C（电流控制）','FontSize',13);
legend('Location','southeast','FontSize',10); grid on; box on;
saveas(fig,[out 'fig3_bjt_output.png']); close(fig);

%% ═══ 图12：MOSFET 输出特性 + 转移特性 ═══
Vth = 1.0; kn = 2e-3; lambda = 0.02;   % 阈值、跨导参数、沟道调制

fig = figure('Position',[100 100 1020 440],'Color','w');

% --- 左：输出特性 I_D ~ V_DS ---
subplot(1,2,1); hold on;
Vds = 0 : 0.02 : 8;
Vgs_list = 2 : 0.5 : 4;
cmap = parula(numel(Vgs_list)+1);
for k = 1:numel(Vgs_list)
    Vgs = Vgs_list(k); Vov = Vgs - Vth;
    Id = zeros(size(Vds));
    tri = Vds <  Vov;                                   % 可变电阻（线性）区
    sat = Vds >= Vov;                                   % 饱和（恒流）区
    Id(tri) = kn*(Vov*Vds(tri) - 0.5*Vds(tri).^2);
    Id(sat) = 0.5*kn*Vov^2*(1 + lambda*(Vds(sat) - Vov));   % 在夹断点与线性区连续
    plot(Vds, Id*1000,'Color',cmap(k,:),'LineWidth',2.4,...
        'DisplayName',sprintf('V_{GS} = %.1f V', Vgs));
end
% 预夹断轨迹 V_DS = V_GS - Vth
Vov_t = 0:0.02:3; Id_pp = 0.5*kn*Vov_t.^2*1000;
plot(Vov_t, Id_pp,'k--','LineWidth',1.2,'DisplayName','预夹断轨迹 V_{DS}=V_{ov}');
xlim([0 8]); ylim([0 10]);
xlabel('漏-源电压 V_{DS} (V)','FontSize',11);
ylabel('漏极电流 I_D (mA)','FontSize',11);
title('输出特性：V_{GS} 控制 I_D（电压控制）','FontSize',11.5);
legend('Location','southeast','FontSize',9); grid on; box on;

% --- 右：转移特性 I_D ~ V_GS（饱和区）---
subplot(1,2,2); hold on;
Vgs = 0 : 0.01 : 5;
Vov = max(Vgs - Vth, 0);
Id  = 0.5*kn*Vov.^2 * 1000;                            % mA
plot(Vgs, Id,'Color',[0.85 0.25 0.1],'LineWidth',2.6);
xline(Vth,'k--','LineWidth',1.2);
text(Vth+0.1, 7,'阈值电压 V_{th}','FontSize',10.5,'Color','k');
area(Vgs(Vgs<=Vth), Id(Vgs<=Vth),'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
text(0.15, 0.6,'截止区','FontSize',10,'Color',[0.4 0.4 0.4]);
xlim([0 5]); ylim([0 18]);
xlabel('栅-源电压 V_{GS} (V)','FontSize',11);
ylabel('漏极电流 I_D (mA)','FontSize',11);
title('转移特性：V_{GS} < V_{th} 截止，之后平方律上升','FontSize',11.5);
grid on; box on;

sgtitle('MOSFET（增强型 N 沟道）：栅压控制、几乎不取栅极电流','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig3_mosfet.png']); close(fig);

%% ═══ 图13：常见元件伏安特性一览（理想化对比）═══
fig = figure('Position',[100 100 820 560],'Color','w'); hold on;

V = -6:0.01:6;
% 电阻
plot(V, V/2*1000/1000*10,'Color',[0.10 0.60 0.20],'LineWidth',2.4,'DisplayName','电阻：直线 I=U/R');
% 二极管（指数）
Id = 1e-9*(exp(V/Vt)-1)*1000; Id(Id>10)=NaN;
plot(V, Id,'Color',[0.85 0.25 0.1],'LineWidth',2.4,'DisplayName','二极管：单向指数');
% 理想电压源（垂直线 U=const）
plot([3 3],[-10 10],'Color',[0.15 0.45 0.75],'LineWidth',2.4,'LineStyle','-.','DisplayName','理想电压源：U 恒定');
% 理想电流源（水平线 I=const）
plot([-6 6],[6 6],'Color',[0.6 0.3 0.7],'LineWidth',2.4,'LineStyle',':','DisplayName','理想电流源：I 恒定');

xline(0,'k:','Alpha',0.5,'HandleVisibility','off'); yline(0,'k:','Alpha',0.5,'HandleVisibility','off');
xlim([-6 6]); ylim([-10 10]);
xlabel('电压 U (V)','FontSize',12); ylabel('电流 I (任意单位)','FontSize',12);
title('伏安特性是元件的"身份证"：形状即本质','FontSize',13);
legend('Location','southeast','FontSize',10.5); grid on; box on;
saveas(fig,[out 'fig3_vi_summary.png']); close(fig);

fprintf('=== gen_figures_2.m：8 张图已生成，保存在 %s ===\n', out);
