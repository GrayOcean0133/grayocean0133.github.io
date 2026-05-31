%% Chapter 3 配图生成脚本（3.1 基本原理 + 3.2 PN 结）
% 运行此脚本将在 Chapter#3 文件夹中生成对应讲义配图
close all; clearvars; clc;
out = 'E:\AI-Link Group\Chapter#3\';

Vt = 0.02585;   % 热电压 kT/q @ 300K ≈ 25.85 mV，全脚本通用

%% ═══ 图1：电阻的伏安特性（线性元件）═══
V  = -10:0.05:10;
Rs = [220, 1000, 4700];                       % 三个阻值（Ω）
cl = {[0.85 0.25 0.1],[0.15 0.45 0.75],[0.10 0.60 0.20]};

fig = figure('Position',[100 100 760 480],'Color','w'); hold on;
for k = 1:numel(Rs)
    I = V ./ Rs(k) * 1000;                    % 电流（mA）
    plot(V, I, 'Color',cl{k},'LineWidth',2.4, ...
        'DisplayName',sprintf('R = %g \\Omega  （G = %.2f mS）', Rs(k), 1000/Rs(k)));
end
xline(0,'k:','LineWidth',0.8,'Alpha',0.5,'HandleVisibility','off');
yline(0,'k:','LineWidth',0.8,'Alpha',0.5,'HandleVisibility','off');

% 斜率示意（220Ω 那条）
text(6.2, 6.2/220*1000+4, '斜率 = \DeltaI/\DeltaU = 1/R = 电导 G', ...
    'Color',[0.85 0.25 0.1],'FontSize',10.5,'FontWeight','bold');

xlim([-10 10]); ylim([-50 50]);
xlabel('电压 U (V)','FontSize',12); ylabel('电流 I (mA)','FontSize',12);
title('电阻的伏安特性：过原点的直线，斜率 = 1/R（电导）','FontSize',13);
legend('Location','northwest','FontSize',10.5); grid on; box on;
saveas(fig,[out 'fig3_vi_resistor.png']); close(fig);

%% ═══ 图2：本征 / N型 / P型 半导体载流子示意 ═══
rng(3);
fig = figure('Position',[80 80 1040 380],'Color','w');
types = {'本征半导体（纯 Si）','N 型（掺 5 价磷，多子为电子）','P 型（掺 3 价硼，多子为空穴）'};

