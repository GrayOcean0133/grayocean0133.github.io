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
        canvas.width  = window.innerWidth;
        canvas.height = window.innerHeight;
        columns = Math.floor(canvas.width / fontSize);
        drops   = Array(columns).fill(0);
    }
    resize();
    window.addEventListener('resize', resize);

    function draw() {
        ctx.fillStyle = 'rgba(10,10,10,0.05)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.font = fontSize + 'px monospace';
        drops.forEach(function (y, i) {
            const char   = chars[Math.floor(Math.random() * chars.length)];
            const bright = Math.random() > 0.96;
            ctx.fillStyle  = bright ? '#ccffcc' : '#00ff41';
            ctx.globalAlpha = bright ? 0.9 : 0.25 + Math.random() * 0.2;
            ctx.fillText(char, i * fontSize, y * fontSize);
            ctx.globalAlpha = 1;
            if (y * fontSize > canvas.height && Math.random() > 0.975) drops[i] = 0;
            else drops[i]++;
        });
    }
    setInterval(draw, 50);
})();

/* ===== Typewriter (subtitle) ===== */
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
            setTimeout(function () { el.classList.remove('typewriter-cursor'); }, 1200);
        }
    }
    setTimeout(type, 600);
})();

/* ===== Typewriter (hero title + subtitle) ===== */
(function () {
    const h1 = document.querySelector('.hero-text h1');
    const p  = document.querySelector('.hero-text p');
    if (!h1) return;

    // 选当前语言对应的可见目标 —— 双语模式下只对可见的那个 span 打字，
    // 不去碰隐藏 span 的原文，这样切语言时另一边的文字始终在
    function visibleTarget(el) {
        if (!el) return null;
        const lang = document.documentElement.getAttribute('data-lang') || 'zh';
        return el.querySelector('.i18n-' + lang) || el;
    }

    function typeEl(el, text, speed, cb) {
        el.style.display   = 'inline-block';
        el.style.borderRight = '2px solid #00ff41';
        el.style.animation = 'blink-cursor 0.7s step-end infinite';
        let i = 0;
        function tick() {
            if (i < text.length) {
                el.textContent += text[i++];
                setTimeout(tick, speed);
            } else {
                el.style.borderRight = 'none';
                el.style.animation   = 'none';
                el.style.display     = '';
                if (cb) setTimeout(cb, 200);
            }
        }
        tick();
    }

    function start() {
        const h1Target = visibleTarget(h1);
        const pTarget  = visibleTarget(p);
        const h1Text   = h1Target.textContent.trim();
        const pText    = pTarget ? pTarget.textContent.trim() : '';
        h1Target.textContent = '';
        if (pTarget) pTarget.textContent = '';

        typeEl(h1Target, h1Text, 60, function () {
            if (pTarget && pText) typeEl(pTarget, pText, 35, null);
        });
    }

    // 等入场遮罩结束再打字 —— 否则在 overlay 后面空跑、用户看不到
    if (document.getElementById('introOverlay')) {
        document.addEventListener('intro-done', function () {
            setTimeout(start, 250);
        }, { once: true });
    } else {
        setTimeout(start, 800);
    }
})();

/* ===== Scroll slide-in (IntersectionObserver — 全局) ===== */
(function () {
    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (!entry.isIntersecting) return;
            const el = entry.target;
            el.style.opacity   = '1';
            el.style.transform = 'translateY(0)';
            observer.unobserve(el);
        });
    }, { threshold: 0.10 });

    function register(el, delay) {
        el.style.opacity    = '0';
        el.style.transform  = 'translateY(28px)';
        el.style.transition = 'opacity 0.55s ease ' + delay + 's, '
                            + 'transform 0.55s ease ' + delay + 's';
        observer.observe(el);
    }

    // 所有页面：main-content 的直接子元素全部触发
    document.querySelectorAll('.main-content > *').forEach(function (el, i) {
        register(el, (i * 0.07).toFixed(2));
    });

    // Snap-scroll 首页：每个 .snap-inner 的直接子元素逐个出现
    document.querySelectorAll('.snap-inner > *').forEach(function (el, i) {
        register(el, (i * 0.05).toFixed(2));
    });

    // 卡片类：网格内的子卡片单独逐个出现（覆盖上面的 delay）
    ['.dept-card', '.member-card', '.project', '.feature-card', '.join-card', '.fit-row'].forEach(function (sel) {
        document.querySelectorAll(sel).forEach(function (el, i) {
            register(el, (i * 0.08).toFixed(2));
        });
    });
})();

