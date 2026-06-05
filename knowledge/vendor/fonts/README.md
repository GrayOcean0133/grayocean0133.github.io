# 知识库内嵌中文字体

`cjk-subset.ttf` 用于浏览器内运行（Pyodide / matplotlib）时正确显示图表中的中文，
否则中文会渲染成「□」方框。

## 来源与许可

- 源字体：**Noto Sans SC**（思源黑体衍生，Google / Adobe），授权 **SIL Open Font License 1.1**。
- 处理：用 `fontTools` 将变量字体固定为 Regular 字重，并**子集化**为第六章讲义实际用到的
  约 780 个汉字 + ASCII，体积从 ~10MB 降到 ~218KB。
- 字体内部 family 名改为 `SimHei`，使讲义代码里现成的
  `plt.rcParams['font.sans-serif'] = ['SimHei', ...]` 无需改动即可命中本字体。
  （SIL OFL 允许修改与重命名，因为 Noto 未声明保留字名 Reserved Font Names。）

SIL OFL 1.1 全文见：<https://openfontlicense.org/>

## 重新生成

```powershell
python _build_subset.py
```

脚本会从本机 `C:\Windows\Fonts\NotoSansSC-VF.ttf` 读取源字体并重建子集。
若需扩充覆盖的汉字范围，编辑脚本里收集字符的逻辑后重跑即可。
