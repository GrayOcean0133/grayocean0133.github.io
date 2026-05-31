/* ============================================================
   AI-Link 知识库 · 内容清单 (manifest)
   ------------------------------------------------------------
   新增一章：把 .md 和配图放进 knowledge/chapters/<id>/，
   然后在下面 chapters 数组里加一项即可。hub 与 reader 都读这里。
   status: 'done' 已完结 | 'draft' 连载中
   ============================================================ */
window.AILINK_KB = {
    chapters: [
        {
            id: 'chapter1',
            file: 'chapters/chapter1/chapter1.md',
            order: 1,
            status: 'draft',
            titleZh: '第一章 · 信号、特征与噪声',
            titleEn: 'Ch.1 · Signal, Feature & Noise',
            descZh: '从“什么是信号”讲起，串起比特/波特率、噪声与信噪比、滤波降噪、傅里叶变换（FFT/STFT）到特征工程，建立信号处理与机器学习的共同语言。',
            descEn: 'Starts from "what is a signal" and threads through bits/baud, noise & SNR, filtering, the Fourier transform (FFT/STFT) and feature engineering.',
            topics: ['信号 / 比特 / 波特率', '噪声与信噪比 SNR', '滤波与降噪', '傅里叶变换 FFT / STFT', '特征工程'],
            scripts: ['gen_fft_demo.m', 'gen_fft_filter.m', 'gen_fft_waterfall.m']
        },
        {
            id: 'chapter2',
            file: 'chapters/chapter2/chapter2.md',
            order: 2,
            status: 'done',
            titleZh: '第二章 · 电信号与电磁波',
            titleEn: 'Ch.2 · Electrical Signals & EM Waves',
            descZh: '电路物理层视角：电信号的描述量与调制（AM/FM/QAM），PCB 上从电源、芯片、接口到接地的信号链路，再到空气中电磁波的产生、传播、天线、路径损耗与多径衰落。',
            descEn: 'The circuit-layer view: signal parameters & modulation (AM/FM/QAM), the PCB signal chain from power to ground, and electromagnetic waves — propagation, antennas, path loss and multipath.',
            topics: ['电信号描述量', '调制 AM / FM / QAM', '电源 / 去耦 / 接地', 'UART / SPI 时序', '电磁波与天线', '路径损耗与多径'],
            scripts: ['gen_figures.m', 'gen_figures_2.m', 'gen_figures_3.m']
        },
        {
            id: 'chapter3',
            file: 'chapters/chapter3/chapter3.md',
            order: 3,
            status: 'done',
            titleZh: '第三章 · 电路原理、PN 结与元器件',
            titleEn: 'Ch.3 · Circuit Principles, PN Junction & Components',
            descZh: '补齐器件层拼图：从电路基本物理量与三大定律、伏安特性与工作点，到半导体与 PN 结的物理本质，再系统梳理电阻/电容/电感、二极管家族、BJT 与 MOSFET 等常用元器件。',
            descEn: 'The device-layer view: basic circuit quantities and the three core laws, V-I characteristics and operating points, semiconductors and the PN junction, then a systematic tour of R/L/C, the diode family, BJTs and MOSFETs.',
            topics: ['基本物理量与定律', '伏安特性与工作点', '半导体与 PN 结', '电阻 / 电容 / 电感', '二极管家族', 'BJT / MOSFET'],
            scripts: ['gen_figures.m', 'gen_figures_2.m']
        }
    ],
    docs: [
        {
            id: 'intro',
            file: 'docs/ai-link-intro.md',
            status: 'done',
            titleZh: 'AI-Link 社团综合介绍材料',
            titleEn: 'AI-Link · Club Introduction',
            descZh: '社团方向、双博士导师团队、孵化项目「路愈者 RobotHealer」与算力/硬件资源的完整介绍（修订版）。',
            descEn: 'Full introduction to the club: direction, the two-PhD advisor team, the incubated "RobotHealer" project, and compute/hardware resources.',
            topics: ['社团介绍', '导师团队', 'RobotHealer']
        }
    ]
};
