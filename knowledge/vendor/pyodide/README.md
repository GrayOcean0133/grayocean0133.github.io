# 自托管 Pyodide 运行时

放置浏览器内 Python 运行所需的 Pyodide 核心 + 科学计算包，让访客从 **本站自己的服务器**
加载，而不依赖外网 CDN（解决国内访问 jsdelivr 偶发慢/被墙的问题）。

## 如何填充本目录

```powershell
./fetch-pyodide.ps1
```

脚本会解析 `pyodide-lock.json` 的依赖闭包，只下载用到的包
（numpy / pandas / matplotlib / scikit-learn / scipy / pillow 及其依赖），约 **90MB**。

## runner.js 的加载顺序

[`knowledge/runner.js`](../../runner.js) 启动时按顺序探测：

1. `knowledge/vendor/pyodide/`（本目录，自托管，**存在即优先**）
2. `https://gcore.jsdelivr.net/...`（CDN 兜底，国内通常较稳）
3. `https://cdn.jsdelivr.net/...`（CDN 兜底）

所以：**本目录为空时站点照常用 CDN 工作**；填充后自动切到自托管，无需改代码。

## 部署提示

这些文件较大（~90MB）。是否纳入 git 由你决定：

- 若站点通过 git 部署到服务器：`git add knowledge/vendor/pyodide` 一并提交即可随站点上线。
- 若不想让 git 仓库变大：把本目录单独同步/上传到服务器对应路径（Caddy 站点根下的
  `knowledge/vendor/pyodide/`）即可，仓库里保留 `fetch-pyodide.ps1` 与本说明。
