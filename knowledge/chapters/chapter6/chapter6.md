# 机器学习 期末复习（知识点 + 完整可运行代码）

> 本 Notebook 依据课程 PPT 的重难点与课堂框架代码整理而成，覆盖**全部 9 章**内容。
> 每个知识点都遵循「**章节讲解 → 完整带注释代码 → 代码说明**」的结构，所有代码均可直接运行并产生结果。
>
> **运行环境**：Python 3 + numpy / pandas / matplotlib / scikit-learn / scipy / Pillow。
> **数据文件**：均已放在 `data/` 文件夹下，直接相对路径读取。
> 建议在 Jupyter 中先运行第一格「全局环境设置」，再按顺序「全部运行」（Run All）。

---

## 目录

1. [第一章　机器学习概述](#ch1)
2. [第二章　K-近邻（KNN）](#ch2)
3. [第三章　线性回归](#ch3)
4. [第四章　逻辑回归](#ch4)
5. [第五章　朴素贝叶斯](#ch5)
6. [第六章　决策树（ID3 / C4.5 / CART / 剪枝）](#ch6)
7. [第七章　支持向量机（SVM）](#ch7)
8. [第八章　神经网络（感知机 / BP / MLP）](#ch8)
9. [第九章　无监督学习（聚类 / 降维 / 关联规则）](#ch9)

---

```python
# ============== 全局环境设置（务必最先运行这一格）==============
import warnings
warnings.filterwarnings('ignore')          # 屏蔽部分版本告警，复习时输出更干净

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from IPython.display import display          # 让 display() 在任意环境可用

# 让 matplotlib 正常显示中文与负号
plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False

np.random.seed(42)                           # 固定随机种子，保证结果可复现
DATA = 'data/'                               # 数据文件夹（相对当前 Notebook）
print('环境就绪：numpy', np.__version__, '| pandas', pd.__version__)
```

## <a id="ch1"></a>第一章　机器学习概述

### 1.1 核心概念
- **人工智能 ⊃ 机器学习 ⊃ 深度学习**：机器学习是让计算机利用已有数据（经验）得出模型，并用模型预测未来的方法；深度学习是实现机器学习的一类技术。
- **三大类型**：
  - **监督学习**（有标签）：又分**分类**（标签离散，如猫/狗）与**回归**（标签连续，如房价）。
  - **无监督学习**（无标签）：聚类、降维、关联规则。
  - **强化学习**：智能体在与环境交互中通过奖励信号学习策略。
- **数据集划分**：训练集（训练模型）、验证集（选超参数）、测试集（评估泛化），三者通常不重叠。

### 1.2 机器学习四要素
| 要素 | 含义 |
|---|---|
| 模型 | 概率模型 / 非概率模型；线性 / 非线性 |
| 损失函数 | 度量单样本预测误差（0-1、平方、绝对、对数损失等） |
| 优化算法 | 求解最优参数（本课程主要用**梯度下降**） |
| 模型评估 | 用训练误差 / 测试误差衡量，最终目标是**泛化能力** |

### 1.3 一般流程
数据收集 → 数据清洗 → 特征工程 → 数据建模 → 模型评估 → 部署。
> 名言：**数据和特征决定了机器学习的上限，模型和算法只是逼近这个上限。**

下面用两段代码直观感受：① 常见损失函数的形状；② 一个最小的「监督学习」完整流程。

```python
# ===== 代码1：常见损失函数形状 =====
import numpy as np
import matplotlib.pyplot as plt

z = np.linspace(-3, 3, 200)        # 预测分数 / 间隔
squared  = z**2                    # 平方损失：误差越大惩罚越大（对异常值敏感）
absolute = np.abs(z)               # 绝对损失：对异常值不敏感
zero_one = (z > 0).astype(float)   # 0-1 损失：分错记 1（不可导，难优化）
hinge    = np.maximum(0, 1 - z)    # 合页损失（SVM 用）：间隔不足 1 时线性惩罚

plt.figure(figsize=(9, 5))
plt.plot(z, squared,  label='平方损失 (Squared)')
plt.plot(z, absolute, label='绝对损失 (Absolute)')
plt.plot(z, zero_one, label='0-1 损失', linestyle='--')
plt.plot(z, hinge,    label='合页损失 (Hinge)')
plt.xlabel('预测得分 z'); plt.ylabel('损失值')
plt.title('常见损失函数对比'); plt.legend(); plt.grid(alpha=0.3)
plt.show()
```

**代码说明**：平方损失对大误差惩罚最重（曲线最陡），绝对损失增长平缓，0-1 损失是阶梯函数（不可导，实际优化常用替代品），合页损失是 SVM 的核心损失。

```python
# ===== 代码2：一个最小的「监督学习」完整流程（鸢尾花分类）=====
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier

iris = load_iris()
X, y = iris.data, iris.target                       # 特征矩阵 + 标签

# 划分训练集 / 测试集（70% 训练，30% 测试）
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42)

model = KNeighborsClassifier(n_neighbors=3)         # 选一个模型
model.fit(X_train, y_train)                         # 训练
acc = model.score(X_test, y_test)                   # 测试集评估
print('训练样本数：', X_train.shape[0], '  测试样本数：', X_test.shape[0])
print('测试集准确率：{:.2%}'.format(acc))
```

**代码说明**：这段代码浓缩了监督学习的标准范式——`加载数据 → 划分训练/测试 → fit 训练 → score 评估`。后续每一章只是把模型换成线性回归、逻辑回归、决策树、SVM 等。

---

## <a id="ch2"></a>第二章　K-近邻（KNN）

### 2.1 核心思想
**物以类聚，近朱者赤**：一个样本在特征空间中与 $k$ 个最相似（最邻近）的实例多数属于某类，则该样本也属于该类。

### 2.2 算法流程
1. 计算测试对象到训练集中每个对象的距离；
2. 按距离从近到远排序；
3. 取最近的 $k$ 个训练对象作为邻居；
4. 统计这 $k$ 个邻居的类别频次；
5. 频次最高的类别即为预测类别。

### 2.3 三要素
- **k 值选择**：$k$ 太小（如 1）易受噪声影响；$k$ 太大（=样本总数）失去判别力。常用交叉验证选最优 $k$。
- **距离度量**：见下方多种距离公式。
- **决策规则**：分类用多数表决；回归用 $k$ 个邻居标签的均值。

### 2.4 常见距离公式
- 欧氏距离：$d=\sqrt{\sum_i (x_i-y_i)^2}$
- 曼哈顿距离：$d=\sum_i |x_i-y_i|$
- 切比雪夫距离：$d=\max_i |x_i-y_i|$
- 闵可夫斯基距离：$d=(\sum_i |x_i-y_i|^p)^{1/p}$（$p=1$ 曼哈顿，$p=2$ 欧氏，$p\to\infty$ 切比雪夫）
- 汉明距离：对应位不同的比例
- 余弦相似度：$\cos\theta = \dfrac{x\cdot y}{\|x\|\,\|y\|}$

### 2.5 优缺点
- 优点：简单、天然支持多分类、对数据无分布假设、对异常点不敏感。
- 缺点：可解释性差、对样本不平衡敏感、计算/空间复杂度高（可用 KD 树加速近邻搜索）。

```python
# ===== 代码1：六种距离度量的实现 =====
import numpy as np

def euclidean(x, y):                 # 欧氏距离
    return np.sqrt(np.sum((x - y) ** 2))

def manhattan(x, y):                 # 曼哈顿距离（城市街区距离）
    return np.sum(np.abs(x - y))

def chebyshev(x, y):                 # 切比雪夫距离（各维差绝对值的最大值）
    return np.max(np.abs(x - y))

def minkowski(x, y, p):              # 闵可夫斯基距离（p 的一般形式）
    return np.sum(np.abs(x - y) ** p) ** (1 / p)

def hamming(x, y):                   # 汉明距离（对应位不同的比例）
    return np.sum(x != y) / len(x)

def cosine_sim(x, y):                # 余弦相似度
    return np.dot(x, y) / (np.linalg.norm(x) * np.linalg.norm(y))

a = np.array([4, 5]); b = np.array([1, 1])
print('欧氏距离      :', euclidean(a, b))
print('曼哈顿距离    :', manhattan(a, b))
print('切比雪夫距离  :', chebyshev(a, b))
print('闵氏距离(p=1) :', minkowski(a, b, 1))
print('闵氏距离(p=2) :', minkowski(a, b, 2))
print('汉明距离      :', hamming(np.array([1,1,0,0]), np.array([0,1,1,0])))
print('余弦相似度    :', cosine_sim(a, b))
```

**代码说明**：闵氏距离 $p=1$ 时退化为曼哈顿、$p=2$ 时退化为欧氏，验证了它是这两种距离的统一形式。这些距离函数会被下面手写的 KNN 调用。

```python
# ===== 代码2：手写 KNN 分类器（鸢尾花，取前两个特征）=====
import numpy as np
import pandas as pd
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split

iris = load_iris()
df = pd.DataFrame(iris.data, columns=iris.feature_names)
df['label'] = iris.target
df.columns = ['sepal length', 'sepal width', 'petal length', 'petal width', 'label']

# 取 3 类、4 个特征
data = np.array(df.iloc[:, :])
X, y = data[:, :-1], data[:, -1].astype(int)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

def KNN(X_train, y_train, x, k):
    # 1) 计算 x 到所有训练样本的欧氏距离
    dists = [euclidean(x, X_train[i]) for i in range(len(X_train))]
    # 2) 取距离最近的 k 个样本的下标
    knn_idx = np.argsort(dists)[:k]
    # 3) 统计这 k 个邻居的类别，做多数表决
    knn_labels = y_train[knn_idx]
    return np.bincount(knn_labels).argmax()

# 对测试集逐个预测，统计准确率
pred = np.array([KNN(X_train, y_train, x, k=3) for x in X_test])
print('单个样本预测：', KNN(X_train, y_train, X_test[0], 3), ' 真实：', y_test[0])
print('手写 KNN 测试集准确率：{:.2%}'.format(np.mean(pred == y_test)))
```

**代码说明**：手写 KNN 三步走——算距离、取最近 $k$ 个、`np.bincount(...).argmax()` 做多数表决。用 `np.argsort` 排序下标比 PPT 里手动维护最大值的写法更简洁。

```python
# ===== 代码3：用 sklearn 调库 + 网格搜索最优 k =====
from sklearn.neighbors import KNeighborsClassifier

best_k, best_score = -1, 0.0
for k in range(1, 11):
    clf = KNeighborsClassifier(n_neighbors=k)
    clf.fit(X_train, y_train)
    score = clf.score(X_test, y_test)
    print(f'k={k:2d}  测试集准确率={score:.3f}')
    if score > best_score:
        best_k, best_score = k, score

print(f'\n最优 k = {best_k}，对应准确率 = {best_score:.2%}')
```

**代码说明**：sklearn 的 `KNeighborsClassifier` 一行即可建模。通过遍历 $k=1\sim10$ 并在测试集比较，演示了**超参数选择**的基本做法（严谨做法应在验证集上选 $k$）。

---

## <a id="ch3"></a>第三章　线性回归

### 3.1 概念
线性回归通过特征的线性组合预测连续标签，目标是找一条直线/超平面使预测值与真实值的误差最小。模型：$\hat{y}=Xw$（$X$ 第一列补 1 表示偏置）。

### 3.2 代价函数（均方误差）
$$J(w)=\frac{1}{2m}\sum_{i=1}^m (x^{(i)}w-y^{(i)})^2$$

### 3.3 两种求解方法
- **最小二乘法（解析解）**：$w=(X^TX)^{-1}X^Ty$。一次算出，无需学习率；但需求逆，特征多（>1万）时代价大，只适用于线性模型。
- **梯度下降（迭代解）**：$w := w-\alpha\cdot\frac{1}{m}X^T(Xw-y)$。需选学习率、需迭代；适用面广。
  - 三种形式：批量 BGD（用全部样本）、随机 SGD（用 1 个样本）、小批量 MBGD（用一批，batch 常取 32/64/128）。

### 3.4 评价指标
- MSE $=\frac1m\sum(y_i-\hat y_i)^2$，RMSE $=\sqrt{MSE}$，MAE $=\frac1m\sum|y_i-\hat y_i|$
- $R^2$：越接近 1 拟合越好。

### 3.5 标准化、过拟合与正则化
- **标准化/归一化**：基于距离的模型（KNN、SVM、K-means）与线性回归需要；树模型、朴素贝叶斯不需要。
- **过拟合**处理：更多数据、降维、正则化、集成。
- **正则化**：L1（Lasso，产生稀疏）、L2（Ridge，平滑权重）、弹性网络。

```python
# ===== 代码1：读取数据并可视化 =====
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

data = pd.read_csv(DATA + 'regress_data1.csv')   # 列：人口、收益
display(data.head())

fig, ax = plt.subplots(figsize=(10, 6))
ax.scatter(data['人口'], data['收益'], label='训练数据')
ax.set_xlabel('人口', fontsize=14)
ax.set_ylabel('收益', fontsize=14)
ax.set_title('预测收益和人口规模', fontsize=14)
ax.legend(); plt.show()
```

**代码说明**：数据是「城市人口 → 餐车收益」的一元回归问题。散点图显示人口与收益大致线性正相关，适合用线性回归拟合。

```python
# ===== 代码2：代价函数 + 最小二乘法（解析解）=====
def computeCost(X, y, w):
    inner = np.power(X @ w - y, 2)          # 每个样本的平方误差
    return np.sum(inner) / (2 * X.shape[0]) # 均方误差 / 2

# 构造特征矩阵：第一列补 1（偏置项），其余为特征
data2 = data.copy()
data2.insert(0, 'Ones', 1)
X = np.array(data2.iloc[:, :-1])            # 特征矩阵 (m, 2)
y = np.array(data2.iloc[:, -1:])           # 标签列向量 (m, 1)
w = np.random.randn(X.shape[1], 1)         # 随机初始化参数

def LSM(X, y):                              # 最小二乘法解析解
    return np.linalg.inv(X.T @ X) @ X.T @ y

optimal_w = LSM(X, y)
print('随机初始参数的代价：', computeCost(X, y, w))
print('最小二乘法最优参数 w =\n', optimal_w.ravel())
print('最优参数的代价：', computeCost(X, y, optimal_w))
```

**代码说明**：`computeCost` 实现 MSE/2；`LSM` 用公式 $w=(X^TX)^{-1}X^Ty$ 一步求出最优参数。可见最优参数的代价远小于随机初始值。

```python
# ===== 代码3：批量梯度下降（BGD）=====
def batch_gradientDescent(X, y, w, alpha, count):
    costs = []
    for i in range(count):
        # 核心更新公式：w = w - α/m * X^T (Xw - y)
        w = w - (X.T @ (X @ w - y)) * alpha / X.shape[0]
        cost = computeCost(X, y, w)
        costs.append(cost)
        if i % 200 == 0:
            print(f'第 {i:4d} 次迭代，cost = {cost:.4f}')
    return w, costs

w_init = np.random.randn(X.shape[1], 1)
alpha, iters = 0.01, 1000
w_gd, costs = batch_gradientDescent(X, y, w_init, alpha, iters)
print('\n梯度下降参数 w =', w_gd.ravel())
print('最小二乘参数 w =', optimal_w.ravel(), ' (两者应非常接近)')
```

```python
# ===== 代码4：拟合直线 + 代价下降曲线 =====
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# 左图：拟合直线
xs = np.array([data['人口'].min(), data['人口'].max()])
ys = optimal_w[0, 0] + optimal_w[1, 0] * xs
axes[0].scatter(data['人口'], data['收益'], label='训练数据')
axes[0].plot(xs, ys, 'r', label='拟合直线')
axes[0].set_xlabel('人口'); axes[0].set_ylabel('收益')
axes[0].set_title('线性回归拟合结果'); axes[0].legend()

# 右图：代价随迭代下降
axes[1].plot(range(iters), costs)
axes[1].set_xlabel('迭代次数'); axes[1].set_ylabel('代价 J(w)')
axes[1].set_title('梯度下降代价曲线')
plt.show()
```

**代码说明**：左图红线即拟合出的回归直线；右图显示代价随迭代单调下降并趋于平稳，说明梯度下降收敛。梯度下降的结果与最小二乘的解析解几乎一致。

```python
# ===== 代码5：sklearn 线性回归 + 评价指标 + 正则化 =====
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

X1 = np.array(data[['人口']])     # 原始单特征（不含偏置列，sklearn 自动处理截距）
y1 = np.array(data['收益'])

lin = LinearRegression().fit(X1, y1)
pred = lin.predict(X1)
print('LinearRegression 系数={:.4f}, 截距={:.4f}'.format(lin.coef_[0], lin.intercept_))
print('MSE  = {:.4f}'.format(mean_squared_error(y1, pred)))
print('RMSE = {:.4f}'.format(np.sqrt(mean_squared_error(y1, pred))))
print('MAE  = {:.4f}'.format(mean_absolute_error(y1, pred)))
print('R^2  = {:.4f}'.format(r2_score(y1, pred)))

# 正则化模型（数据简单，此处主要演示用法）
ridge = Ridge(alpha=1.0).fit(X1, y1)    # L2 正则
lasso = Lasso(alpha=0.1).fit(X1, y1)    # L1 正则
print('\nRidge 系数={:.4f}  Lasso 系数={:.4f}'.format(ridge.coef_[0], lasso.coef_[0]))
```

**代码说明**：`LinearRegression` 自动拟合截距，结果与手写一致。四个评价指标里 $R^2$ 越接近 1 越好。`Ridge`/`Lasso` 分别是 L2/L1 正则化版本，`alpha` 是正则化强度（超参数）。

---

## <a id="ch4"></a>第四章　逻辑回归

### 4.1 概念
逻辑回归（Logistic Regression）名字带「回归」，但实际处理**分类**问题。它与线性回归同属广义线性模型：
- 线性回归拟合**真实标签**；
- 逻辑回归拟合标签的**对数几率** $\ln\frac{p}{1-p}=Xw$，再经 **Sigmoid** 把连续值压到 $(0,1)$ 当概率。

### 4.2 Sigmoid 与假设
$$g(z)=\frac{1}{1+e^{-z}},\qquad h_w(x)=g(Xw)=\frac{1}{1+e^{-Xw}}$$
预测：$h\ge 0.5$ 判为正类，否则负类。

### 4.3 交叉熵损失 + 梯度
单样本对数损失，整体代价：
$$J(w)=-\frac1m\sum_i\big[y_i\ln h_i+(1-y_i)\ln(1-h_i)\big]$$
梯度与线性回归形式一致（只是 $h$ 用了 Sigmoid）：$\;\nabla J=\frac1m X^T(g(Xw)-y)$。

### 4.4 多分类：One-vs-Rest
依次把某一类当正类、其余当负类训练二分类器；$K$ 类需 $K$（或 $K-1$）次。

### 4.5 分类评价指标（混淆矩阵）
- 查准率 Precision $=\frac{TP}{TP+FP}$；查全率 Recall $=\frac{TP}{TP+FN}$
- 准确率 Accuracy $=\frac{TP+TN}{TP+FP+TN+FN}$
- F1 $=\frac{2\cdot P\cdot R}{P+R}$

```python
# ===== 代码1：读取数据并可视化（两门考试成绩 -> 是否录取）=====
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

data = pd.read_csv(DATA + 'ex2data1.txt', header=None,
                   names=['Exam 1', 'Exam 2', 'Admitted'])
print('数据形状：', data.shape)
display(data.head())

positive = data[data['Admitted'] == 1]    # 录取
negative = data[data['Admitted'] == 0]    # 未录取

fig, ax = plt.subplots(figsize=(9, 6))
ax.scatter(positive['Exam 1'], positive['Exam 2'], c='b', marker='o', label='Admitted')
ax.scatter(negative['Exam 1'], negative['Exam 2'], c='r', marker='x', label='Not Admitted')
ax.set_xlabel('Exam 1 Score'); ax.set_ylabel('Exam 2 Score'); ax.legend()
plt.show()
```

**代码说明**：蓝点（录取）与红叉（未录取）大致可被一条直线分开，是典型的二分类问题，适合逻辑回归。

```python
# ===== 代码2：Sigmoid + 交叉熵代价 + 梯度下降（手写）=====
def sigmoid(z):
    z = np.clip(z, -500, 500)              # 防止 exp 溢出
    return 1 / (1 + np.exp(-z))

def computeCost(w, X, y):
    first  = np.multiply(-y, np.log(sigmoid(X @ w)))
    second = np.multiply(-(1 - y), np.log(1 - sigmoid(X @ w)))
    return np.sum(first + second) / X.shape[0]

# 特征标准化（成绩范围 0~100，标准化后梯度下降收敛更快更稳）
feat = data[['Exam 1', 'Exam 2']].values
feat = (feat - feat.mean(axis=0)) / feat.std(axis=0)
X = np.hstack([np.ones((feat.shape[0], 1)), feat])     # 补偏置列
y = data['Admitted'].values.reshape(-1, 1)
w = np.zeros((X.shape[1], 1))
print('初始代价：', computeCost(w, X, y))

def batch_gradientDescent(X, y, w, alpha, count):
    costs = []
    for i in range(count):
        w = w - (X.T @ (sigmoid(X @ w) - y)) * alpha / X.shape[0]
        costs.append(computeCost(w, X, y))
        if i % 5000 == 0:
            print(f'第 {i:5d} 次迭代，cost = {costs[-1]:.4f}')
    return w, costs

w, costs = batch_gradientDescent(X, y, w, alpha=0.1, count=20000)
print('\n训练后代价：', computeCost(w, X, y))
```

```python
# ===== 代码3：预测 + 准确率（注意：取模 % 是 PPT 笔误，应为除法 /）=====
def predict(w, X):
    prob = sigmoid(X @ w)
    return np.array([1 if p >= 0.5 else 0 for p in prob]).reshape(-1, 1)

pred = predict(w, X)
accuracy = np.mean(pred == y)              # 正确：用平均（等价于 正确数 / 总数）
print('手写逻辑回归训练集准确率：{:.2%}'.format(accuracy))

# 画出决策边界（标准化空间内 w0 + w1*x1 + w2*x2 = 0）
fig, ax = plt.subplots(figsize=(9, 6))
ax.scatter(X[y.ravel()==1, 1], X[y.ravel()==1, 2], c='b', marker='o', label='Admitted')
ax.scatter(X[y.ravel()==0, 1], X[y.ravel()==0, 2], c='r', marker='x', label='Not Admitted')
xb = np.array([X[:,1].min(), X[:,1].max()])
yb = -(w[0,0] + w[1,0]*xb) / w[2,0]
ax.plot(xb, yb, 'g-', label='决策边界')
ax.set_xlabel('Exam 1 (标准化)'); ax.set_ylabel('Exam 2 (标准化)'); ax.legend()
plt.show()
```

**代码说明**：`predict` 以 0.5 为阈值把概率转成 0/1。**特别提醒**：课堂框架代码里 `accuracy = sum(correct) % len(correct)` 用了取模运算符 `%`，这是笔误，正确应为除法 `/`（或直接取平均）。绿线是学到的决策边界，能较好地把两类分开。

```python
# ===== 代码4：sklearn 逻辑回归 + 完整分类评价指标 =====
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (confusion_matrix, precision_score,
                             recall_score, accuracy_score, f1_score)

clf = LogisticRegression()
clf.fit(feat, y.ravel())                   # 用标准化特征
pred_sk = clf.predict(feat)

cm = confusion_matrix(y.ravel(), pred_sk)  # 混淆矩阵 [[TN,FP],[FN,TP]]
print('混淆矩阵:\n', cm)
print('准确率 Accuracy : {:.3f}'.format(accuracy_score(y.ravel(), pred_sk)))
print('查准率 Precision: {:.3f}'.format(precision_score(y.ravel(), pred_sk)))
print('查全率 Recall   : {:.3f}'.format(recall_score(y.ravel(), pred_sk)))
print('F1 分数        : {:.3f}'.format(f1_score(y.ravel(), pred_sk)))
```

**代码说明**：`LogisticRegression` 调库训练。混淆矩阵的四格对应 TN/FP/FN/TP，由此算出 Precision（查准）、Recall（查全）、F1（两者调和平均），是分类任务最常考的评价指标。

---

## <a id="ch5"></a>第五章　朴素贝叶斯

### 5.1 判别模型 vs 生成模型
- **判别模型**：直接学 $P(Y|X)$（线性/逻辑回归、决策树、SVM……）。
- **生成模型**：先学联合分布 $P(X,Y)=P(Y)P(X|Y)$，再推 $P(Y|X)$（朴素贝叶斯、HMM……）。

### 5.2 贝叶斯公式
$$P(Y|X)=\frac{P(X|Y)P(Y)}{P(X)}\;\propto\; \underbrace{P(X|Y)}_{似然}\,\underbrace{P(Y)}_{先验}$$
分类时只需比较各类别的「似然 × 先验」，取最大者。

### 5.3 朴素 = 条件独立假设
假设各特征在给定类别下相互独立：
$$P(X|Y)=\prod_{j} P(x_j|Y)$$
这大幅减少了参数量，使学习与预测简单高效。

### 5.4 拉普拉斯平滑
为避免某特征值在训练集中没出现导致概率为 0：
$$P(x_j|Y)=\frac{N_{x_j,Y}+1}{N_Y+S_j}$$
其中 $S_j$ 为该特征取值数。

### 5.5 三种常见实现
- GaussianNB（特征服从高斯分布，连续值）
- MultinomialNB（多项式分布，计数特征如词频）
- BernoulliNB（伯努利分布，0/1 特征）

```python
# ===== 代码1：手写朴素贝叶斯（打网球例子 + 拉普拉斯平滑）=====
import numpy as np
import pandas as pd

# 14 条训练数据：天气/温度/湿度/风 -> 是否打网球
rows = [
 ['Sunny','Hot','High','Weak','No'],   ['Sunny','Hot','High','Strong','No'],
 ['Overcast','Hot','High','Weak','Yes'],['Rain','Mild','High','Weak','Yes'],
 ['Rain','Cool','Normal','Weak','Yes'], ['Rain','Cool','Normal','Strong','No'],
 ['Overcast','Cool','Normal','Strong','Yes'],['Sunny','Mild','High','Weak','No'],
 ['Sunny','Cool','Normal','Weak','Yes'],['Rain','Mild','Normal','Weak','Yes'],
 ['Sunny','Mild','Normal','Strong','Yes'],['Overcast','Mild','High','Strong','Yes'],
 ['Overcast','Hot','Normal','Weak','Yes'],['Rain','Mild','High','Strong','No'],
]
cols = ['天气','温度','湿度','风','打网球']
df = pd.DataFrame(rows, columns=cols)
display(df)

def naive_bayes_predict(df, sample, laplace=True):
    label_col = '打网球'
    classes = df[label_col].unique()
    feats = [c for c in df.columns if c != label_col]
    result = {}
    for c in classes:
        sub = df[df[label_col] == c]
        prior = len(sub) / len(df)                 # 先验 P(Y=c)
        prob = prior
        for f, v in zip(feats, sample):
            Sj = df[f].nunique()                   # 该特征取值数
            cnt = np.sum(sub[f] == v)              # 类 c 下取值为 v 的计数
            if laplace:                            # 拉普拉斯平滑
                prob *= (cnt + 1) / (len(sub) + Sj)
            else:
                prob *= cnt / len(sub)
        result[c] = prob
    return result

# 预测：Sunny, Cool, High, Strong
sample = ['Sunny', 'Cool', 'High', 'Strong']
res = naive_bayes_predict(df, sample, laplace=True)
total = sum(res.values())
print('\n待预测样本：', sample)
for c, p in res.items():
    print(f'  类别 {c}: 似然×先验 = {p:.6f}  归一化概率 = {p/total:.2%}')
print('预测结果：', max(res, key=res.get))
```

**代码说明**：手写贝叶斯按「先验 × 各特征条件概率连乘」计算每个类别的得分，取最大者。加入**拉普拉斯平滑**（分子 +1、分母 +取值数）后，即便某组合在训练集中没出现也不会得到 0 概率，避免「零概率问题」。

```python
# ===== 代码2：sklearn 高斯朴素贝叶斯（鸢尾花二分类）=====
import numpy as np
import pandas as pd
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB

def create_data():
    iris = load_iris()
    d = pd.DataFrame(iris.data, columns=iris.feature_names)
    d['label'] = iris.target
    arr = np.array(d.iloc[:100, :])     # 取前 100 条（两类）
    return arr[:, :-1], arr[:, -1]

X, y = create_data()
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

clf = GaussianNB()                      # 假设特征服从高斯分布
clf.fit(X_train, y_train)
print('GaussianNB 测试集准确率：{:.2%}'.format(clf.score(X_test, y_test)))
print('前两个测试样本预测：', clf.predict(X_test[:2]), ' 真实：', y_test[:2])
```

**代码说明**：鸢尾花特征是连续值，用 `GaussianNB`（假设每个特征在各类下服从正态分布）。二分类问题上朴素贝叶斯通常能取得很高准确率。

---

## <a id="ch6"></a>第六章　决策树（ID3 / C4.5 / CART / 剪枝）

### 6.1 原理
决策树是树状结构的**判别模型**：根节点/非叶节点代表特征，分支代表特征取值，叶节点代表类别。用贪心算法自顶向下构建，关键是**选哪个特征作分裂依据**。

### 6.2 三种算法对比
| 算法 | 树结构 | 特征选择 | 连续值 | 剪枝 | 任务 |
|---|---|---|---|---|---|
| ID3 | 多叉 | 信息增益 | 否 | 否 | 分类 |
| C4.5 | 多叉 | 信息增益率 | 是 | 是 | 分类 |
| CART | 二叉 | 基尼指数/均方差 | 是 | 是 | 分类+回归 |

### 6.3 信息论基础
- **信息熵**（不确定性）：$H(D)=-\sum_k p_k\log_2 p_k$，越小越纯。
- **条件熵**：$H(D|A)=\sum_v \frac{|D_v|}{|D|}H(D_v)$
- **信息增益**（ID3）：$g(D,A)=H(D)-H(D|A)$，越大越好。
- **信息增益率**（C4.5）：$g_R=\dfrac{g(D,A)}{H_A(D)}$，克服 ID3 偏好取值多的特征。
- **基尼指数**（CART）：$Gini(D)=1-\sum_k p_k^2$。

### 6.4 剪枝（防过拟合）
- 预剪枝：划分前判断是否提升验证集精度，不提升就不分（可能欠拟合）。
- 后剪枝：先长成完整树，再自底向上用叶节点替换子树（欠拟合风险更小，但计算量大）。

```python
# ===== 代码1：手写 ID3——信息熵 / 条件熵 / 信息增益（贷款数据集）=====
import numpy as np
import pandas as pd
from math import log

def create_data():
    datasets = [
        ['青年','否','否','一般','否'], ['青年','否','否','好','否'],
        ['青年','是','否','好','是'],   ['青年','是','是','一般','是'],
        ['青年','否','否','一般','否'], ['中年','否','否','一般','否'],
        ['中年','否','否','好','否'],   ['中年','是','是','好','是'],
        ['中年','否','是','非常好','是'],['中年','否','是','非常好','是'],
        ['老年','否','是','非常好','是'],['老年','否','是','好','是'],
        ['老年','是','否','好','是'],   ['老年','是','否','非常好','是'],
        ['老年','否','否','一般','否'],
    ]
    labels = ['年龄','有工作','有自己的房子','信贷情况','类别']
    return datasets, labels

datasets, labels = create_data()
display(pd.DataFrame(datasets, columns=labels))

def calc_ent(datasets):                    # 计算数据集的信息熵
    n = len(datasets)
    label_count = {}
    for row in datasets:                   # 统计每个类别出现次数
        label = row[-1]
        label_count[label] = label_count.get(label, 0) + 1
    return -sum((c/n) * log(c/n, 2) for c in label_count.values())

def cond_ent(datasets, axis=0):            # 计算某特征的条件熵
    n = len(datasets)
    feature_sets = {}
    for row in datasets:                   # 按该特征取值分组
        feature_sets.setdefault(row[axis], []).append(row)
    return sum((len(p)/n) * calc_ent(p) for p in feature_sets.values())

print('\n整个数据集的信息熵 H(D) = {:.3f}'.format(calc_ent(datasets)))
```

```python
# ===== 代码2：信息增益，选出最优分裂特征 =====
def info_gain_train(datasets, labels):
    count = len(datasets[0]) - 1           # 特征数
    ent = calc_ent(datasets)               # H(D)
    best_feature, max_ig, best_idx = [], -1, -1
    for c in range(count):
        ig = ent - cond_ent(datasets, axis=c)   # 信息增益 = H(D) - H(D|A)
        best_feature.append((c, ig))
        print('特征({}) 的信息增益为：{:.3f}'.format(labels[c], ig))
        if ig > max_ig:
            max_ig, best_idx = ig, c
    return best_idx

best_fea = info_gain_train(datasets, labels)
print('\n=> 特征({}) 信息增益最大，选为根节点'.format(labels[best_fea]))
```

**代码说明**：`calc_ent` 算信息熵，`cond_ent` 按特征取值分组算条件熵，`info_gain_train` 比较各特征的信息增益。结果「有自己的房子」信息增益最大，被选为根节点——与课件手算结论一致。

```python
# ===== 代码3：C4.5 信息增益率（克服 ID3 对多取值特征的偏好）=====
def cond_ent_and_split(datasets, axis=0):
    n = len(datasets)
    feature_sets = {}
    for row in datasets:
        feature_sets.setdefault(row[axis], []).append(row)
    ce = sum((len(p)/n) * calc_ent(p) for p in feature_sets.values())      # 条件熵
    split_info = -sum((len(p)/n) * log(len(p)/n, 2) for p in feature_sets.values())  # 特征自身的熵 H_A(D)
    return ce, split_info

def info_gain_ratio_train(datasets, labels):
    ent = calc_ent(datasets)
    max_gr, best_idx = -1, -1
    for c in range(len(datasets[0]) - 1):
        ce, split_info = cond_ent_and_split(datasets, axis=c)
        gr = (ent - ce) / split_info if split_info != 0 else 0   # 信息增益率
        print('特征({}) 的信息增益率为：{:.3f}'.format(labels[c], gr))
        if gr > max_gr:
            max_gr, best_idx = gr, c
    return best_idx

best_fea2 = info_gain_ratio_train(datasets, labels)
print('\n=> 按信息增益率，特征({}) 最优'.format(labels[best_fea2]))
```

**代码说明**：C4.5 在信息增益基础上除以「特征自身的熵」$H_A(D)$ 得到增益率，从而抑制 ID3 偏好取值数目多的特征（如「编号」）的缺点。

```python
# ===== 代码4：基尼指数 + sklearn 决策树（分类）+ 可视化 =====
import numpy as np
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier, plot_tree

def gini(labels):                          # 基尼指数 Gini(D)=1-Σ p_k^2
    _, counts = np.unique(labels, return_counts=True)
    p = counts / counts.sum()
    return 1 - np.sum(p ** 2)

print('示例：标签[0,0,1,1] 的基尼指数 =', gini(np.array([0,0,1,1])))

iris = load_iris()
X, y = iris.data[:, :2], iris.target       # 取前两个特征便于画图
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

clf = DecisionTreeClassifier(criterion='gini', max_depth=3, random_state=42)
clf.fit(X_train, y_train)
print('CART 决策树测试集准确率：{:.2%}'.format(clf.score(X_test, y_test)))

plt.figure(figsize=(14, 8))
plot_tree(clf, filled=True, feature_names=iris.feature_names[:2],
          class_names=iris.target_names, rounded=True)
plt.title('CART 决策树（max_depth=3）')
plt.show()
```

```python
# ===== 代码5：决策树回归（不同深度的拟合对比，体会过拟合）=====
import numpy as np
from sklearn.tree import DecisionTreeRegressor

rng = np.random.RandomState(1)
X = np.sort(5 * rng.rand(80, 1), axis=0)
y = np.sin(X).ravel()
y[::5] += 3 * (0.5 - rng.rand(16))        # 人为加入噪声

regr_1 = DecisionTreeRegressor(max_depth=2).fit(X, y)
regr_2 = DecisionTreeRegressor(max_depth=5).fit(X, y)
X_test = np.arange(0.0, 5.0, 0.01)[:, np.newaxis]
y_1, y_2 = regr_1.predict(X_test), regr_2.predict(X_test)

plt.figure(figsize=(10, 6))
plt.scatter(X, y, s=20, edgecolor='black', c='darkorange', label='data')
plt.plot(X_test, y_1, color='cornflowerblue', label='max_depth=2', linewidth=2)
plt.plot(X_test, y_2, color='yellowgreen', label='max_depth=5', linewidth=2)
plt.xlabel('data'); plt.ylabel('target'); plt.title('决策树回归')
plt.legend(); plt.show()
```

**代码说明**：`plot_tree` 把树结构可视化，可看到每个节点的分裂特征、基尼值、样本分布。回归对比图中，`max_depth=5` 的曲线把噪声也拟合了（阶梯过细 → **过拟合**），`max_depth=2` 更平滑——这正是需要**剪枝/限制深度**的原因。

---

## <a id="ch7"></a>第七章　支持向量机（SVM）

### 7.1 概念
SVM 是二分类的广义线性分类器，目标是找**最大间隔超平面**：让离超平面最近的点（**支持向量**）到超平面的距离最大，从而获得更好的泛化能力。

### 7.2 间隔与优化
点到超平面 $w^Tx+b=0$ 的几何间隔为 $\frac{|w^Tx+b|}{\|w\|}$。最大化间隔等价于：
$$\min_{w,b}\tfrac12\|w\|^2,\quad s.t.\;y_i(w^Tx_i+b)\ge 1$$
用拉格朗日乘子法转对偶问题求解（KKT 条件）。

### 7.3 硬间隔 / 软间隔
- 硬间隔：要求完全分对（线性可分）。
- 软间隔：引入松弛变量 $\xi_i$（合页损失），允许少量错分；惩罚参数 **C** 越大对错分惩罚越重。

### 7.4 核技巧（处理线性不可分）
用核函数 $K(x_i,x_j)=\phi(x_i)^T\phi(x_j)$ 隐式把数据映射到高维空间使其线性可分：
- 线性核、多项式核、**RBF（高斯核）**。
- RBF 的 **gamma**：越大决策边界越复杂（过拟合），越小越平滑（欠拟合），需与 C 协同调参。

```python
# ===== 代码1：线性 SVM——不同 C 的决策边界（svmdata1）=====
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn import svm

data1 = pd.read_csv(DATA + 'svmdata1.csv')   # 列：X1, X2, y
display(data1.head())

fig, axes = plt.subplots(1, 2, figsize=(15, 6))
for ax, C in zip(axes, [1, 100]):
    model = svm.LinearSVC(C=C, loss='hinge', max_iter=20000, dual=True)
    model.fit(data1[['X1', 'X2']], data1['y'])
    score = model.score(data1[['X1', 'X2']], data1['y'])

    # 用决策函数值上色，直观显示置信度
    conf = model.decision_function(data1[['X1', 'X2']])
    ax.scatter(data1['X1'], data1['X2'], s=50, c=conf, cmap='seismic')
    # 画决策边界 w1*x + w2*y + b = 0
    w, b = model.coef_[0], model.intercept_[0]
    xs = np.linspace(data1['X1'].min(), data1['X1'].max(), 100)
    ys = (-w[0] * xs - b) / w[1]
    ax.plot(xs, ys, 'k-', linewidth=1)
    ax.set_title(f'LinearSVC (C={C})  准确率={score:.2f}')
plt.show()
```

**代码说明**：`LinearSVC` 用合页损失的线性 SVM。颜色表示决策函数置信度，黑线是决策边界。C 越大模型越「努力」分对每个点（间隔变窄），对左上角离群点更敏感。

```python
# ===== 代码2：非线性 SVM——RBF 核 + gamma 的影响（svmdata2）=====
data2 = pd.read_csv(DATA + 'svmdata2.csv')
fig, axes = plt.subplots(1, 3, figsize=(18, 5))
for ax, gamma in zip(axes, [1, 10, 20]):
    svc = svm.SVC(C=100, gamma=gamma, probability=True)
    svc.fit(data2[['X1', 'X2']], data2['y'])
    score = svc.score(data2[['X1', 'X2']], data2['y'])
    prob = svc.predict_proba(data2[['X1', 'X2']])[:, 0]
    ax.scatter(data2['X1'], data2['X2'], s=30, c=prob, cmap='Reds')
    ax.set_title(f'RBF SVM (gamma={gamma})  准确率={score:.3f}')
plt.show()
```

**代码说明**：RBF 核能拟合非线性边界。gamma 越大，每个支持向量影响范围越小、边界越「弯曲」复杂（容易过拟合）；gamma 适中时泛化更好。

```python
# ===== 代码3：网格搜索最优 (C, gamma)（svmdata3 训练 + 验证集）=====
data3 = pd.read_csv(DATA + 'svmdata3.csv')
data3val = pd.read_csv(DATA + 'svmdata3val.csv')
X, y = data3[['X1', 'X2']], data3['y']
Xval, yval = data3val[['X1', 'X2']], data3val['yval']

C_values = [0.01, 0.03, 0.1, 0.3, 1, 3, 10, 30, 100]
gamma_values = [0.01, 0.03, 0.1, 0.3, 1, 3, 10, 30, 100]
best_score, best_params = 0, {'C': None, 'gamma': None}
for C in C_values:
    for gamma in gamma_values:
        svc = svm.SVC(C=C, gamma=gamma)
        svc.fit(X, y)
        score = svc.score(Xval, yval)       # 在验证集上选超参数
        if score > best_score:
            best_score, best_params = score, {'C': C, 'gamma': gamma}

print('验证集最优准确率：{:.3f}'.format(best_score))
print('最优超参数：', best_params)
```

**代码说明**：用两层循环在 9×9=81 组 (C, gamma) 中搜索，按**验证集**准确率挑最优组合——这是 SVM 调参的标准做法（网格搜索）。

---

## <a id="ch8"></a>第八章　神经网络（感知机 / BP / MLP）

### 8.1 发展脉络
M-P 模型(1943) → 单层感知机(1958) → 感知机局限(1969) → BP 反向传播(1986) → 深度学习(2006) → AlexNet(2012) → AlphaGo(2016) → 大模型。

### 8.2 感知机
二分类线性模型 $f(x)=sign(w\cdot x+b)$，对误分类样本用 $w\leftarrow w+\eta y x,\;b\leftarrow b+\eta y$ 更新。
**单层感知机只能解决线性可分问题**（无法处理异或 XOR），需引入隐藏层 → 多层感知机 MLP。

### 8.3 激活函数（必须非线性，否则多层退化为单层）
- **Sigmoid** $\frac1{1+e^{-z}}$：输出 (0,1)，二分类输出层；有梯度消失。
- **Tanh**：输出 (-1,1)，零中心化。
- **ReLU** $\max(0,z)$：缓解梯度消失、稀疏、计算快，深层网络默认。
- **Softmax**：多分类输出层，输出归一化为概率分布。

### 8.4 BP（反向传播）算法
前向传播算各层输出 → 算输出误差 → 用**链式法则**把误差反向传播算各层梯度 → 梯度下降更新参数，循环至收敛。

### 8.5 损失函数与优化器
- 回归：MSE / MAE / Huber；分类：交叉熵（配 Sigmoid/Softmax）。
- 优化器：SGD → Momentum → RMSProp → **Adam**（最常用，自适应学习率 + 动量）。
- 过拟合抑制：数据增强、正则化、Dropout、早停、集成。

```python
# ===== 代码1：三种激活函数的形状 =====
import numpy as np
import matplotlib.pyplot as plt

def sigmoid(x): return 1 / (1 + np.exp(-x))
def tanh(x):    return np.tanh(x)
def relu(x):    return np.maximum(0, x)

x = np.linspace(-5, 5, 200)
plt.figure(figsize=(15, 4))
for i, (name, f) in enumerate([('Sigmoid', sigmoid), ('Tanh', tanh), ('ReLU', relu)]):
    plt.subplot(1, 3, i + 1)
    plt.plot(x, f(x)); plt.title(name + ' Function'); plt.grid(alpha=0.3)
plt.show()
```

**代码说明**：Sigmoid 压到 (0,1)、Tanh 压到 (-1,1) 且零中心化、ReLU 在正半轴恒等、负半轴归零。注意原 PPT 代码里 `plt.title('...Function’)` 用了中文右单引号 `’`，会报语法错误，这里已改成正确的英文引号。

```python
# ===== 代码2：手写感知机（鸢尾花前两类，线性可分）=====
import numpy as np
import pandas as pd
from sklearn.datasets import load_iris
import matplotlib.pyplot as plt

iris = load_iris()
df = pd.DataFrame(iris.data, columns=iris.feature_names)
df['label'] = iris.target
df.columns = ['sepal length', 'sepal width', 'petal length', 'petal width', 'label']

data = np.array(df.iloc[:100, [0, 1, -1]])
X, y = data[:, :-1], data[:, -1]
y = np.array([1 if i == 1 else -1 for i in y])      # 标签转为 +1 / -1

def sign(x, w, b):
    return np.dot(x, w) + b

w, b, lr = np.ones(X.shape[1]), 0.0, 0.1
is_wrong = False
while not is_wrong:                                  # 直到没有误分类点
    wrong_count = 0
    for d in range(len(X)):
        if y[d] * sign(X[d], w, b) <= 0:            # 误分类
            w = w + lr * y[d] * X[d]                # 更新权重
            b = b + lr * y[d]                       # 更新偏置
            wrong_count += 1
    if wrong_count == 0:
        is_wrong = True
print('训练得到 w =', w, ' b =', b)

# 画决策直线
x_pts = np.linspace(4, 7, 10)
y_pts = -(w[0] * x_pts + b) / w[1]
plt.figure(figsize=(9, 6))
plt.plot(x_pts, y_pts, 'g', label='决策边界')
plt.scatter(data[:50, 0], data[:50, 1], color='blue', label='Iris-setosa')
plt.scatter(data[50:100, 0], data[50:100, 1], color='orange', label='Iris-versicolor')
plt.xlabel('sepal length'); plt.ylabel('sepal width'); plt.legend(); plt.show()
```

**代码说明**：感知机对每个误分类点 $y(w\cdot x+b)\le 0$ 就更新参数，循环到全部分对为止。因为这两类线性可分，算法一定收敛，绿线即学到的分隔线。

```python
# ===== 代码3：BP 反向传播解决异或 XOR（两层网络手写）=====
import numpy as np

def sigmoid(x):            return 1 / (1 + np.exp(-x))
def sigmoid_derivative(x): return x * (1 - x)        # 输入已是 sigmoid 输出

# 初始化参数：2->2->1 网络
W1 = np.array([[0., 1.], [0., 1.]])   # 输入->隐藏 (2x2)
b1 = np.array([0., 0.])
W2 = np.array([[0., 1.]])             # 隐藏->输出 (1x2)
b2 = np.array([0.])

X = np.array([[0,0],[0,1],[1,0],[1,1]], dtype=float)   # XOR 输入
y = np.array([[0],[1],[1],[0]], dtype=float)           # XOR 标签

def forward(X):
    z1 = X @ W1 + b1; h = sigmoid(z1)         # 隐藏层
    z2 = h @ W2.T + b2                         # 输出层
    return sigmoid(z2), h

def backward(X, y, output, h, lr=0.5):
    global W1, W2, b1, b2
    m = len(X)
    d_output = output - y
    d_z2 = d_output * sigmoid_derivative(output)
    d_W2 = (d_z2.T @ h) / m
    d_b2 = np.sum(d_z2, axis=0) / m
    d_h  = d_z2 @ W2                           # 用当前 W2 反传
    d_z1 = d_h * sigmoid_derivative(h)
    d_W1 = (X.T @ d_z1) / m
    d_b1 = np.sum(d_z1, axis=0) / m
    W2 -= lr * d_W2; b2 -= lr * d_b2           # 统一更新
    W1 -= lr * d_W1; b1 -= lr * d_b1
    return np.mean(d_output ** 2)

print('初始预测:', forward(X)[0].ravel().round(3))
for epoch in range(5000):
    output, h = forward(X)
    loss = backward(X, y, output, h)
    if epoch % 1000 == 0:
        print(f'Epoch {epoch}: Loss={loss:.4f}')
print('最终预测:', forward(X)[0].ravel().round(3))
print('分类结果:', (forward(X)[0] > 0.5).astype(int).ravel())
```

**代码说明**：单层感知机无法解决异或，但加一个隐藏层后，通过 BP（前向传播 → 算误差 → 链式法则反向求梯度 → 更新参数）即可学会 XOR。训练后预测值接近 [0,1,1,0]。

```python
# ===== 代码4：sklearn MLP 识别手写数字 =====
import matplotlib.pyplot as plt
from sklearn.neural_network import MLPClassifier
from sklearn.datasets import load_digits
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

digits = load_digits()                 # 1797 张 8x8 手写数字图
X, y = digits.data, digits.target

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()              # 标准化（神经网络对尺度敏感）
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

mlp = MLPClassifier(hidden_layer_sizes=(128, 64),  # 两层隐藏层
                    max_iter=100, random_state=42)
mlp.fit(X_train, y_train)
print('训练集准确率: {:.4f}'.format(mlp.score(X_train, y_train)))
print('测试集准确率: {:.4f}'.format(mlp.score(X_test, y_test)))

# 展示 9 张测试图的真实/预测标签
fig, axes = plt.subplots(3, 3, figsize=(7, 7))
pred = mlp.predict(X_test)
for i, ax in enumerate(axes.ravel()):
    ax.imshow(X_test[i].reshape(8, 8), cmap='gray')
    ax.set_title(f'真实:{y_test[i]} 预测:{pred[i]}')
    ax.axis('off')
plt.tight_layout(); plt.show()
```

**代码说明**：`MLPClassifier(hidden_layer_sizes=(128,64))` 构建两层隐藏层的多层感知机，默认用 Adam 优化器、ReLU 激活。手写数字识别测试集准确率通常 >95%。`hidden_layer_sizes`、`max_iter`、`learning_rate_init`、`activation` 都是常考超参数。

---

## <a id="ch9"></a>第九章　无监督学习（聚类 / 降维 / 关联规则）

### 9.1 概念
无监督学习处理**无标签**数据，目标是发现隐藏结构：聚类、降维、关联规则、推荐。

### 9.2 K-means 聚类
将数据分成 $K$ 个不重叠簇，每簇用**质心**（均值）表示，目标是最小化所有点到所属质心的平方距离和（畸变函数）。
流程：① 初始化 K 个质心 → ② 每点归到最近质心 → ③ 重算各簇质心 → ④ 重复直到质心不变。
- K 值选择：先验法、**手肘法**（SSE 拐点）。
- 缺点：需预设 K、对初值敏感（K-means++ 改进）、只适合凸形簇、对异常值敏感。

### 9.3 层次聚类
- 聚合（自下而上）：每点一簇 → 不断合并最近两簇。
- 分裂（自上而下）：所有点一簇 → 不断拆分。
- 簇间距离：最小/最大/平均/中心距离。可用**树状图**展示。

### 9.4 DBSCAN（密度聚类）
基于密度：核心点（Eps 邻域内点数 ≥ MinPts）、边界点、噪声点。能发现任意形状簇、识别噪声、无需指定簇数；但对 Eps/MinPts 联合调参敏感。

### 9.5 PCA 降维
把高维数据线性变换到低维，保留最大方差方向（主成分），用少量主成分近似原数据。

### 9.6 关联规则
支持度（组合出现频率）、置信度（买 A 后买 B 的概率）、提升度（A 对 B 的提升程度），用于购物篮分析。

### 9.7 聚类评价指标
有真值：ARI、AMI、同一性、完整性、V-measure；无真值：**轮廓系数**（[-1,1]，越接近 1 越好）。

```python
# ===== 代码1：手写 K-means（ex7data2）=====
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

data2 = pd.read_csv(DATA + 'ex7data2.csv')   # 列：X1, X2
X = data2.values
display(data2.head())

def find_closest_centroids(X, centroids):
    m, k = X.shape[0], centroids.shape[0]
    idx = np.zeros(m, dtype=int)
    for i in range(m):
        # 计算第 i 个点到每个质心的距离，取最近的质心编号
        dists = [np.sum((X[i] - centroids[j]) ** 2) for j in range(k)]
        idx[i] = np.argmin(dists)
    return idx

def compute_centroids(X, idx, k):
    n = X.shape[1]
    centroids = np.zeros((k, n))
    for i in range(k):
        centroids[i] = X[idx == i].mean(axis=0)   # 该簇所有点的均值
    return centroids

def run_k_means(X, initial_centroids, max_iters):
    centroids = initial_centroids.copy()
    for _ in range(max_iters):
        idx = find_closest_centroids(X, centroids)   # 分配
        centroids = compute_centroids(X, idx, centroids.shape[0])  # 更新
    return idx, centroids

initial_centroids = np.array([[3, 3], [6, 2], [8, 5]])
idx, centroids = run_k_means(X, initial_centroids, 10)

plt.figure(figsize=(9, 7))
for i, color in zip(range(3), ['r', 'g', 'b']):
    cluster = X[idx == i]
    plt.scatter(cluster[:, 0], cluster[:, 1], s=30, color=color, label=f'Cluster {i+1}')
plt.scatter(centroids[:, 0], centroids[:, 1], s=300, c='black', marker='*', label='质心')
plt.legend(); plt.title('手写 K-means 聚类结果'); plt.show()
```

**代码说明**：K-means 两步迭代——`find_closest_centroids`（把每个点分给最近质心）和 `compute_centroids`（用簇内均值更新质心）。黑色星号是最终质心，三种颜色清晰分出三个簇。

```python
# ===== 代码2：sklearn KMeans + 手肘法选 K =====
from sklearn.cluster import KMeans

SSE = []                                   # 每个 K 的误差平方和(inertia)
for k in range(1, 9):
    km = KMeans(n_clusters=k, n_init=10, random_state=42)
    km.fit(data2)
    SSE.append(km.inertia_)

plt.figure(figsize=(9, 5))
plt.plot(range(1, 9), SSE, 'o-')
plt.xlabel('K (簇数量)'); plt.ylabel('SSE (畸变)')
plt.title('手肘法选择最优 K'); plt.grid(alpha=0.3)
plt.show()
print('各 K 的 SSE：', [round(s, 1) for s in SSE])
```

**代码说明**：SSE 随 K 增大而下降，在「肘部」（这里约 K=3）后下降明显变缓，故选拐点处的 K 作为最优簇数——这就是**手肘法**。

```python
# ===== 代码3：K-means 图像压缩（颜色量化）=====
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans

pic = plt.imread(DATA + 'bird_small.png')      # 读图（用 matplotlib，替代 skimage）
if pic.max() > 1:                              # 若是 0~255，归一化到 0~1
    pic = pic / 255.0
pic = pic[:, :, :3]                            # 只保留 RGB 三通道
print('图像形状：', pic.shape)

h, w, c = pic.shape
data = pic.reshape(h * w, c)                   # 拉平成 (像素数, 3)

model = KMeans(n_clusters=16, n_init=4, random_state=42)   # 把颜色聚成 16 类
model.fit(data)
centroids = model.cluster_centers_
C = model.predict(data)
compressed = centroids[C].reshape(h, w, c)     # 用质心颜色替换每个像素

fig, ax = plt.subplots(1, 2, figsize=(11, 5))
ax[0].imshow(pic); ax[0].set_title('原图'); ax[0].axis('off')
ax[1].imshow(compressed); ax[1].set_title('压缩后(16色)'); ax[1].axis('off')
plt.show()
```

**代码说明**：把每个像素的 RGB 当成三维样本，用 K-means 聚成 16 类，再用 16 个质心颜色替换所有像素——图片只用 16 种颜色表示，实现**颜色量化压缩**。这是聚类在图像处理的经典应用。

```python
# ===== 代码4：层次聚类树状图（鸢尾花）=====
import numpy as np
import matplotlib.pyplot as plt
from scipy.cluster.hierarchy import dendrogram
from sklearn.datasets import load_iris
from sklearn.cluster import AgglomerativeClustering

iris = load_iris()
X = iris.data
# distance_threshold=0 + n_clusters=None 计算完整的树
model = AgglomerativeClustering(distance_threshold=0, n_clusters=None).fit(X)

def plot_dendrogram(model, **kwargs):
    counts = np.zeros(model.children_.shape[0])
    n_samples = len(model.labels_)
    for i, merge in enumerate(model.children_):
        current_count = 0
        for child_idx in merge:
            if child_idx < n_samples:
                current_count += 1            # 叶子节点
            else:
                current_count += counts[child_idx - n_samples]
        counts[i] = current_count
    linkage_matrix = np.column_stack([model.children_, model.distances_, counts]).astype(float)
    dendrogram(linkage_matrix, **kwargs)

plt.figure(figsize=(11, 6))
plt.title('层次聚类树状图（前三级）')
plot_dendrogram(model, truncate_mode='level', p=3)
plt.xlabel('节点中的点数（无括号则为点索引）')
plt.show()
```

**代码说明**：聚合层次聚类把每个样本逐步合并成树，`dendrogram` 画出树状图。纵轴是合并时的簇间距离，横切一条线即可得到不同数量的簇——无需预先指定 K。

```python
# ===== 代码5：DBSCAN 密度聚类 + 评价指标 =====
import numpy as np
from sklearn.cluster import DBSCAN
from sklearn import metrics
from sklearn.datasets import make_blobs
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

centers = [[1, 1], [-1, -1], [1, -1]]
X, labels_true = make_blobs(n_samples=750, centers=centers,
                            cluster_std=0.4, random_state=0)
X = StandardScaler().fit_transform(X)

def plot_dbscan(MyEps, MiniSample):
    db = DBSCAN(eps=MyEps, min_samples=MiniSample).fit(X)
    core_mask = np.zeros_like(db.labels_, dtype=bool)
    core_mask[db.core_sample_indices_] = True
    labels = db.labels_
    n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)
    n_noise_ = list(labels).count(-1)
    print(f'eps={MyEps}, min_samples={MiniSample}')
    print('  估计簇数: %d  噪声点: %d' % (n_clusters_, n_noise_))
    print('  同一性: %.3f  完整性: %.3f  V-measure: %.3f'
          % (metrics.homogeneity_score(labels_true, labels),
             metrics.completeness_score(labels_true, labels),
             metrics.v_measure_score(labels_true, labels)))
    print('  ARI: %.3f  轮廓系数: %.3f'
          % (metrics.adjusted_rand_score(labels_true, labels),
             metrics.silhouette_score(X, labels)))

    unique_labels = set(labels)
    colors = [plt.cm.Spectral(each) for each in np.linspace(0, 1, len(unique_labels))]
    plt.figure(figsize=(7, 6))
    for k, col in zip(unique_labels, colors):
        if k == -1:
            col = [0, 0, 0, 1]              # 噪声点用黑色
        mask = labels == k
        xy = X[mask & core_mask]            # 核心点（大）
        plt.plot(xy[:,0], xy[:,1], 'o', markerfacecolor=tuple(col),
                 markeredgecolor='k', markersize=12)
        xy = X[mask & ~core_mask]           # 边界/噪声点（小）
        plt.plot(xy[:,0], xy[:,1], 'o', markerfacecolor=tuple(col),
                 markeredgecolor='k', markersize=6)
    plt.title('簇的数量为: %d' % n_clusters_)
    plt.show()

plot_dbscan(0.3, 10)    # 较优参数
```

**代码说明**：DBSCAN 按密度聚类，自动判定核心点/边界点/噪声点（黑色），能发现任意形状的簇且无需指定簇数。输出的同一性、完整性、V-measure、ARI、轮廓系数是常用聚类评价指标。可尝试改 `plot_dbscan(0.1,10)`、`plot_dbscan(0.4,10)` 观察参数敏感性。

```python
# ===== 代码6：PCA 降维（3 维 -> 2 维）=====
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA

np.random.seed(500)
mean = [0, 0, 0]
cov = [[1, 0.8, 0.5], [0.8, 1, 0.3], [0.5, 0.3, 1]]   # 特征间有相关性
X = np.random.multivariate_normal(mean, cov, 200)

pca = PCA(n_components=2)        # 降到 2 维
X_pca = pca.fit_transform(X)
print('各主成分解释方差比例：', pca.explained_variance_ratio_.round(3))
print('累计解释方差：{:.1%}'.format(pca.explained_variance_ratio_.sum()))

fig = plt.figure(figsize=(13, 5))
ax1 = fig.add_subplot(121, projection='3d')
ax1.scatter(X[:, 0], X[:, 1], X[:, 2], c='b', alpha=0.5)
ax1.set_title('原始 3 维数据')
ax2 = fig.add_subplot(122)
ax2.scatter(X_pca[:, 0], X_pca[:, 1], c='r', alpha=0.5)
ax2.set_xlabel('主成分 1'); ax2.set_ylabel('主成分 2')
ax2.set_title('PCA 降维后 2 维数据')
plt.show()
```

**代码说明**：PCA 找到方差最大的两个正交方向（主成分），把 3 维数据投影到 2 维。`explained_variance_ratio_` 显示前两个主成分保留了原数据约 90% 以上的信息——用少量维度近似原数据。

```python
# ===== 代码7：关联规则——手算支持度/置信度/提升度 =====
# 5 笔交易，看 {面包} -> {黄油} 这条规则
transactions = [
    {'面包', '黄油', '牛奶'},
    {'面包', '黄油'},
    {'面包', '牛奶'},
    {'面包', '黄油', '鸡蛋'},
    {'牛奶', '鸡蛋'},
]
N = len(transactions)
sup_bread       = sum('面包' in t for t in transactions) / N
sup_butter      = sum('黄油' in t for t in transactions) / N
sup_bread_butter= sum({'面包','黄油'} <= t for t in transactions) / N

confidence = sup_bread_butter / sup_bread          # 置信度 P(黄油|面包)
lift       = confidence / sup_butter               # 提升度
print('支持度 support(面包,黄油) = {:.2f}'.format(sup_bread_butter))
print('置信度 confidence(面包->黄油) = {:.2f}'.format(confidence))
print('提升度 lift(面包->黄油) = {:.2f}'.format(lift))
print('\n解读：买面包的顾客有 {:.0%} 也会买黄油；提升度 >1 说明两者正相关。'.format(confidence))
```

**代码说明**：购物篮分析三指标——支持度（组合出现频率）、置信度（买面包后买黄油的条件概率）、提升度（>1 表示正相关，捆绑销售有意义）。这是 Apriori 等关联规则算法的基础概念。

---

## 复习小结

| 章节 | 模型 | 类型 | 关键词 |
|---|---|---|---|
| 2 | KNN | 分类/回归 | 距离度量、k 值、KD 树 |
| 3 | 线性回归 | 回归 | 最小二乘、梯度下降、正则化 |
| 4 | 逻辑回归 | 分类 | Sigmoid、交叉熵、混淆矩阵 |
| 5 | 朴素贝叶斯 | 分类(生成) | 贝叶斯公式、条件独立、拉普拉斯平滑 |
| 6 | 决策树 | 分类/回归 | 信息增益、增益率、基尼、剪枝 |
| 7 | SVM | 分类 | 最大间隔、软间隔、核技巧 |
| 8 | 神经网络 | 分类/回归 | 感知机、激活函数、BP、Adam |
| 9 | 无监督 | 聚类/降维 | K-means、层次、DBSCAN、PCA |

> 祝考试顺利！如需针对某章深入练习，可修改对应代码格中的超参数（k、alpha、C、gamma、K 等）观察结果变化。
