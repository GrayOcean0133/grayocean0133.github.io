% gen_fft_waterfall.m — 示例三：三维时频瀑布图
outfile = 'e:\AI-Link Group\fft_waterfall_3d.png';

rng(0);
fs = 4000;
T  = 3;
t  = (0 : 1/fs : T - 1/fs);

seg1 = sin(2*pi*100 * t(t < 1));
seg2 = sin(2*pi*400 * t(t >= 1 & t < 2));
t3   = t(t >= 2) - 2;
seg3 = chirp(t3, 50, 1, 800);
x    = [seg1, seg2, seg3] + 0.15*randn(1, length(t));

win_len = 512;
overlap = 448;
nfft    = 1024;

[S, F, Tv] = spectrogram(x, hamming(win_len), overlap, nfft, fs);
Z = 20*log10(abs(S) + eps);

fig = figure('Position', [100 100 960 620], 'Color', 'w', 'Visible', 'off');
waterfall(F, Tv, Z');
xlabel('频率 (Hz)', 'FontSize', 12);
ylabel('时间 (s)',  'FontSize', 12);
zlabel('强度 (dB)', 'FontSize', 12);
title('短时傅里叶变换 — 三维时频瀑布图', 'FontSize', 13);
colormap(jet);
cb = colorbar;
cb.Label.String = '强度 (dB)';
xlim([0 1000]);
view(28, 38);
grid on;

exportgraphics(fig, outfile, 'Resolution', 150);
disp(['Saved: ' outfile]);
