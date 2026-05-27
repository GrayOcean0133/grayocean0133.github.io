% gen_fft_filter.m — 示例二：FFT 频域低通滤波
outfile = 'e:\AI-Link Group\fft_filter_demo.png';

rng(42);
fs    = 1000;
t     = (0:fs-1) / fs;
clean = sin(2*pi*5*t);
noise = 0.8 * randn(1, fs);
noisy = clean + noise;

N        = length(noisy);
X        = fft(noisy);
f_axis   = (0:N-1) * fs / N;
cutoff   = 20;
X_filt   = X;
mask     = f_axis > cutoff & f_axis < (fs - cutoff);
X_filt(mask) = 0;
filtered = real(ifft(X_filt));

fig = figure('Position', [100 100 820 660], 'Color', 'w', 'Visible', 'off');

subplot(3,1,1);
plot(t, clean, 'Color', [0.22 0.45 0.70], 'LineWidth', 1.3);
ylabel('幅度'); title('原始信号（5 Hz 正弦波）');
grid on; box off;

subplot(3,1,2);
plot(t, noisy, 'Color', [0.85 0.33 0.10], 'LineWidth', 0.8);
ylabel('幅度'); title('加噪信号（SNR ≈ 0 dB）');
grid on; box off;

subplot(3,1,3);
plot(t, filtered, 'Color', [0.17 0.63 0.17], 'LineWidth', 1.3); hold on;
plot(t, clean, '--', 'Color', [0.22 0.45 0.70], 'LineWidth', 1.0);
xlabel('时间 (s)'); ylabel('幅度');
title('频域低通滤波后（截止 20 Hz）');
legend('滤波结果', '原始参考', 'Location', 'northeast');
grid on; box off;

exportgraphics(fig, outfile, 'Resolution', 150);
disp(['Saved: ' outfile]);
