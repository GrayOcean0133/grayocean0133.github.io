# Chapter 4 Git/GitHub、VS Code 与 Anaconda 上手


做项目之前，先把"趁手的兵器"配齐。本章把三件几乎天天要用的工具串成一条完整的工作流：用 **Git/GitHub** 管理代码与协作，用 **VS Code** 写代码、调代码，用 **Anaconda** 隔离每个项目的 Python 环境。三者各管一摊，配合起来就是现代工程的"标准起手式"。

> 本章是上手指南，目标是让你**能跑起来**，并理解每一步在做什么。命令以 Windows / PowerShell 为主，macOS / Linux 在终端里同样适用（差异会单独标注）。

---

## 4.1 总览：三件套各管什么

很多新同学一开始会把这三样东西搞混，其实它们解决的是完全不同的问题：

| 工具 | 解决的问题 | 一句话理解 |
| ---- | --------- | --------- |
| **Git** | 代码的版本管理 | 给代码做"时间机器"，每次改动都能回溯 |
| **GitHub** | 代码的托管与协作 | Git 仓库的"云端家园"+ 多人协作平台 |
| **VS Code** | 写代码 / 调试 / 集成各种工具 | 一个高度可扩展的代码编辑器 |
| **Anaconda** | Python 环境与依赖管理 | 给每个项目一个互不打架的"独立房间" |

它们的协作关系可以这样理解：

```text
Anaconda  → 准备好这个项目要用的 Python 环境（解释器 + 一堆库）
   │
VS Code   → 在这个环境里写代码、跑代码、调试
   │
Git       → 把代码的每次改动记录成版本
   │
GitHub    → 把版本推到云端，和队友一起协作
```

> **关键认知**：Git 和 GitHub 不是一回事。Git 是装在你电脑上的版本控制**软件**；GitHub 是一个用 Git 的**网站**（同类还有 GitLab、Gitee 等）。没有 GitHub 也能用 Git，但用了 GitHub 协作会方便很多。

---

## 4.2 Git 与 GitHub

### 4.2.1 为什么需要版本控制

没有版本控制时，大家保存代码的方式通常是这样的：

```text
作业最终版.py
作业最终版_真的最终.py
作业最终版_这次真的不改了.py
作业最终版_老师让改的.py
```

这套"文件名版本控制法"有三个致命问题：**无法知道每个版本改了什么、无法多人同时改、改坏了无法干净地回退**。Git 就是来解决这些问题的：它把每一次改动记录成一个**提交（commit）**，附带时间、作者和说明，任何时候都能回到历史上的任意一个版本，也能让多个人各自改动后自动合并。

### 4.2.2 安装与首次配置

