/* ===== Matrix Rain ===== */
(function () {
    const canvas = document.createElement('canvas');
    canvas.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;z-index:-1;pointer-events:none;opacity:0.8;';
    document.body.prepend(canvas);

    const ctx = canvas.getContext('2d');
    const chars = '01アイウエオカキクケコABCDEFGHIJKLMNOPQRSTUVWXYZ#@!$%&<>';
    const fontSize = 13;
    let columns, drops;

    function resize() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        columns = Math.floor(canvas.width / fontSize);
        drops = Array(columns).fill(0);
    }
    resize();
    window.addEventListener('resize', resize);

    function draw() {
        ctx.fillStyle = 'rgba(10,10,10,0.05)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.font = fontSize + 'px monospace';

        drops.forEach(function (y, i) {
            const char = chars[Math.floor(Math.random() * chars.length)];
            const bright = Math.random() > 0.96;
            ctx.fillStyle = bright ? '#ccffcc' : '#00ff41';
            ctx.globalAlpha = bright ? 0.9 : 0.25 + Math.random() * 0.2;
            ctx.fillText(char, i * fontSize, y * fontSize);
            ctx.globalAlpha = 1;
            if (y * fontSize > canvas.height && Math.random() > 0.975) drops[i] = 0;
            else drops[i]++;
        });
    }

    setInterval(draw, 50);
})();

/* ===== Typewriter ===== */
(function () {
    const el = document.querySelector('.site-subtitle');
    if (!el) return;
    const text = el.textContent.trim();
    el.textContent = '';
    el.classList.add('typewriter-cursor');

    let i = 0;
    function type() {
        if (i < text.length) {
            el.textContent += text[i++];
            setTimeout(type, 90);
        } else {
            setTimeout(function () {
                el.classList.remove('typewriter-cursor');
            }, 1200);
        }
    }
    setTimeout(type, 600);
})();

/* ===== Fade-in on load (staggered) ===== */
(function () {
    const selectors = [
        '.project',
        '.news-section',
        '.dept-card',
        '.member-card',
        '.member-section'
    ];

    selectors.forEach(function (sel) {
        document.querySelectorAll(sel).forEach(function (el, i) {
            el.style.opacity = '0';
            el.style.transform = 'translateY(24px)';
            el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            el.style.transitionDelay = (i * 0.07) + 's';
        });
    });

    window.addEventListener('load', function () {
        selectors.forEach(function (sel) {
            document.querySelectorAll(sel).forEach(function (el) {
                el.style.opacity = '1';
                el.style.transform = 'translateY(0)';
            });
        });
    });
})();