for s = 1:3
    subplot(1,3,s); hold on;
    rectangle('Position',[0 0 10 8],'EdgeColor',[0.35 0.35 0.35],...
        'LineWidth',1.4,'FaceColor',[0.97 0.97 0.97]);
    axis equal; axis([-0.6 10.6 -1.8 8.8]); axis off;
    title(types{s},'FontSize',11.5);

    % 局部约定：蓝色实心圆=自由电子(-)，红色实心圆=空穴(+)，灰色空心圆=固定离子
    blue = [0.10 0.30 0.85]; bluE = [0.05 0.15 0.5];
    red  = [0.88 0.20 0.15]; reD  = [0.55 0.10 0.08]; gry = [0.55 0.55 0.55];
    switch s
        case 1   % 本征：少量电子-空穴对（数量相等）
            ex = [2.4 5.8 8.1]; ey = [5.4 2.6 6.0];
            hx = [3.4 6.9 4.6]; hy = [3.0 5.4 6.9];
            for i=1:3
                plot(ex(i),ey(i),'o','MarkerSize',20,'MarkerFaceColor',blue,'MarkerEdgeColor',bluE,'LineWidth',1);
                text(ex(i),ey(i),'-','Color','w','FontSize',16,'FontWeight','bold','HorizontalAlignment','center');
                plot(hx(i),hy(i),'o','MarkerSize',20,'MarkerFaceColor',red,'MarkerEdgeColor',reD,'LineWidth',1);
                text(hx(i),hy(i),'+','Color','w','FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
            end
            text(5,-1.2,'蓝点 = 自由电子(-)   红点 = 空穴(+)   数量少且相等','HorizontalAlignment','center','FontSize',9.5);

        case 2   % N型：大量自由电子(蓝)，固定施主正离子(灰环+)
            gx = repmat([1.6 4.0 6.4 8.8],1,2); gy = [2 2 2 2 5.8 5.8 5.8 5.8];
            for i=1:8                          % 固定施主离子（灰环，不可动）
                plot(gx(i)+0.6,gy(i)+0.75,'o','MarkerSize',14,'MarkerFaceColor','w','MarkerEdgeColor',gry,'LineWidth',1.2);
                text(gx(i)+0.6,gy(i)+0.75,'+','Color',gry,'FontSize',10,'FontWeight','bold','HorizontalAlignment','center');
            end
            for i=1:8                          % 自由电子（多子）
                plot(gx(i),gy(i),'o','MarkerSize',20,'MarkerFaceColor',blue,'MarkerEdgeColor',bluE,'LineWidth',1);
                text(gx(i),gy(i),'-','Color','w','FontSize',16,'FontWeight','bold','HorizontalAlignment','center');
            end
            text(5,-1.2,'蓝点 = 自由电子（多子）    灰环 = 固定施主离子(+)','HorizontalAlignment','center','FontSize',9.5);

        case 3   % P型：大量空穴(红)，固定受主负离子(灰环-)
            gx = repmat([1.6 4.0 6.4 8.8],1,2); gy = [2 2 2 2 5.8 5.8 5.8 5.8];
            for i=1:8                          % 固定受主离子（灰环，不可动）
                plot(gx(i)+0.6,gy(i)+0.75,'o','MarkerSize',14,'MarkerFaceColor','w','MarkerEdgeColor',gry,'LineWidth',1.2);
                text(gx(i)+0.6,gy(i)+0.75,'-','Color',gry,'FontSize',13,'FontWeight','bold','HorizontalAlignment','center');
            end
            for i=1:8                          % 空穴（多子）
                plot(gx(i),gy(i),'o','MarkerSize',20,'MarkerFaceColor',red,'MarkerEdgeColor',reD,'LineWidth',1);
                text(gx(i),gy(i),'+','Color','w','FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
            end
            text(5,-1.2,'红点 = 空穴（多子）    灰环 = 固定受主离子(-)','HorizontalAlignment','center','FontSize',9.5);
    end
end
sgtitle('本征半导体与掺杂：掺杂决定多数载流子类型','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig3_semiconductor_doping.png']); close(fig);

%% ═══ 图3：PN 结的耗尽层与内建电场 ═══
fig = figure('Position',[100 100 900 600],'Color','w');

% --- 上：结构示意 ---
ax1 = subplot(3,1,[1 2]); hold on;
rectangle('Position',[0 0 4 5],'FaceColor',[0.99 0.86 0.86],'EdgeColor','k','LineWidth',1.2); % P
rectangle('Position',[6 0 4 5],'FaceColor',[0.86 0.91 0.99],'EdgeColor','k','LineWidth',1.2); % N
rectangle('Position',[4 0 2 5],'FaceColor',[0.95 0.95 0.82],'EdgeColor','k','LineWidth',1.2); % 耗尽层

text(2,5.45,'P 区（多子：空穴）','HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color',[0.7 0.1 0.1]);
text(8,5.45,'N 区（多子：电子）','HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color',[0.1 0.2 0.7]);
text(5,5.55,'耗尽层','HorizontalAlignment','center','FontSize',10.5,'FontWeight','bold','Color',[0.4 0.35 0]);

% P区空穴、N区电子
for x=[0.7 1.5 2.4 3.2]
    for y=[1.2 2.6 4.0]
        text(x,y,'+','Color',[0.8 0.2 0.15],'FontSize',13,'FontWeight','bold','HorizontalAlignment','center');
    end
end
for x=[6.6 7.4 8.3 9.2]
    for y=[1.2 2.6 4.0]
        text(x,y,'-','Color',[0.15 0.25 0.8],'FontSize',16,'FontWeight','bold','HorizontalAlignment','center');
    end
end
% 耗尽层内：P侧固定负离子(受主)，N侧固定正离子(施主) —— 用灰环表示"不可动"
for y=[1.0 2.3 3.6]
    plot(4.5,y,'o','MarkerSize',13,'MarkerFaceColor','w','MarkerEdgeColor',[0.7 0.1 0.1],'LineWidth',1.3);
    text(4.5,y,'-','Color',[0.7 0.1 0.1],'FontSize',13,'FontWeight','bold','HorizontalAlignment','center');
    plot(5.5,y,'o','MarkerSize',13,'MarkerFaceColor','w','MarkerEdgeColor',[0.1 0.2 0.7],'LineWidth',1.3);
    text(5.5,y,'+','Color',[0.1 0.2 0.7],'FontSize',11,'FontWeight','bold','HorizontalAlignment','center');
end

% 内建电场箭头（由 N 指向 P，即向左）
quiver(5.9,4.4,-1.8,0,0,'Color',[0 0.5 0],'LineWidth',2.6,'MaxHeadSize',2);
text(5.0,4.7,'E_{内建}','Color',[0 0.5 0],'FontSize',12,'FontWeight','bold','HorizontalAlignment','center');

axis([-0.3 10.3 -0.4 6.0]); axis off;
title('PN 结：扩散形成耗尽层，露出的离子建立内建电场','FontSize',12.5);

% --- 下：电势分布 ---
ax2 = subplot(3,1,3); hold on;
x = linspace(0,10,600);
Vbi = 0.7;
phi = Vbi*0.5*(1+tanh((x-5)*1.4));
plot(x,phi,'Color',[0.15 0.45 0.75],'LineWidth',2.4);
area(x(x>=4 & x<=6), phi(x>=4 & x<=6),'FaceColor',[0.95 0.95 0.82],...
    'EdgeColor','none','FaceAlpha',0.8);
yline(Vbi,'k--','LineWidth',1);
text(8.4,Vbi+0.05,sprintf('内建电势 V_{bi} \\approx %.1f V', Vbi),'FontSize',10.5,'Color','k');
text(1.2,0.06,'P 区','FontSize',10); text(8.4,0.06,'N 区','FontSize',10);
xlim([0 10]); ylim([-0.05 0.9]);
xlabel('位置 x','FontSize',11); ylabel('电势 \phi (V)','FontSize',11);
title('结区电势：势垒集中在耗尽层，阻止多子继续扩散','FontSize',11);
grid on;
saveas(fig,[out 'fig3_pn_junction.png']); close(fig);

%% ═══ 图4：正偏 vs 反偏（单向导电性）═══
fig = figure('Position',[100 100 920 420],'Color','w');

% --- 正偏 ---
subplot(1,2,1); hold on;
wd = 0.8;  xc = 5;                                  % 耗尽层变窄
rectangle('Position',[0 0 xc-wd/2 5],'FaceColor',[0.99 0.86 0.86],'EdgeColor','k');
rectangle('Position',[xc+wd/2 0 10-(xc+wd/2) 5],'FaceColor',[0.86 0.91 0.99],'EdgeColor','k');
rectangle('Position',[xc-wd/2 0 wd 5],'FaceColor',[0.95 0.95 0.82],'EdgeColor','k');
text(2,5.4,'P','FontSize',13,'FontWeight','bold','HorizontalAlignment','center','Color',[0.7 0.1 0.1]);
text(8,5.4,'N','FontSize',13,'FontWeight','bold','HorizontalAlignment','center','Color',[0.1 0.2 0.7]);
% 外加电压：P接正、N接负
text(-0.2,2.5,'+','FontSize',20,'FontWeight','bold','Color','r','HorizontalAlignment','center');
text(10.2,2.5,'-','FontSize',24,'FontWeight','bold','Color','b','HorizontalAlignment','center');
% 大电流箭头
quiver(2.5,6.4,4.5,0,0,'Color',[0.1 0.6 0.2],'LineWidth',3,'MaxHeadSize',1.5);
text(5,6.9,'大电流 I（导通）','HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color',[0.1 0.6 0.2]);
axis([-0.6 10.6 -0.6 7.6]); axis off;
title('正向偏置：外电场抵消内建电场 → 耗尽层变窄 → 导通','FontSize',11);

% --- 反偏 ---
subplot(1,2,2); hold on;
wd = 2.6;  xc = 5;                                  % 耗尽层变宽
rectangle('Position',[0 0 xc-wd/2 5],'FaceColor',[0.99 0.86 0.86],'EdgeColor','k');
rectangle('Position',[xc+wd/2 0 10-(xc+wd/2) 5],'FaceColor',[0.86 0.91 0.99],'EdgeColor','k');
rectangle('Position',[xc-wd/2 0 wd 5],'FaceColor',[0.95 0.95 0.82],'EdgeColor','k');
text(1.8,5.4,'P','FontSize',13,'FontWeight','bold','HorizontalAlignment','center','Color',[0.7 0.1 0.1]);
text(8.2,5.4,'N','FontSize',13,'FontWeight','bold','HorizontalAlignment','center','Color',[0.1 0.2 0.7]);
text(-0.2,2.5,'-','FontSize',24,'FontWeight','bold','Color','b','HorizontalAlignment','center');
text(10.2,2.5,'+','FontSize',20,'FontWeight','bold','Color','r','HorizontalAlignment','center');
quiver(4.4,6.4,1.2,0,0,'Color',[0.6 0.6 0.6],'LineWidth',1,'MaxHeadSize',2,'LineStyle',':');
text(5,6.9,'仅极小漏电流（截止）','HorizontalAlignment','center','FontSize',11,'FontWeight','bold','Color',[0.5 0.5 0.5]);
axis([-0.6 10.6 -0.6 7.6]); axis off;
title('反向偏置：外电场叠加内建电场 → 耗尽层变宽 → 截止','FontSize',11);

sgtitle('PN 结的单向导电性：正偏导通、反偏截止','FontSize',13,'FontWeight','bold');
saveas(fig,[out 'fig3_diode_bias.png']); close(fig);

%% ═══ 图5：二极管伏安特性（Shockley 方程，Si/Ge/Schottky）═══
V = -1.0 : 0.0005 : 1.0;

% 通过调节反向饱和电流 Is 把"开启电压"放在不同位置
Is_si  = 1e-13;  n_si  = 1;     % 硅       ~0.7 V
Is_ge  = 1e-7;   n_ge  = 1;     % 锗       ~0.3 V
Is_sch = 5e-7;   n_sch = 1;     % 肖特基   ~0.2 V

I_si  = Is_si  .* (exp(V./(n_si .*Vt)) - 1) * 1000;   % mA
I_ge  = Is_ge  .* (exp(V./(n_ge .*Vt)) - 1) * 1000;
I_sch = Is_sch .* (exp(V./(n_sch.*Vt)) - 1) * 1000;

fig = figure('Position',[100 100 800 520],'Color','w'); hold on;
plot(V, I_sch,'Color',[0.55 0.35 0.75],'LineWidth',2.4,'DisplayName','肖特基  (V_{th}\approx0.2 V)');
plot(V, I_ge ,'Color',[0.10 0.60 0.20],'LineWidth',2.4,'DisplayName','锗 Ge   (V_{th}\approx0.3 V)');
plot(V, I_si ,'Color',[0.85 0.25 0.10],'LineWidth',2.6,'DisplayName','硅 Si   (V_{th}\approx0.7 V)');

xline(0,'k:','LineWidth',0.8,'Alpha',0.5,'HandleVisibility','off');
yline(0,'k:','LineWidth',0.8,'Alpha',0.5,'HandleVisibility','off');

% 区域标注
text(-0.85,1.6,'反向区：I \approx -I_s（极小，nA~µA 级）',...
    'Color',[0.3 0.3 0.3],'FontSize',10);
text(0.72,16,'正向导通：电流随电压指数上升','Color',[0.85 0.25 0.10],'FontSize',10,...
    'HorizontalAlignment','right');
annotation('textarrow',[0.55 0.66],[0.40 0.30],'String','"膝点"/开启电压','FontSize',10);

xlim([-1.0 1.0]); ylim([-5 20]);
xlabel('电压 U (V)','FontSize',12); ylabel('电流 I (mA)','FontSize',12);
title('二极管伏安特性：I = I_s (e^{U/nV_T} - 1)','FontSize',13);
legend('Location','northwest','FontSize',10.5); grid on; box on;
saveas(fig,[out 'fig3_diode_vi.png']); close(fig);

fprintf('=== gen_figures.m：5 张图已生成，保存在 %s ===\n', out);
