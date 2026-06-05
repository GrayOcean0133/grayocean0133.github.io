/* ============================================================
   AI-Link 知识库 · 浏览器内 Python 运行引擎（Pyodide）
   ------------------------------------------------------------
   - 给文章里的 ```python 代码块加「运行」按钮，浏览器内直接跑
   - 懒加载：用户第一次点运行才下载 Pyodide + 科学计算包（首次较大，之后浏览器缓存）
   - 共享内核：整页所有代码块共用一个 Python 命名空间（和 Notebook 一致）
   - 「运行」= 自动先把上方还没跑过的代码块依次执行，再跑当前块（保证依赖）
   - 捕获 print 输出、display() 表格、matplotlib 图像
   - 数据文件：按 manifest 里每章的 data 列表，预加载进 Pyodide 虚拟文件系统的 data/ 下
   wiki.js 渲染完文章后调用 window.KBRunner.enhance(artEl, entry)
   ============================================================ */
(function () {
    'use strict';

    var ROOT = 'knowledge/';
    // Pyodide 运行时来源：自托管优先（存在即用），否则多个 CDN 兜底（gcore 在国内通常更稳）
    var PYODIDE_VER = 'v0.26.4';
    var PYODIDE_BASES = [
        ROOT + 'vendor/pyodide/',
        'https://gcore.jsdelivr.net/pyodide/' + PYODIDE_VER + '/full/',
        'https://cdn.jsdelivr.net/pyodide/' + PYODIDE_VER + '/full/'
    ];
    var FONT_URL = ROOT + 'vendor/fonts/cjk-subset.ttf';
    var PACKAGES = ['numpy', 'pandas', 'matplotlib', 'scikit-learn', 'scipy', 'pillow'];

    // Pyodide 启动后注入的 Python 前导：display 垫片 / 伪 IPython / 输出收集
    var PREAMBLE = [
        'import sys, types, io, base64, json',
        'import matplotlib',
        "matplotlib.use('AGG')",
        'import matplotlib.pyplot as plt',
        'import matplotlib.font_manager as _fm',
        'try:',
        "    _fm.fontManager.addfont('fonts/cjk-subset.ttf')",
        "    matplotlib.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans']",
        "    matplotlib.rcParams['axes.unicode_minus'] = False",
        'except Exception: pass',
        '_KB_OUT = []',
        'def display(*objs):',
        '    for o in objs:',
        '        html = None',
        '        try: html = o._repr_html_()',
        '        except Exception: html = None',
        "        _KB_OUT.append(['html', html] if html else ['text', repr(o)])",
        "_ip = types.ModuleType('IPython')",
        "_ipd = types.ModuleType('IPython.display')",
        '_ipd.display = display',
        '_ip.display = _ipd',
        "sys.modules['IPython'] = _ip",
        "sys.modules['IPython.display'] = _ipd",
        'import builtins',
        'builtins.display = display',
        'def _kb_collect():',
        '    figs = []',
        '    for n in plt.get_fignums():',
        '        f = plt.figure(n)',
        '        b = io.BytesIO()',
        '        try:',
        "            f.savefig(b, format='png', bbox_inches='tight', dpi=110)",
        '            figs.append(base64.b64encode(b.getvalue()).decode())',
        '        except Exception: pass',
        "    plt.close('all')",
        '    out = list(_KB_OUT); _KB_OUT.clear()',
        "    return json.dumps({'items': out, 'figs': figs})",
        '_KB_BASE_KEYS = set(globals().keys()); _KB_BASE_KEYS.add("_KB_BASE_KEYS")',
        'def _kb_reset():',
        '    g = globals()',
        '    for k in list(g.keys()):',
        '        if k not in _KB_BASE_KEYS: del g[k]',
        "    _KB_OUT.clear(); plt.close('all')"
    ].join('\n');

    function esc(s) {
        return String(s == null ? '' : s)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    /* ---------------- Pyodide 启动（全局一次） ---------------- */
    var pyodide = null, booting = null, booted = false;

    function injectScript(src) {
        return new Promise(function (resolve, reject) {
            var existing = document.querySelector('script[data-kb-pyodide]');
            if (existing) { existing.addEventListener('load', resolve); existing.addEventListener('error', reject); return; }
            var s = document.createElement('script');
            s.src = src; s.async = true; s.setAttribute('data-kb-pyodide', '1');
            s.onload = resolve; s.onerror = function () { reject(new Error('Pyodide 脚本加载失败')); };
            document.head.appendChild(s);
        });
    }

    // 依次探测 PYODIDE_BASES，第一个可达的即用（自托管存在则优先，否则 CDN 兜底）
    var resolvedBase = null;
    function resolveBase() {
        if (resolvedBase) return Promise.resolve(resolvedBase);
        return PYODIDE_BASES.reduce(function (chain, base) {
            return chain.then(function (found) {
                if (found) return found;
                return fetch(base + 'pyodide.js', { method: 'HEAD' })
                    .then(function (r) { return r.ok ? base : null; })
                    .catch(function () { return null; });
            });
        }, Promise.resolve(null)).then(function (found) {
            resolvedBase = found || PYODIDE_BASES[PYODIDE_BASES.length - 1];
            return resolvedBase;
        });
    }

    function loadFont() {
        return fetch(FONT_URL).then(function (r) {
            return r.ok ? r.arrayBuffer() : null;
        }).then(function (buf) {
            if (!buf) return;
            try {
                pyodide.FS.mkdirTree('fonts');
                pyodide.FS.writeFile('fonts/cjk-subset.ttf', new Uint8Array(buf));
            } catch (e) {}
        }).catch(function () {});
    }

    function boot() {
        if (booted) return Promise.resolve(pyodide);
        if (booting) return booting;
        setBanner('loading', '正在下载并初始化 Python 运行环境…', 'Downloading & initializing the Python runtime…');
        var base;
        booting = resolveBase().then(function (b) {
            base = b;
            return injectScript(base + 'pyodide.js');
        }).then(function () {
            return window.loadPyodide({ indexURL: base });
        }).then(function (py) {
            pyodide = py;
            setBanner('loading', '正在加载科学计算包（numpy / pandas / matplotlib / scikit-learn …）', 'Loading scientific packages…');
            return pyodide.loadPackage(PACKAGES);
        }).then(function () {
            return loadFont();
        }).then(function () {
            return pyodide.runPythonAsync(PREAMBLE);
        }).then(function () {
            booted = true;
            setBanner('ready', 'Python 环境就绪 · 可直接运行下方代码', 'Python runtime ready · run the code below');
            return pyodide;
        }).catch(function (err) {
            booting = null;
            setBanner('error', '环境加载失败：' + err.message + '（需联网或自托管 Pyodide）', 'Runtime failed to load: ' + err.message);
            throw err;
        });
        return booting;
    }

    /* ---------------- 数据文件预加载（按文章） ---------------- */
    var dataLoadedFor = null;
    function ensureData() {
        var entry = currentEntry;
        if (!entry || !entry.data || !entry.data.length) return Promise.resolve();
        if (dataLoadedFor === entry.id) return Promise.resolve();
        try { pyodide.FS.mkdirTree('data'); } catch (e) {}
        var dir = entry.file.replace(/[^/]+$/, '');   // chapters/chapter6/
        var jobs = entry.data.map(function (name) {
            return fetch(ROOT + dir + 'data/' + name).then(function (r) {
                if (!r.ok) throw new Error('HTTP ' + r.status + ' · ' + name);
                return r.arrayBuffer();
            }).then(function (buf) {
                pyodide.FS.writeFile('data/' + name, new Uint8Array(buf));
            });
        });
        return Promise.all(jobs).then(function () { dataLoadedFor = entry.id; });
    }

    /* ---------------- 单个 / 连带运行 ---------------- */
    var cells = [], currentEntry = null, running = false;

    function runUpTo(idx) {
        if (running) return;
        running = true;
        setAllDisabled(true);
        boot().then(ensureData).then(function () {
            return cells.slice(0, idx).reduce(function (chain, cell, j) {
                return chain.then(function (ok) {
                    if (ok === false) return false;            // 上游出错则中断
                    return cell.ran ? true : runOne(j);
                });
            }, Promise.resolve(true));
        }).then(function (ok) {
            if (ok !== false) return runOne(idx);              // 目标块总是重跑
        }).catch(function (err) {
            renderOut(cells[idx], '', { items: [], figs: [] }, err);
        }).then(function () {
            running = false; setAllDisabled(false);
        });
    }

    function runOne(j) {
        var cell = cells[j];
        setBusy(cell, true);
        var buf = '';
        pyodide.setStdout({ batched: function (s) { buf += s; } });
        pyodide.setStderr({ batched: function (s) { buf += s; } });
        return pyodide.runPythonAsync(cell.code).then(function () {
            return null;
        }, function (err) {
            return err;
        }).then(function (err) {
            var collected = { items: [], figs: [] };
            try { collected = JSON.parse(pyodide.runPython('_kb_collect()')); } catch (e) {}
            renderOut(cell, buf, collected, err);
            cell.ran = !err;
            setBusy(cell, false);
            return !err;
        });
    }

    function resetKernel() {
        if (!booted || running) return;
        try { pyodide.runPython('_kb_reset()'); } catch (e) {}
        cells.forEach(function (c) { c.ran = false; c.out.hidden = true; c.out.innerHTML = ''; markStatus(c, ''); });
        setBanner('ready', '内核已重置 · 变量已清空', 'Kernel reset · variables cleared');
    }

    /* ---------------- 输出渲染 ---------------- */
    function renderOut(cell, stdoutText, collected, err) {
        var html = '';
        if (stdoutText && stdoutText.trim() !== '') {
            html += '<pre class="kb-out-text">' + esc(stdoutText.replace(/\n+$/, '')) + '</pre>';
        }
        (collected.items || []).forEach(function (it) {
            if (it[0] === 'html') html += '<div class="kb-out-df">' + it[1] + '</div>';
            else html += '<pre class="kb-out-text">' + esc(it[1]) + '</pre>';
        });
        (collected.figs || []).forEach(function (b64) {
            html += '<img class="kb-out-fig" alt="figure" src="data:image/png;base64,' + b64 + '">';
        });
        if (err) html += '<pre class="kb-out-err">' + esc(err.message || String(err)) + '</pre>';
        if (html === '') html = '<div class="kb-out-empty"><span class="i18n-zh">（无输出）</span><span class="i18n-en">(no output)</span></div>';
        cell.out.innerHTML = html;
        cell.out.hidden = false;
        markStatus(cell, err ? 'err' : 'ok');
    }

    /* ---------------- DOM 状态小工具 ---------------- */
    function setBusy(cell, busy) {
        markStatus(cell, busy ? 'run' : '');
        if (busy) { cell.out.hidden = false; cell.out.innerHTML = '<div class="kb-out-empty"><span class="i18n-zh">运行中…</span><span class="i18n-en">Running…</span></div>'; }
    }
    function markStatus(cell, state) {
        var el = cell.bar.querySelector('.kb-code-status');
        if (!el) return;
        var map = { run: ['运行中…', 'Running…'], ok: ['✓ 完成', '✓ done'], err: ['✗ 出错', '✗ error'], '': ['', ''] };
        var t = map[state] || map[''];
        el.className = 'kb-code-status' + (state ? ' is-' + state : '');
        el.innerHTML = t[0] ? '<span class="i18n-zh">' + t[0] + '</span><span class="i18n-en">' + t[1] + '</span>' : '';
    }
    function setAllDisabled(dis) {
        cells.forEach(function (c) {
            var b = c.bar.querySelector('.kb-run');
            if (b) b.disabled = dis;
        });
        var rb = document.querySelector('.kb-runbar-reset');
        if (rb) rb.disabled = dis;
    }

    var bannerEl = null;
    function setBanner(state, zh, en) {
        if (!bannerEl) return;
        bannerEl.className = 'kb-runbar is-' + state;
        var msg = bannerEl.querySelector('.kb-runbar-msg');
        if (msg) msg.innerHTML = '<span class="i18n-zh">' + esc(zh) + '</span><span class="i18n-en">' + esc(en) + '</span>';
    }

    /* ---------------- 文章增强入口 ---------------- */
    function enhance(artEl, entry) {
        currentEntry = entry;
        cells = [];
        var content = artEl.querySelector('.reader-content');
        if (!content) return;
        var codes = content.querySelectorAll('pre > code.language-python');
        if (!codes.length) { bannerEl = null; return; }

        // 顶部运行状态条 + 重置按钮
        var bar = document.createElement('div');
        bar.className = 'kb-runbar is-idle';
        bar.innerHTML =
            '<span class="kb-runbar-icon">▶</span>' +
            '<span class="kb-runbar-msg"><span class="i18n-zh">本页代码可在浏览器内直接运行。首次点击「运行」会加载 Python 环境（约 30MB，之后缓存）。</span>' +
            '<span class="i18n-en">Code on this page runs in your browser. The first Run loads the Python runtime (~30MB, cached afterwards).</span></span>' +
            '<button type="button" class="kb-runbar-reset"><span class="i18n-zh">重置内核</span><span class="i18n-en">Reset</span></button>';
        content.insertBefore(bar, content.firstChild);
        bannerEl = bar;
        bar.querySelector('.kb-runbar-reset').addEventListener('click', resetKernel);

        // 预下载/预热：空闲时后台静默初始化 Python 环境，用户点「运行」时即就绪。
        // 省流量 / 弱网(saveData、2g) 用户跳过，避免自动下大包。
        (function schedulePreload() {
            var conn = navigator.connection || {};
            if (conn.saveData || /(^|-)2g$/.test(conn.effectiveType || '')) return;
            var kick = function () { if (!booted && !booting) boot().catch(function () {}); };
            if ('requestIdleCallback' in window) requestIdleCallback(kick, { timeout: 4000 });
            else setTimeout(kick, 1800);
        })();

        Array.prototype.forEach.call(codes, function (codeEl, i) {
            var pre = codeEl.parentElement;
            var wrap = document.createElement('div');
            wrap.className = 'kb-code';
            pre.parentNode.insertBefore(wrap, pre);

            var tbar = document.createElement('div');
            tbar.className = 'kb-code-bar';
            tbar.innerHTML =
                '<button type="button" class="kb-run">▶ <span class="i18n-zh">运行</span><span class="i18n-en">Run</span></button>' +
                '<span class="kb-code-status"></span>';

            var out = document.createElement('div');
            out.className = 'kb-code-out';
            out.hidden = true;

            wrap.appendChild(tbar);
            wrap.appendChild(pre);
            wrap.appendChild(out);

            var cell = { code: codeEl.textContent, out: out, bar: tbar, ran: false };
            cells.push(cell);
            (function (idx) {
                tbar.querySelector('.kb-run').addEventListener('click', function () { runUpTo(idx); });
            })(i);
        });
    }

    window.KBRunner = { enhance: enhance };
})();