/* ===== 数字滚动入场计数 ===== */
(function () {
    const targets = document.querySelectorAll('.metric-num');
    if (!targets.length) return;

    function parseNum(str) {
        const trimmed = String(str).trim();
        const clean = trimmed.replace(/,/g, '');
        const value = parseFloat(clean);
        if (isNaN(value)) return null;
        const hasComma = trimmed.includes(',');
        const m = trimmed.match(/\.(\d+)/);
        const decimals = m ? m[1].length : 0;
        return { value: value, decimals: decimals, hasComma: hasComma };
    }

    function format(n, decimals, hasComma) {
        let s = n.toFixed(decimals);
        if (hasComma) {
            const parts = s.split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            s = parts.join('.');
        }
        return s;
    }

    function easeOutCubic(t) { return 1 - Math.pow(1 - t, 3); }

    function animate(el, target, duration) {
        const start = performance.now();
        const decimals = target.decimals;
        const hasComma = target.hasComma;
        const endVal = target.value;

        function tick(now) {
            const t = Math.min(1, (now - start) / duration);
            const v = endVal * easeOutCubic(t);
            el.textContent = format(v, decimals, hasComma);
            if (t < 1) requestAnimationFrame(tick);
            else el.textContent = format(endVal, decimals, hasComma);
        }
        requestAnimationFrame(tick);
    }

    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (!entry.isIntersecting) return;
            const el = entry.target;
            if (el.dataset.counted) return;
            const parsed = parseNum(el.textContent);
            if (!parsed) return;
            el.dataset.counted = '1';
            el.textContent = format(0, parsed.decimals, parsed.hasComma);
            animate(el, parsed, 1400);
            observer.unobserve(el);
        });
    }, { threshold: 0.35 });

    targets.forEach(function (el) { observer.observe(el); });
})();

/* ===== Sticky header =====
   原本这里有 .scrolled 双态切换（hero 时展开、滚动后折叠），
   但 toggle 引发的 header 高度变化会被 snap-scroll 反向触发，
   形成无解的 layout 反馈环。现在 CSS 改成 header 始终紧凑，
   不再需要 JS toggle，整段删除。 */

/* ===== i18n：中英语言切换 ===== */
(function () {
    const HTML = document.documentElement;

    function apply(lang) {
        if (lang !== 'en') lang = 'zh';
        HTML.dataset.lang = lang;
        HTML.lang = lang === 'en' ? 'en' : 'zh-CN';
        try { localStorage.setItem('aiLinkLang', lang); } catch (e) {}

        // 同步更新 page-dots 的 data-label 与 aria-label
        document.querySelectorAll('.page-dot').forEach(function (d) {
            const zh = d.dataset.labelZh;
            const en = d.dataset.labelEn;
            const text = lang === 'en' ? (en || zh) : (zh || en);
            if (text) d.setAttribute('data-label', text);
            if (en && zh) {
                d.setAttribute('aria-label', (lang === 'en' ? 'Jump to ' : '跳转到') + text);
            }
        });

        // 通知监听者重渲（例如 Path Finder 结果区）
        document.dispatchEvent(new CustomEvent('langchange', { detail: { lang: lang } }));
    }

    // 初始：localStorage > 浏览器 > zh
    let initial = null;
    try { initial = localStorage.getItem('aiLinkLang'); } catch (e) {}
    if (!initial) {
        const b = (navigator.language || 'zh').toLowerCase();
        initial = b.startsWith('en') ? 'en' : 'zh';
    }
    apply(initial);

    // toggle 按钮：整体可点击（fallback flip），但点到具体 .lang-opt 时直接设那个
    document.querySelectorAll('.lang-toggle').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            const target = e.target.closest('.lang-opt');
            if (target && target.dataset.langSet) {
                apply(target.dataset.langSet);
            } else {
                apply(HTML.dataset.lang === 'en' ? 'zh' : 'en');
            }
        });
    });
})();

/* ===== Scroll-spy：根据可见区段高亮 page-dot 与导航链接 ===== */
(function () {
    const sections = document.querySelectorAll('main .snap-section[id]');
    const dots     = document.querySelectorAll('.page-dot');
    const navLinks = document.querySelectorAll('.nav-links a');
    if (!sections.length) return;

    function activate(id) {
        const hash = '#' + id;
        dots.forEach(function (d) {
            d.classList.toggle('active', d.getAttribute('href') === hash);
        });
        navLinks.forEach(function (n) {
            const href = n.getAttribute('href');
            if (!href || !href.startsWith('#')) return;
            n.classList.toggle('active', href === hash);
        });
    }

    // 选当前在视口里"最显著"那个 section 作为 active
    let visible = new Map();  // id -> ratio
    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                visible.set(entry.target.id, entry.intersectionRatio);
            } else {
                visible.delete(entry.target.id);
            }
        });
        let bestId = null;
        let bestRatio = 0;
        visible.forEach(function (ratio, id) {
            if (ratio > bestRatio) {
                bestRatio = ratio;
                bestId = id;
            }
        });
        if (bestId) activate(bestId);
    }, { threshold: [0.2, 0.4, 0.6, 0.8] });

    sections.forEach(function (s) { observer.observe(s); });
})();
