/* ============================================================
   AI-Link 知识库 · 内嵌 wiki（index.html #knowledge 区段）
   - 左侧导航树 + 搜索；右侧内容面板内部独立滚动
   - 点条目 fetch 对应 .md，marked + KaTeX 即时渲染
   - 公式保护：先抽出 $..$ / $$..$$ 占位再交给 marked，渲染后还原
   - 深链：?kb=<id>#knowledge
   ============================================================ */
(function () {
    'use strict';

    var ROOT = 'knowledge/';                 // 相对 index.html 的资料根目录
    var KB = window.AILINK_KB || { chapters: [], docs: [] };

    var sectionEl = document.getElementById('knowledge');
    if (!sectionEl) return;

    var navEl = document.getElementById('wikiNav');
    var artEl = document.getElementById('wikiArticle');
    var crumbEl = document.getElementById('wikiCrumb');
    var searchEl = document.getElementById('wikiSearch');
    var mainEl = document.getElementById('wikiMain');
    if (!navEl || !artEl) return;

    function esc(s) { return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;'); }

    var groups = [
        {
            key: 'chapters', zh: '课程讲义', en: 'Lecture Notes',
            items: (KB.chapters || []).slice().sort(function (a, b) { return (a.order || 0) - (b.order || 0); })
        },
        { key: 'docs', zh: '社团资料', en: 'Club Docs', items: KB.docs || [] }
    ];
    var byId = {};
    groups.forEach(function (g) { g.items.forEach(function (it) { byId[it.id] = it; it._group = g; }); });

    var libsReady = (typeof marked !== 'undefined' && typeof katex !== 'undefined');

    /* ---------------- markdown + math 渲染 ---------------- */
    function slugify(t) {
        return (t || '').toLowerCase()
            .replace(/\$+[^$]*\$+/g, '').replace(/[`*_~]/g, '')
            .replace(/[^\w一-鿿]+/g, '-').replace(/^-+|-+$/g, '') || 'sec';
    }
    function cleanText(t) {
        return (t || '').replace(/`/g, '').replace(/[*_~]/g, '').replace(/\$+([^$]*)\$+/g, '$1').trim();
    }
    function collectHeadings(src) {
        var lines = src.split('\n'), inFence = false, tok = '', out = [];
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            var fm = line.match(/^(\s*)(```+|~~~+)/);
            if (fm) {
                if (!inFence) { inFence = true; tok = fm[2].charAt(0); }
                else if (line.replace(/\s/g, '').charAt(0) === tok) { inFence = false; }
                continue;
            }
            if (inFence) continue;
            var hm = line.match(/^(#{1,6})\s+(.*?)\s*#*\s*$/);
            if (hm) out.push({ level: hm[1].length, text: hm[2] });
        }
        return out;
    }
    function renderMarkdown(src, baseDir) {
        src = src.replace(/^﻿?\s*#\s+.*(?:\r?\n|$)/, '');
        var codeStore = [], mathStore = [];
        src = src.replace(/```[\s\S]*?```|~~~[\s\S]*?~~~|`[^`\n]+`/g, function (m) {
            codeStore.push(m); return ' C' + (codeStore.length - 1) + ' ';
        });
        src = src.replace(/\$\$[\s\S]+?\$\$|\$(?:\\.|[^$\\\n])+?\$/g, function (m) {
            mathStore.push(m); return 'ZkatexZ' + (mathStore.length - 1) + 'Zend';
        });
        src = src.replace(/ C(\d+) /g, function (_, i) { return codeStore[+i]; });

        var headings = collectHeadings(src);
        var html = marked.parse(src);

        var hi = 0, used = {};
        html = html.replace(/<h([1-6])>/g, function (m, lvl) {
            var h = headings[hi++];
            if (!h) return m;
            var slug = slugify(h.text);
            if (used[slug]) { used[slug]++; slug = slug + '-' + used[slug]; } else { used[slug] = 1; }
            h.slug = slug; h.display = cleanText(h.text);
            return '<h' + lvl + ' id="' + slug + '">';
        });
        html = html.replace(/(<img\b[^>]*?\bsrc=")(?!https?:|\/\/|\/|data:)([^"]+)(")/g,
            function (_, p, s, q) { return p + baseDir + s + q; });
        html = html.replace(/<a\b([^>]*?)href="(https?:[^"]+)"/g,
            function (_, pre, href) { return '<a ' + pre + 'href="' + href + '" target="_blank" rel="noopener"'; });
        html = html.replace(/ZkatexZ(\d+)Zend/g, function (_, i) {
            var raw = mathStore[+i], display, tex;
            if (raw.indexOf('$$') === 0 && raw.lastIndexOf('$$') === raw.length - 2) { display = true; tex = raw.slice(2, -2); }
            else { display = false; tex = raw.slice(1, -1); }
            try { return katex.renderToString(tex.trim(), { displayMode: display, throwOnError: false, strict: false }); }
            catch (e) { return '<code class="math-err">' + esc(raw) + '</code>'; }
        });
        return { html: html, headings: headings };
    }

    /* ---------------- 侧栏导航 ---------------- */
    function statusTag(entry) {
        return entry.status === 'draft'
            ? '<span class="wiki-tag-draft"><span class="i18n-zh">连载中</span><span class="i18n-en">Draft</span></span>'
            : '';
    }
    function buildNav() {
        navEl.innerHTML = groups.filter(function (g) { return g.items.length; }).map(function (g) {
            return '<div class="wiki-group" data-group="' + g.key + '">' +
                '<div class="wiki-group-title"><span class="i18n-zh">' + esc(g.zh) + '</span>' +
                '<span class="i18n-en">' + esc(g.en) + '</span></div>' +
                '<ul class="wiki-list">' + g.items.map(function (it) {
                    return '<li><a class="wiki-link" data-id="' + esc(it.id) + '" ' +
                        'href="?kb=' + encodeURIComponent(it.id) + '#knowledge">' +
                        '<span class="wiki-link-label"><span class="i18n-zh">' + esc(it.titleZh) + '</span>' +
                        '<span class="i18n-en">' + esc(it.titleEn) + '</span></span>' + statusTag(it) + '</a></li>';
                }).join('') + '</ul></div>';
        }).join('') + '<div class="wiki-empty" id="wikiNoMatch" hidden>' +
            '<span class="i18n-zh">没有匹配的资料</span><span class="i18n-en">No matching docs</span></div>';
    }
    function setActive(id) {
        Array.prototype.forEach.call(navEl.querySelectorAll('.wiki-link'), function (a) {
            a.classList.toggle('active', a.getAttribute('data-id') === id);
        });
    }

    /* ---------------- 面包屑 ---------------- */
    function setCrumb(entry) {
        var home = '<a data-home="1"><span class="i18n-zh">知识库</span><span class="i18n-en">Knowledge Base</span></a>';
        if (!entry) {
            crumbEl.innerHTML = home;
            return;
        }
        var g = entry._group;
        crumbEl.innerHTML = home + '<span class="sep">/</span>' +
            '<span><span class="i18n-zh">' + esc(g.zh) + '</span><span class="i18n-en">' + esc(g.en) + '</span></span>' +
            '<span class="sep">/</span>' +
            '<span><span class="i18n-zh">' + esc(entry.titleZh) + '</span>' +
            '<span class="i18n-en">' + esc(entry.titleEn) + '</span></span>';
    }

    /* ---------------- 文章组装 ---------------- */
    function articleHead(entry) {
        var meta = entry.status === 'draft'
            ? '<span class="reader-badge reader-badge-draft"><span class="i18n-zh">连载中</span><span class="i18n-en">Draft</span></span>'
            : '<span class="reader-badge"><span class="i18n-zh">已完结</span><span class="i18n-en">Complete</span></span>';
        if (entry.scripts && entry.scripts.length) {
            var links = entry.scripts.map(function (s) {
                return '<a class="reader-script" href="' + ROOT + entry.file.replace(/[^/]+$/, '') + s + '" download>' + esc(s) + '</a>';
            }).join('');
            meta += '<span class="reader-scripts"><span class="reader-scripts-label">' +
                '<span class="i18n-zh">绘图脚本</span><span class="i18n-en">Scripts</span></span>' + links + '</span>';
        }
        return '<div class="wiki-art-head"><h1><span class="i18n-zh">' + esc(entry.titleZh) + '</span>' +
            '<span class="i18n-en">' + esc(entry.titleEn) + '</span></h1>' +
            '<div class="art-title-en"></div></div>' +
            '<div class="wiki-art-meta">' + meta + '</div>';
    }
    function tocHtml(headings) {
        var items = headings.filter(function (h) { return h.level === 2 || h.level === 3; });
        if (items.length < 2) return '';
        return '<details class="wiki-toc" open><summary><span class="i18n-zh">本页目录</span>' +
            '<span class="i18n-en">On this page</span></summary><ul>' +
            items.map(function (h) {
                return '<li class="toc-l' + h.level + '"><a data-target="' + esc(h.slug) + '">' +
                    esc(h.display || cleanText(h.text)) + '</a></li>';
            }).join('') + '</ul></details>';
    }

    var cache = {};
    function openDoc(id, opts) {
        opts = opts || {};
        var entry = byId[id];
        if (!entry) { showWelcome(); return; }
        if (!libsReady) {
            artEl.innerHTML = '<div class="wiki-state wiki-error"><span class="i18n-zh">渲染组件未就绪，请刷新页面。</span>' +
                '<span class="i18n-en">Renderer not ready, please refresh.</span></div>';
            return;
        }
        setActive(id);
        setCrumb(entry);
        try { history.replaceState(null, '', '?kb=' + encodeURIComponent(id) + '#knowledge'); } catch (e) {}
        if (opts.scroll) sectionEl.scrollIntoView();

        var baseDir = ROOT + entry.file.replace(/[^/]+$/, '');
        function paint(md) {
            var out = renderMarkdown(md, baseDir);
            artEl.innerHTML = articleHead(entry) + tocHtml(out.headings) +
                '<div class="reader-content">' + out.html + '</div>';
            wireToc();
        }
        if (cache[id]) { paint(cache[id]); return; }
        artEl.innerHTML = '<div class="wiki-state"><span class="i18n-zh">加载中…</span><span class="i18n-en">Loading…</span></div>';
        fetch(ROOT + entry.file, { cache: 'no-cache' })
            .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.text(); })
            .then(function (md) { cache[id] = md; paint(md); })
            .catch(function (err) {
                artEl.innerHTML = '<div class="wiki-state wiki-error"><p><span class="i18n-zh">资料加载失败（' +
                    esc(err.message) + '）。</span><span class="i18n-en">Failed to load (' + esc(err.message) + ').</span></p>' +
                    '<p><span class="i18n-zh">若在本地直接打开，请改用本地服务器或访问线上站点。</span>' +
                    '<span class="i18n-en">Use a local server or the live site.</span></p></div>';
            });
    }

    function wireToc() {
        Array.prototype.forEach.call(artEl.querySelectorAll('.wiki-toc a[data-target]'), function (a) {
            a.addEventListener('click', function (e) {
                e.preventDefault();
                var t = document.getElementById(a.getAttribute('data-target'));
                if (t) t.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        });
    }

    /* ---------------- 欢迎页 ---------------- */
    function welcomeCard(entry, ord) {
        var topics = (entry.topics || []).map(function (t) { return '<span class="kb-topic">' + esc(t) + '</span>'; }).join('');
        var top = ord ? '<span class="kb-card-order">' + (ord < 10 ? '0' + ord : ord) + '</span>'
            : '<span class="kb-card-order">★</span>';
        var badge = entry.status === 'draft'
            ? '<span class="kb-status kb-status-draft"><span class="i18n-zh">连载中</span><span class="i18n-en">Draft</span></span>'
            : '<span class="kb-status"><span class="i18n-zh">已完结</span><span class="i18n-en">Complete</span></span>';
        return '<a class="kb-card wiki-open" data-id="' + esc(entry.id) + '" href="?kb=' + encodeURIComponent(entry.id) + '#knowledge">' +
            '<div class="kb-card-top">' + top + badge + '</div>' +
            '<div class="kb-card-title">' + esc(entry.titleZh) + '</div>' +
            '<div class="kb-card-title-en">' + esc(entry.titleEn) + '</div>' +
            '<div class="kb-desc"><span class="i18n-zh">' + esc(entry.descZh) + '</span>' +
            '<span class="i18n-en">' + esc(entry.descEn || entry.descZh) + '</span></div>' +
            (topics ? '<div class="kb-topics">' + topics + '</div>' : '') +
            '<div class="kb-card-cta"><span class="i18n-zh">开始阅读</span><span class="i18n-en">Read</span></div></a>';
    }
    function showWelcome() {
        setActive(null);
        setCrumb(null);
        try { history.replaceState(null, '', '#knowledge'); } catch (e) {}
        var cards = groups.filter(function (g) { return g.items.length; }).map(function (g) {
            return g.items.map(function (it) { return welcomeCard(it, g.key === 'chapters' ? (it.order || 0) : 0); }).join('');
        }).join('');
        artEl.innerHTML =
            '<div class="wiki-art-head"><h1 class="wiki-welcome-title"><span class="i18n-zh">知识库</span>' +
            '<span class="i18n-en">Knowledge Base</span></h1></div>' +
            '<p class="wiki-welcome-sub"><span class="i18n-zh">社团内部技术学习资料，由成员与导师共同整理。' +
            '从左侧选择，或点下面的卡片开始阅读（含公式、图示与可下载的绘图脚本）。</span>' +
            '<span class="i18n-en">The club’s internal learning materials. Pick a doc on the left, or open a card below ' +
            '— with formulas, figures and downloadable plotting scripts.</span></p>' +
            '<div class="kb-grid">' + cards + '</div>';
    }

    /* ---------------- 搜索 ---------------- */
    function applySearch(q) {
        q = (q || '').trim().toLowerCase();
        var any = false;
        Array.prototype.forEach.call(navEl.querySelectorAll('.wiki-group'), function (gEl) {
            var groupHit = false;
            Array.prototype.forEach.call(gEl.querySelectorAll('.wiki-link'), function (a) {
                var hit = !q || a.textContent.toLowerCase().indexOf(q) !== -1;
                a.parentNode.hidden = !hit;
                if (hit) { groupHit = true; any = true; }
            });
            gEl.hidden = !groupHit;
        });
        var nm = document.getElementById('wikiNoMatch');
        if (nm) nm.hidden = any;
    }

    /* ---------------- 事件 ---------------- */
    navEl.addEventListener('click', function (e) {
        var a = e.target.closest('.wiki-link');
        if (!a) return;
        e.preventDefault();
        openDoc(a.getAttribute('data-id'), { scroll: true });
    });
    artEl.addEventListener('click', function (e) {
        var card = e.target.closest('.wiki-open');
        if (card) { e.preventDefault(); openDoc(card.getAttribute('data-id'), { scroll: true }); return; }
        var home = e.target.closest('[data-home]');
        if (home) { e.preventDefault(); showWelcome(); }
    });
    if (crumbEl) {
        crumbEl.addEventListener('click', function (e) {
            var home = e.target.closest('[data-home]');
            if (home) { e.preventDefault(); showWelcome(); }
        });
    }
    if (searchEl) {
        searchEl.addEventListener('input', function () { applySearch(searchEl.value); });
    }

    /* ---------------- 初始化 ---------------- */
    buildNav();
    var initial = new URLSearchParams(location.search).get('kb');
    if (initial && byId[initial]) { openDoc(initial, { scroll: false }); }
    else { showWelcome(); }
})();