到 [git-scm.com](https://git-scm.com/) 下载安装。Windows 安装包自带 **Git Bash**，是个很好用的命令行。装完后打开终端验证：

```bash
git --version
```

第一次用必须设置你的身份（会写进每个 commit）：

```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱@example.com"
```

> 邮箱建议用 GitHub 账号的邮箱，这样 GitHub 才能把提交关联到你的头像和贡献记录。

### 4.2.3 核心概念：四个区域

Git 里最容易绕晕的，是文件在四个"区域"之间流转。先建立这张图，后面的命令就都好理解了：

```text
工作区             暂存区            本地仓库           远程仓库
(Working Dir)     (Stage/Index)    (Local Repo)      (Remote/GitHub)
   │   git add        │   git commit    │   git push        │
   ├─────────────────>├────────────────>├──────────────────>│
   │                  │                 │                   │
   │<──────────────────────────────────────────────────────┤
                         git pull / git clone
```

- **工作区**：你正在编辑的文件夹本身。
- **暂存区**：用 `git add` 挑选"这次要提交哪些改动"的暂存清单。
- **本地仓库**：`git commit` 后，改动被永久记录到本地的 `.git` 目录里。
- **远程仓库**：GitHub 上的副本，`git push` 上传、`git pull` 下载。

> 为什么要有"暂存区"这一步？因为它让你能**精挑细选**：一次只把相关的改动打包成一个 commit，而不是把所有零散修改一锅端。

### 4.2.4 最常用的命令

下面这十几个命令覆盖了日常 95% 的场景：

```bash
# —— 获取 / 初始化仓库 ——
git clone <仓库URL>          # 把 GitHub 上的仓库克隆到本地
git init                     # 把当前文件夹变成一个 git 仓库

# —— 查看状态 ——
git status                   # 看哪些文件改了 / 暂存了（用得最多）
git diff                     # 看具体改了哪几行
git log --oneline --graph    # 看提交历史

# —— 提交改动 ——
git add <文件>               # 把某个文件加入暂存区
git add .                    # 把所有改动加入暂存区
git commit -m "说明这次改了什么"

# —— 与远程同步 ——
git pull                     # 拉取并合并远程最新改动
git push                     # 把本地提交推送到远程

# —— 分支 ——
git branch                   # 列出所有分支
git switch -c <新分支名>     # 创建并切换到新分支（旧写法：git checkout -b）
git switch <分支名>          # 切换分支
git merge <分支名>           # 把指定分支合并进当前分支
```

> **写好 commit 信息**：一句话讲清"做了什么"，例如 `修复登录页空指针` 比 `update`、`改了点东西` 有用一百倍。团队里读 `git log` 的人会感谢你。

### 4.2.5 .gitignore：不该提交的东西别提交

仓库里有些文件**不应该**被 Git 跟踪：体积巨大的数据集、编译产物、密钥、还有 Anaconda/Python 的缓存。在仓库根目录建一个 `.gitignore` 文件列出它们：

```gitignore
# Python
__pycache__/
*.pyc
.ipynb_checkpoints/

# 虚拟环境（环境本身不进仓库，用 environment.yml 复现，见 4.4.5）
.venv/
env/

# 编辑器 / 系统
.vscode/
.DS_Store

# 数据与模型（通常太大，不进 git）
*.csv
*.pth
data/
```

> **重要**：绝不要把密码、API Key、`.env` 这类敏感信息提交到 GitHub——一旦推上去，即使后来删掉，历史记录里依然能翻出来。

### 4.2.6 一个典型的个人工作流

每天写代码的循环，基本就是这五步：

| 步骤 | 命令 | 作用 |
| ---- | ---- | ---- |
| 1 | `git pull` | 开工前先同步队友的最新改动 |
| 2 | *（写代码）* | 正常编辑文件 |
| 3 | `git add .` | 把改动放进暂存区 |
| 4 | `git commit -m "..."` | 记录成一个版本 |
| 5 | `git push` | 推送到 GitHub |

### 4.2.7 多人协作：分支与 Pull Request

多人开发时，**不要直接往主分支（main）上提交**。规范的做法是"分支开发 + Pull Request 合并"：

```bash
git switch -c feature/login     # 1. 从 main 切出一个功能分支
# ... 在分支上开发、commit ...
git push -u origin feature/login # 2. 把分支推到 GitHub
```

然后到 GitHub 网页上，点 **"Compare & pull request"** 发起一个 **Pull Request（PR）**，请队友 **Review（评审）**，通过后再 **Merge（合并）** 进 main。

> 这样做的好处：main 分支始终是可用的稳定版本；每个功能独立开发互不干扰；合并前有人帮你把关代码质量。这也是 AI-Link 仓库统一遵循的协作方式。

### 4.2.8 常见问题排查

**① 合并冲突（merge conflict）**
当两个人改了同一处代码，`git pull` / `git merge` 会报冲突。Git 会在文件里插入这样的标记：

```text
<<<<<<< HEAD
你的版本
=======
对方的版本
>>>>>>> main
```

手动编辑，删掉 `<<<<<<<` / `=======` / `>>>>>>>` 三行标记，保留正确的结果，然后 `git add` 那个文件、再 `git commit` 即可。VS Code 对冲突有图形化的"接受当前/接受传入/同时保留"按钮，比手改方便。

**② 想撤销改动**

```bash
git restore <文件>            # 丢弃工作区里某文件的未暂存改动
git restore --staged <文件>   # 把文件移出暂存区（保留改动）
git commit --amend            # 修改"上一次"提交（改信息或补文件）
```

> `git reset --hard` 会**永久丢弃**改动，用前务必想清楚——它属于"难以反悔"的操作。

**③ push 时要求登录 / 认证失败**
GitHub 早已不支持账号密码推送。两种主流认证方式：

- **Personal Access Token（PAT）**：在 GitHub → Settings → Developer settings 里生成一个 token，推送时把它当密码用。
- **SSH Key**：本地 `ssh-keygen` 生成密钥，把公钥贴到 GitHub → Settings → SSH keys，之后用 `git@github.com:...` 形式的地址免密推送。

---

## 4.3 VS Code

### 4.3.1 安装

到 [code.visualstudio.com](https://code.visualstudio.com/) 下载安装。Windows 安装时建议勾选 **"添加到 PATH"** 和 **"在文件夹的右键菜单中打开"**，这样能直接在任意文件夹右键 → "通过 Code 打开"。

### 4.3.2 三个最该先记住的操作

VS Code 功能很多，但新手先掌握这三样就够用了：

| 操作 | 快捷键（Windows） | 作用 |
| ---- | --------------- | ---- |
| **命令面板** | `Ctrl + Shift + P` | 输入命令名就能执行任何功能（最重要！） |
| **集成终端** | `` Ctrl + ` `` | 在编辑器里直接开终端，跑 git / conda |
| **全局搜索** | `Ctrl + Shift + F` | 跨整个项目搜文本 |

> macOS 把 `Ctrl` 换成 `Cmd` 即可。记不住快捷键时，万能解法就是 `Ctrl+Shift+P` 然后搜功能名。

### 4.3.3 必备扩展

VS Code 的灵魂在于扩展（Extensions，左侧四个方块的图标 / `Ctrl+Shift+X`）。做 Python / AI 项目建议先装这几个：

| 扩展 | 作用 |
| ---- | ---- |
| **Python**（Microsoft 官方） | Python 语言支持、运行、调试 |
| **Pylance** | 智能补全与类型检查（装 Python 时通常一起来） |
| **Jupyter** | 在 VS Code 里直接跑 `.ipynb` 笔记本 |
| **GitLens** | 增强 Git：看每一行是谁、什么时候改的 |
| **中文语言包**（Chinese Simplified） | 把界面变成中文 |

### 4.3.4 内置 Git 集成

VS Code 左侧的 **源代码管理（Source Control）** 面板（`Ctrl+Shift+G`）把常用 Git 操作图形化了：改动的文件会列出来，点 `+` 暂存、写信息后点 `✓` 提交、再点同步按钮 push/pull。**不用记命令也能完成日常提交**，但理解 4.2 的命令能让你在出问题时知道发生了什么。

### 4.3.5 选择 Python 解释器（连接 conda 环境）

这是把 VS Code 和 Anaconda 接起来的**关键一步**：`Ctrl+Shift+P` → 输入 `Python: Select Interpreter` → 在列表里选中你为这个项目建的 conda 环境（见下一节）。选好后，右下角状态栏会显示当前环境名，运行和调试就都会用这个环境了。

---

## 4.4 Anaconda

### 4.4.1 为什么需要环境管理：依赖地狱

假设项目 A 需要 `numpy 1.20`，项目 B 需要 `numpy 2.0`，如果所有库都装在同一个全局 Python 里，它们就会**互相覆盖、彼此冲突**——这就是俗称的"依赖地狱（dependency hell）"。

解决办法是给每个项目一个**独立的虚拟环境**：环境之间的库互不可见、互不影响。Anaconda（及其轻量版 Miniconda）就是管理这些环境最常用的工具。

### 4.4.2 安装：Anaconda 还是 Miniconda？

- **Anaconda**：体积大（几个 GB），自带几百个常用科学计算库，开箱即用。
- **Miniconda**：只含 conda 本体和 Python，需要什么自己装，干净小巧。

> 推荐 **Miniconda**：可控、不臃肿。到 [docs.conda.io](https://docs.conda.io/en/latest/miniconda.html) 下载。Windows 安装后，从开始菜单打开 **"Anaconda Prompt"**，或让安装程序把 conda 加入 PATH 后在任意终端使用。

验证安装：

```bash
conda --version
```

### 4.4.3 conda 核心命令

```bash
# 创建一个名为 ailink、用 Python 3.11 的环境
conda create -n ailink python=3.11

# 激活 / 退出环境
conda activate ailink
conda deactivate

# 在当前激活的环境里装库
conda install numpy pandas matplotlib
pip install some-package          # conda 装不到的，用 pip 补（见 4.4.4）

# 查看
conda env list                    # 列出所有环境
conda list                        # 列出当前环境装了哪些库

# 删除一个环境
conda remove -n ailink --all
```

> 激活成功后，终端提示符前会出现 `(ailink)` 字样，表示你现在"身处"这个环境里。

### 4.4.4 conda 与 pip 的关系

两者都能装包，但有分工，混用要讲顺序：

| | conda | pip |
| ---- | ---- | ---- |
| 来源 | conda 仓库 | PyPI |
| 能装的东西 | Python 包 + 非 Python 依赖（如 CUDA、MKL） | 仅 Python 包，但数量最全 |
| 建议 | **优先用 conda 装核心库** | conda 没有的再用 pip 补 |

> **经验法则**：在一个环境里，先用 `conda install` 装能装的，剩下的再 `pip install`。尽量别在两者间反复横跳，否则容易把环境搞乱。

### 4.4.5 用 environment.yml 复现环境

环境本身**不进 Git 仓库**（太大、还跟操作系统相关）。正确做法是导出一份"环境配方"提交到仓库，队友照着一键还原：

```bash
# 导出当前环境
conda env export > environment.yml

# 队友拿到 environment.yml 后还原
conda env create -f environment.yml
```

一个精简的 `environment.yml` 长这样：

```yaml
name: ailink
channels:
  - defaults
dependencies:
  - python=3.11
  - numpy
  - pandas
  - pip
  - pip:
      - some-package-only-on-pypi
```

### 4.4.6 在 VS Code / Jupyter 里用 conda 环境

- **跑脚本**：按 4.3.5 选好解释器即可，VS Code 会自动在该环境里运行。
- **跑 Notebook**：打开 `.ipynb` 后，点右上角的 **"选择内核（Select Kernel）"**，选你的 conda 环境。

> 如果在 VS Code 的解释器列表里找不到刚建的环境，重启一下 VS Code，或确认环境确实创建成功（`conda env list`）。

---

## 4.5 三件套协同：从零跑通一个项目

把前面的东西串起来，一个新项目的完整起手流程是这样的：

```bash
# 1. 建并激活项目环境（Anaconda）
conda create -n myproj python=3.11
conda activate myproj

# 2. 克隆仓库（Git/GitHub）
git clone https://github.com/你的组织/myproj.git
cd myproj

# 3. 按配方装依赖
conda env update -f environment.yml   # 或 pip install -r requirements.txt

# 4. 用 VS Code 打开
code .
```

接着在 VS Code 里：`Ctrl+Shift+P` → `Python: Select Interpreter` → 选 `myproj` 环境 → 开始写代码。写完后用源代码管理面板或命令提交：

```bash
git switch -c feature/my-task
git add .
git commit -m "完成我的功能"
git push -u origin feature/my-task
```

最后到 GitHub 发起 Pull Request，等队友 Review 通过后合并。**一个完整的开发闭环就跑通了。**

---

## 4.6 常见问题速查

| 现象 | 可能原因 / 解决 |
| ---- | -------------- |
| `git` / `conda` / `code` 命令找不到 | 没加入 PATH；重装时勾选"添加到 PATH"，或重启终端 |
| `conda activate` 报错没初始化 | 先运行一次 `conda init`，再重开终端 |
| push 一直要密码且失败 | 改用 PAT 或 SSH Key（见 4.2.8） |
| VS Code 跑代码用错了 Python | 右下角检查解释器，重新 `Select Interpreter` |
| `pip install` 装到了全局而非环境里 | 先 `conda activate` 确认提示符有 `(环境名)` 再装 |
| 合并冲突看不懂 | 用 VS Code 的冲突可视化按钮处理（见 4.2.8） |
| 不小心提交了大文件 / 密钥 | 立刻处理：撤销提交、换掉密钥；必要时联系仓库管理员清理历史 |

---

## 小结

- **Git** 管版本、**GitHub** 管协作、**VS Code** 管编辑、**Anaconda** 管环境——分工明确，配合成链。
- 日常 Git 只需记住 `pull → 改 → add → commit → push` 这个循环，以及多人协作走"分支 + PR"。
- 每个项目用独立 conda 环境，靠 `environment.yml` 让队友一键复现，环境本身别进仓库。
- VS Code 里最关键的一步是 **选对 Python 解释器**，把它和你的 conda 环境接上。

> 工具是手段不是目的。先照着本章把流程跑通，真正动手做一两个项目后，这些命令很快就会变成肌肉记忆。
