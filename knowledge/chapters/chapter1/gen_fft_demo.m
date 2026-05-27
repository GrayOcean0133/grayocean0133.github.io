% gen_fft_demo.m — 示例一：FFT 分解复合信号
outfile = 'e:\AI-Link Group\fft_demo.png';

fs = 1000;
t  = (0:fs-1) / fs;

x = sin(2*pi*5*t) + 0.6*sin(2*pi*20*t) + 0.3*sin(2*pi*50*t);

N    = length(x);
X    = fft(x);
amp  = abs(X(1:N/2+1)) / (N/2);
amp(1) = amp(1) / 2;
freqs = (0:N/2) * fs / N;

fig = figure('Position', [100 100 820 500], 'Color', 'w', 'Visible', 'off');

subplot(2,1,1);
plot(t(1:300), x(1:300), 'Color', [0.22 0.45 0.70], 'LineWidth', 1.4);
xlabel('时间 (s)'); ylabel('幅度');
title('时域信号（前 0.3 s）');
grid on; box off;

subplot(2,1,2);
stem(freqs, amp, 'filled', 'MarkerSize', 4, 'Color', [0.85 0.33 0.10]);
xlabel('频率 (Hz)'); ylabel('归一化幅度');
title('频域（FFT 单侧幅度谱）');
xlim([0 100]); grid on; box off;

exportgraphics(fig, outfile, 'Resolution', 150);
disp(['Saved: ' outfile]);
