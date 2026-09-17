# Phase 0 事实审计

审计日期：2026-09-17。范围以 `../PROJECT_BRIEF.md` 为准。本阶段完成事实、冲突与覆盖审计；**没有重构 MATLAB，也没有声称完成论文数值复现**。科研分歧留待作者审阅，不以未经批准的参数替换消解。

## 1. 证据与阅读范围

完整阅读两篇 PDF 的正文、数学定义、实验与结论；证明用于理解假设和适用范围，不重建证明。提取文本并视觉检查全部图页，尤其 thesis PDF 26–29、38、41–42、48、50–52、55、59、62、65、69–70、74 和 extension 3、7–8、10、12 页。thesis 以下位置使用印刷页，PDF 页通常加 6。`FIGURE_MANIFEST.md` 包含 thesis 23 图、extension 6 图及补充实验；两文没有需另行复现的编号数据表或编号算法表。正文案例和算法规则也纳入审计。

来源简称：

- **T**：`source_material/papers/thesis.pdf`，88 PDF 页。
- **E**：`source_material/papers/ifac_extension_37.pdf`，13 PDF 页；模板页眉/DOI 不能当作已核实出版信息。
- **L**：`source_material/legacy_matlab/simulation_summary/`，45 个 `.m`。
- **G**：`source_material/legacy_github/ZehuiGuo_Pareto_Improvement_Simulation-main/`，20 个 `.m`。
- **P**：`reference/previous_prototype/`，53 个 `.m`，含 35 个包函数、7 个配置、5 个实验入口/总入口、4 个测试类和启动/测试入口。阅读其文档、配置、函数和测试，不认定其结构正确。

[输入清单](evidence/source_inventory.csv) 对 source/reference 的 136 个文件记录大小与 SHA256，包括论文、ZIP、README 和历史审计。ZIP 中 24 个文件与 G 逐字节相同，[归档检查](evidence/archive_check.json) 保存归档注释中的提交标识；这不是在线 GitHub 历史验证。118 个 MATLAB 文件有 99 个规范化文本版本；重复不是独立复现实验。未找到独立实验数据集、缺失的 `testfun3.m` 或原型已生成的结果文件。全部参数主要内嵌于源码。

完整逐文件分类见 [65 个原始 MATLAB 文件清单](evidence/script_classification.csv)，包含用途、输入输出、依赖、图号和执行状态。原始材料和原型均保持不变。临时 PDF 文本/渲染只用于阅读，不构成新的科研结果。

## 2. 数学对象—算法—代码

### 2.1 向量收益 Nash 集与单纯形映射

各 agent 最大化向量 `Ji=(Ji1,…,Jisi)`，状态 `x=(x1,…,xn)`，agent i 只控制 xi。向量 Nash 条件是固定他人状态后不能通过自身变化实现 Pareto 支配；不能把它等同于集中式全体收益 Pareto 最优。二次收益按 `Jij(x)=1/2 xᵀAij x+bijᵀx+cij` 解释，对称 A；own-gradient 仅取 A 的 agent 控制行。

T Chapter 2：对每个 agent 选择 simplex 权重 wi，组成加权 own-gradient 线性方程 `M(w)x+q(w)=0`，解 `x*(w)=-M(w)\q(w)`。**M 和 q 都随权重变化**。在论文给出的非奇异、凹性等条件下，乘积单纯形参数化 Nash 集；光滑满射与双射、边界面像与实体像是不同结论，不能仅靠点云推断拓扑同胚。

- T Example 2.9：3 个标量 agent、各 2 个目标，权重域 `Δ1³` 为 cube，6 个面分 2+4 展示。
- T Example 2.10：agent 状态维数 2+1，目标数 3+2，权重域 `Δ2×Δ1` 为 triangular prism，5 个面分 2+3 展示。
- L acc2024 用 own-row/block 数据求解；P `weightedNashEquilibrium` / `sampleWeightedNashSet` 正确同时加权 M、q，但配置取的是 legacy 符号。P `quadraticFromOwnRows` 补齐非控制方向曲率的做法只可用于该 Nash 几何，不能宣称恢复原始社会福利。
- G `test3_1`、`test5_1` 则对**全四个收益**加权后求集中式最优 `-(ΣwA)\Σwb`；所得为社会 Pareto 集，不是上述逐 agent 权重 Nash 映射。循环包含全零权重导致奇异求逆，其他权重射线也重复。应标识此事实，不把散点集合的视觉重叠当作两种对象相同。

### 2.2 两 agent 标量状态的分段动力学

T (3.8)、E (27)：令 `gij=∂Jij/∂xi`，自身曲率 `aii<0`，BR 是 `gij=0`，有符号距离 `dij=gij/aii=xi-BRij(x−i)`。当 gi1、gi2 同号时选 `|dij|` 最小的目标并令 `fi=αij gij`；异号或任一个为零则 fi=0。BR 之间的 strip 是该 agent 的静止区域，两 agent strip 的交集为 Nash 集。自身贡献 `gij fi≥0`，但总收益导数还含他人的作用。

T 的 tie 使用第一目标 `<=`；E (27) 两个严格比较漏掉 active tie。审计数值核查采用 T tie 规则。注意 α 改变速度；当两个候选在切换线上给出不同速度时，边界数值处理也需要明确，不能将单次 ODE 求解当成一般不连续系统的证明。

L/G 有两类不同实现：

1. `ifac_extention` / `ecc2026` 的 testfun2、2_1、2_2 用 **BR 距离**选择分支，四个 α 输入。
2. cdc2024、acc2025 和 G 的同名 helpers 用 **scaled gradient 绝对值**比较，α11=α21=1，只有 α12、α22 两个输入。当同一 agent 两目标 `αij |aii|` 相等时两规则一致；否则不能互换。trap 就不满足等价条件。

T Chapter 3 的矩阵 `A^{j1j2}` 由两 agent 各取一条 own-row 堆叠；不同于任一完整收益 Hessian。在 general position 及论文相应假设下，四个 determinant 全正对应 compact/stable 情形；全负为不稳定情形，混合符号不能套用这些结论。Assumption 3 是 Nash 集上 own-gradient 向量秩都为 1；Assumption 4 允许一个 agent 秩为 0，产生不同分区/内部拓扑。二维双目标结论不能直接外推 T3.8 的高维/更多目标图。

L ifac2023 / cdc2023 各五个 case 是纯几何/向量场展示，不含 ode45 时间轨迹。按代码行及图形推定 T3.5/T3.6 子图 a,b,c,d,e 对应 case1,2,4,5,3；此对应为有证据的 agent 判断，不是原文件声明。按 (11,12,21,22) 排列的 own-row determinant：

| case | 四个 determinant | 判读 |
|---|---|---|
| 1 | 2.5, 3.5, 2.5, 1.5 | 正 |
| 2 | 2.5, 2.75, 3.5, 3.75 | 正 |
| 3 | −3.75, −2.75, −3.5, −2.5 | 负；应对应 e |
| 4 | 2.5, 2.25, 3.5, 3.25 | 正 |
| 5 | 3.5, 3.25, 1.5, 1.75 | 正 |

两组 BR 截距不同，不可当成重复实验；own-row 不能唯一决定外部收益曲率和线性项。

### 2.3 非双射变换与稳定性证书

E (28) 的 `ηi(x)` 取最近 BR 的 dij，strip 内置零（L `testfun4`；P `coordinateTransform`）。Nash 集映到原点，strip 映到坐标轴：**不是全局可逆坐标变换**。在有效开分支，写 `η=Rx+s`，原动力学为 `xdot=Dη`，因此独立变换系统分支矩阵为 `R D`，不是 `D R`。E 的关键图比较三个对象：原 x(t)、其像 η(x(t))、从 η(x0) 独立积分的 tilde x(t)。后两者在坍缩 strip 及分支切换后可分离；像的欧氏范数亦非处处下降。不能宣称轨迹全局共轭或在轴上任取逆像得到原轨迹。

E (58)–(59)：分片二次函数 `Vj(z)=zᵀPjz`，`Pj=FjᵀTFj`，`Fj=[Ej;I]`；四个 Ej 按 11,12,21,22 为 diag(−,−)、diag(−,+)、diag(+,−)、diag(+,+)。条件为 `AjᵀPj+PjAj+EjᵀUjEj ≺0` 和 `Pj−EjᵀWjEj ≻0`。U/W 是**逐元素非负**乘子，不必半正定；本例 `[0,1;1,0]` 本身是不定矩阵。拉回应使用 `V(η(x))`，不能在跨坍缩轴的“逆网格”间画出虚假连线。

给定 E 的 T 数值和 U=W，上述四个衰减矩阵最大特征值约 −42.276、−20.621、−17.293、−12.669；正性矩阵最小特征值 2.244、8.913、2.733、7.051。独立代数检验支持**这一已给证书**的严格裕量，不代表重新运行 SDP 或证明一般定理。L Solve_lmi 没有实现同一约束集：省略衰减式 EᵀUE，使用非严格约束，未固定 solver；其中 U 定义却未用。不得将其求解输出与印刷 T 自动认作同源。

### 2.4 外部性、Pareto 改进与 trap

T (4.2) 中 Pareto improving 要求所有 i,j 的总导数非负，weakly Pareto improving 要求每个 i 在每个时刻至少一个 j 非负。正文有时称“increase”，定义实际允许常数；本审计避免把“strong”配置名误读为严格正导数定义。

`dJij/dt = gij fi + (∂Jij/∂x−i) f−i`。T (4.3) Ωij 是总导数非负区域；Γij 是外部性项非负区域，故 Γij⊆Ωij。L 的外部梯度零线 Lij 和 BR 可以构造 Γ，但单有 Γ 外的轨迹**不能推出**总收益下降。Ω依赖实际敏感度与完整动力学。正外部性区域的并/交给出弱/全目标改进的充分条件；T4.2 的 invariant neighborhood Nx0 不能用简单任意圆或有限采样轨迹代替。

T Definition 6 的 trap 是存在 t1<t2，使较早的向量收益 Pareto 支配较晚收益（至少一项严格）；不是只比较首尾，也不是某一个收益临时下降。即使每时刻总有一个目标上升，两个不同时间仍可支配逆转。P `trajectoryDiagnostics` 做样本对比较只能提供有限网格见证，未找到见证不是连续时间无 trap 证明。

### 2.5 激励、预算与目标

T (5.5)–(5.29)：只改变 Ji1，Ji2 不可激励。`U=Σηij Jij`，ηij>0，U 严格凹时 target `xhat=−AU\bU`。target 是社会福利最大点，设计要求其属于改造后的 Nash 集；不保证每条轨迹精确收敛到 target。

`Jsum^ω=J11+ω1J12+J21+ω2J22`；Q=Qi=0 的数值例中

`tilde Ji1=ζi σ[U(x)−U(x0)]−ωi[Ji2(x)−Ji2(x0)]+Ji1(x0)`，

`pi=tilde Ji1−Ji1`，`p1+p2=σΔU−ΔJsum^ω`。

ζi>0、Σζ=1；原点锚定是 `pi(x0)=0`，不是令未加常数的收益二次式在 x0 为零。一般式 (5.27) 加中心二次项 Qi，ΣQi=0；Remark 5.2 另有总体 Q 的扩展，不属于现存核心实验。

`D(g,x0)={g≥g(x0)}`，`Dbud={σΔU−ΔJsum^ω≤0}`。预算是瞬时 aggregate transfer 非正，不能改成积分预算、各人都非正或只检验末时刻。T5.2 的 ω 半平面是必要条件图，不能作轨迹充分可行性证明；ω 与保证无 trap 的正权重 λ 概念不同。Theorem 5.4 还需 concavity、general position、所有相关 own-row determinant 正、以及 **Nx0⊆Γ̃1(λ1)∩Γ̃2(λ2)∩Dbud**。只检查有限时刻 pi、target 或 trace/det 不足以认证该定理。

## 3. 参数版本登记

以下 A/b 均按 11,12,21,22 排列；未列出的常数取零只适用于增量与动力学，不能据此恢复绝对收益标注。各版本不得静默混合。

### TOP-C / TOP-P（T2.3、T2.4）

TOP-C paper own-rows：`[-1,0,.4];[-1,0,-.6];[1,-2,.4];[1,-2,-.5];[0,0,-1.5];[0,0,-1]`，own-offsets `[0,5,0,6,0,-10]`。L cube 第二/第四行的末系数是 **+.6、+.5**；又固定 `M=[a11;a21;a31]` 只对 b 加权，这是独立于符号分歧的明确实现缺陷。P 修复加权但保留 legacy 符号。

TOP-P paper：agent1 三组 own-blocks `[-1,0,.5;0,-1,0]`、`[-1,0,.5;0,-2,0]`、`[-1,0,0;0,-2,.5]`，offset `[0;0]`、`[0;5]`、`[6;0]`；agent2 两组 `[-1,.5,-2]`，offset 0、6。L/P agent2 首系数为 **+1**。L prism 同时加权 M/b，不能将 cube 缺陷扩大到 prism。

### PAR（T4.3）

共同矩阵 `AP={[-2,1;1,-3],[-4,-4;-4,-12],[-7,1;1,-2],[-3,-1;-1,-2]}`。

- paper-all：b=`[0,−1.25];[−30,1];[55.5,−5];[24.5,0]`，x0=(0,0)。初始 own-gradients 分别 (0,−30)、(−5,0)，所以 **f(x0)=0 对任意正 α 成立**。满足非下降定义，但不能生成 T4.3(b) 的非平凡增长曲线。
- legacy-all：L cdc2024/test6_4_1 改为 b=`[15,−1.25];[30,−1];[55.5,−5];[24.5,0]`；P 使用此版本。α=[1,.5;1,1]，x0=(0,0)，t≤5。独立核查四个收益增长，不能据此“修正”印刷参数而不说明。
- weak：同 AP，b=`[5,12];[30,0];[−20,0];[20,0]`，x0=(0,3)，α=[1,.5;1,1]，t≤5，L test10_1/2、P。J12/J22 增长，J11/J21 可下降。
- nonweak-paper：A=`{[-4,−1;−1,−3],[-2,−1;−1,−10],[-2,1;1,−2],[-5,1;1,−1]}`，b=`[10,22];[10,78];[8,0];[5,0]`，x0=(7,13)。未找到对应脚本或明确印刷 α。审计使用说明性的 α=[1,2;1,2] 验证 agent1 可同时下降；不是原图精确重现，也未验证原文所说 agent2 后 agent1 的完整次序。

### TRAP / BUD（T5.1、T5.4）

A=`{[-2,1;1,-3],[-2,-1;-1,-10],[-4,1;1,-4],[-5,-1;-1,-2]}`；b=`[5,-5];[20,124];[90,0];[72,0]`；c=(0,0,667.64,561.65)，x0=(18.5,−8.71)。G trap：scaled-gradient 规则，α=[1,1.2;1,2]，t≤4。T5.1 图注 α=[1.2,1.2;1.25,1]，按 T3.8 为距离规则，t1=0,t2=2.75；代码残留未用 t1=.5,t2=3.35，标记代码被注释。

独立核查 legacy 轨迹各 agent 始终有一个采样非负导数，agent2 在 (0,2.75) 的两收益差为 (−1.1132,−.6936)，支持所需 trap。**图注版本** agent2 最佳目标导数最低约 −5.7267，即出现两目标同时下降；(0,2.75) 差为 (−3.3105,+.2153)，不是图注声称的该时间对双下降。两版本末状态差异在步长减半后仍存在，不能归因于积分精度；但审计未执行 MATLAB。

BUD 使用同一游戏，η=(1,3,1,3)、ω=(1,1)、Q=0。图注把 η21 重复写为1和3，结合代码判定第二处应为 η12。预算 Hessian 退化 σ≈.4096591512、.5265853903，与图中 .4097/.5266 一致。G main slider 只在 .3–.6，默认 .5；需覆盖三段及临界点，不能只保存一次滑块图。

### INC-0 / INC-ω（T5.5–6 与补充）

共同 A=`{[-4,1;1,-10],[-4,-1;-1,-3],[-16,8;8,-16],[-5,-1;-1,-2]}`。

INC-0：G test3_*，b=`[5,-440];[30,-20];[360,0];[58.5,0]`，η=(.7,4,1,2)，ω=(0,0)，ζ=(.3,.7)，σ=.05，Q=Qi=0，x0=(16,−15)，t≤3；原 α=[1,1;1,8]，改造 α=[1,.168;1,.6825]。target≈(12.85808,−9.05854)，AU determinant=1739.91。P 自动 inverse-curvature normalization 改变两 agent 相对速度：原 α=[.25,.25;.0625,.5]，与 legacy 并非统一时间缩放，不能对齐有限时间曲线。

INC-ω：G test5_* 与 L acc2025/incentive_deisgn 对应，b=`[5,730];[30,-295];[360,0];[180,0]`，η=(.5,2.5,.5,2)，ω=(1,4)，ζ=(.5,.5)，σ=3，Q=Qi=0，x0=(21,−35)，t≤2；改造 α=[1,10.25;1,14.375]。target≈(20.58333,−15.20408)，AU determinant=735。此为不同游戏/权重的补充实验，不能直接当成只改变 ω 的对照。

### EXT / ECC

E 原矩阵 `A={[-2,-1;-1,-3],[-4,-4;-4,-12],[-7,1;1,-2],[-3,1;1,-1]}`，b=`[8,0];[30,0];[4,0];[12,0]`，α=[.5,.25;5,1]，x0=(6.5,−10)，t≤5，采样间隔 .001。L ifac_extention 后两 b 为(0,0)，仅改非控制方向，**不改动力学/Nash/η，但改变收益**。真实 η(x0)=(−2.5,−13.25)，E 印为(−2.5,−13.5)。T 数值来源 E/原型配置，严格证书检验见 §2.3 与证据 JSON。

L ecc2026 原轨迹另用 A12=[−1,−1;−1,−3]、A21=[−7,−1;−1,−4]、A22=[−3,1;1,−4]，A11 同 EXT；own-offset 8,8,0,0，α=[.25,2;.25,.25]，x0=(2.3,7.9)，t≤30。它不是 EXT 的重复参数，未发现对应本次两论文图，应保留为补充来源，不能混合运行其 image 脚本中重新赋值的 EXT 参数。

## 4. 原始脚本分类与运行障碍

逐文件完整分类由 CSV 覆盖；此表解释成组的工作区契约。所有 MATLAB 执行状态均为**未核实**，以下“自含”仅指静态上定义输入，不保证执行成功。

| 路径（相对 L 或 G） | 用途、输入、输出 | 依赖/风险 |
|---|---|---|
| L ifac2023/case1–5、cdc2023/case1–5 | 内嵌 BR 行/截距 → Nash 几何、streamslice | 无时间轨迹；不能补出完整 payoff |
| L acc2024/cube/test4,4_1,4_2 | 权重网格 → 实体、2面、4面 | 固定 M 缺陷、符号差异；不应按现状作为论文复现 |
| L acc2024/triangular prism/test6,7,7_1 | 权重网格 → 实体/边、2面、3面 | paper/legacy 符号差异 |
| L cdc2024/test6_4_1 / test10_1 | A,b,alpha,x0,tspan → xt、BR/L线、场图 | testfun2；all 版本不同于 paper |
| L cdc2024/test10_2 | xt,t,A,b → payoff 增量 | 需先前工作区；J11 ×5 必须标注 |
| L cdc2024/test6_4_2 | xt,t,A,b 和另设 hJ → hJ/倍乘 J 对照 | 探索性激励，不是独立 T4.3(b) payoff 脚本；不满足已核实设计链 |
| G trap_of_weak_Pareto_improvement/trap | TRAP → 原轨迹、收益/外部性区 | 本目录 helpers；图注 α/规则不一致 |
| G Characterization_of_D_{bud}(sigma)/main | BUD → 可交互预算域等高线 | 图注 eta 笔误；target 标签误作 Jsum 的最大点 |
| G Simulation_results_for_design/test3_1/2/3 | INC-0 → 社会 Pareto 集 / 初值区域 / 双轨迹与收益 | 同目录 helpers；_1 零权重奇异；_3 的 J11,J21,p ÷10 未充分标识 |
| G …/test5_1/2/3 与 L acc2025/incentive_deisgn | INC-ω，同上三类输出 | _3 aggregate p 漏 ω 项；_2 中间区域为普通 Jsum，不是 Jsum^ω |
| L ifac_extention/original_trajectory | EXT → xt、BR、场图 | line70 contour 用未定义 V/levels；干净运行会阻断 |
| L ifac_extention/image_of_original_trajectory | xt,x0,tspan,alpha → η(xt)、独立 xct、变换场 | line18/62 缺 testfun3；先读原轨迹工作区 |
| L …/Solve_lmi | 工作区 A/alpha → T/P 候选 | YALMIP sdpvar/optimize +未固定 SDP solver；不是 E 的完整 LMI |
| L …/level_sets_for_original_transformed_system | T、参数、xct → V/原坐标拉回等高线 | 300² grid，levels30,130,290,520；初值 P0 分支与网格不一致；原/变换坐标轴标签混淆 |
| L …/preimage_of_transformed_trajectory | xct、xt、BR、field 网格 → 逆像叠图 | testfun3_3；不是独立实验；轴上逆像无唯一性 |
| L ecc2026/original_trajectory | ECC → xt/场图 | 静态自含；后续 image 重设参数，不能串接为同一实验 |
| L ecc2026/image_of_original_trajectory | 原轨迹像与独立变换轨迹图 | 直接调用缺失的 testfun3；工作区依赖 |
| L ecc2026/transformed_dynamics_trajectory | 实际将已有 xct 经 testfun3_3 拉回原坐标叠图；没有独立积分 | 依赖上游 xct；image 缺 RHS 使其间接受阻，不能依文件名判断算法 |
| L ecc2026/Solve_lmi、level_sets_for_original_transformed_system | 实际均为 LMI 脚本 | 二者与 ifac Solve_lmi 内容相同；文件名不能证明内容 |

EXT 还形成依赖环：original 绘图先用 V，levels 依赖 T 与 xct，image 依赖 original 的 xt，而变换 RHS 缺失。不能通过同一长时间打开的 MATLAB 工作区偶然留存变量来证明可重复运行。

helper 的两类 RHS 已见 §2.2；`testfun4` 是正向 η；`testfun3_3` 只试若干逆分支，末分支无一致性验证且任何零坐标都返回原点；`testfun1` 是求第二坐标和截距的代数构造，**不是 payoff evaluator**（历史 baseline 对它的描述错误）。所有同名 helper 必须按路径识别，不能递归加整个 source tree 到 MATLAB path。

重复情况：G 三目录的 testfun1/2/2_1/2_2 各自重复；L acc2025 test5_* 与 G test5_* 规范化换行后相同，testfun2 也相同；EXT/ECC 的 testfun2、2_1、2_2、3_3、4 相同。硬编码参数遍布入口；未发现随机种子依赖或外部数据输入，但 GUI/default graphics、path、workspace、SDP solver、ODE tolerance 都是执行环境变量。

## 5. 论文、代码、参数冲突及严重度

| ID | 证据与判断 | 影响/处置 |
|---|---|---|
| C1 | T4.3(b) 参数使 x0 精确静止；legacy/P 有不同 b | 实质实验冲突，作者选择参数版本；两者均保留，不以数值通过消除 |
| C2 | T5.1 图注 distance 参数不再 weak；legacy scaled 参数可展示所需 trap | 实质动力学定义冲突，作者确认用于公开比较的规则/参数 |
| C3 | TOP-C/TOP-P 符号不同；cube 固定 M 违背加权方程 | 分离 paper/legacy 版本，后续修正 cube 算法；无需现在重构 |
| C4 | E η0 印刷错误、b 非控制方向差异 | η0 可直接代数纠正；b 若只画动力学等价，若画收益须明确版本 |
| C5 | E (17) BR 缺负号，(27) tie 缺分支；E p11 衰减推导漏负号，EWE 在轴上不严格正 | 依 own-gradient=0、(28)、T3.8 和数值证书理解；不照抄有误等式，不宣称重建证明 |
| C6 | G test5_3 p 漏 −ω1ΔJ12−ω2ΔJ22 | budget 曲线值错误；必须从 pi 或完整 identity 重算。审计轨迹正确预算仍非正，不能夸大为已发生预算失效 |
| C7 | T3.2/3.4 caption 的 case 指代互换，T3.6 正文把 c 说为 non-Hurwitz 又说 e unstable | 图形/代码 determinant 支持 e；修正文案须显式标注 |
| C8 | T4.2 caption Ω 与正文 Γ 混用；T4.3(a) Γ 外推出收益下降 | Γ 仅充分区域，收益结论必须验证总导数；不得扩张定理 |
| C9 | T5.4 η下标重复；T5.23 严格 <0 与 x0=0 budget 冲突 | 取正文约束 ≤0，eta 由代码/上下文解读(1,3,1,3) |
| C10 | T Chapter6 p72 “bounded case”不能激励成 bounded stable 的无条件措辞，与Chapter5示例冲突 | 可能漏 initially unstable / 不可激励分支条件，需作者确认结论措辞，不直接判定定理错误 |
| C11 | T2 Definition1 非严格关系若含自身会造成退化；堆叠维数/行索引局部笔误 | 按前文 Pareto 支配及 Chapter3 Definition3 解释；不改变模型 |
| C12 | L LMI 与 E 不同、逆映射缺失/不成立，P 证书检查缺条件 | 将“给定证书验算”“求解新证书”“独立变换动态复现”分开记录 |

## 6. 原型覆盖和最重要遗漏

P 的函数实现是可参考的工作成果，但 `reproduce_all` 的四类入口不等于论文完整性：

- `run_topology_examples`：只有 cube/prism 密集 Nash 点云；缺权重域并列图、各面/边的颜色对应、满射/双射区分；保留 legacy 参数而非 paper 版。
- `run_stability_example`：只模拟原系统与 η(xt)。包中有 transformedDynamics 不代表实验独立积分了它；缺 E6 实线/虚线分离、Lyapunov contours、拉回、域映射及十个稳定性案例/非紧案例。变换测试在初始分支验证 chain rule 不能弥补。
- `run_pareto_examples`：包含 legacy-all、weak、trap，但没有 T4.3(a) 的 nonweak 比较；Chapter5 trap 不能替代 Chapter4 nonweak。没有 Γ/Ω 与 Nx0 的区域图；trap caption 版本记录而未实际比较。
- `run_incentive_example`：两条轨迹配的是原 BR；未完整展示改造 BR/Nash 和预算可行域。原 payoff 虽存储却未绘图，只画改造收益/总预算，丢失 T5.6(b/c) 前后对照。遗漏 T5.5 社会 Pareto 集、T5.4 sigma 三段、T5.2/3 omega 机制和 INC-ω 补充实验。α normalization 改变相对速度。
- 数学验证限制：`verifyIncentiveDesign` 的 generalPosition 仅检查跨 agent determinant 非零，漏同 agent 平行/三线共点，且绝对值会接受负 determinant；passes 未完整验证预算、不变域或正 λ no-trap 条件。`verifyLyapunovCertificate` 未检查 U/W entrywise nonnegative，容许零裕量。`transformedBranch` 无候选时仍返回一个 best 候选，`transformedDynamics` 不据 isConsistent 拒绝。因此报告名不能当作 theorem certificate。
- 四个测试类主要核查局部公式/有限采样行为；即便通过也不说明参数来自论文、原有比较齐全或连续时间结论成立。本阶段没有以重跑单元测试替代上述内容核查。

G 自身只覆盖 Chapter5 trap、budget slider、两组 incentive（含社会 Pareto 集），不覆盖 Chapter2拓扑、Chapter3/extension稳定性、Chapter4外部性。因此既不能以 G README 的范围代替整篇论文，也不能让 P 的四个入口限制新仓库范围。

## 7. 独立核查与边界

可复查的 [verify_algebra.py](evidence/verify_algebra.py) 只转录纸面/legacy 参数，用 NumPy 代数与 RK4，未调用或修改 MATLAB/P；[输出](evidence/algebra_checks.json) 保留初始 RHS、末状态、步长减半误差、导数最小值、trap 见证、budget identity 与证书特征值。固定步长 .001 与 .0005；trap 支配搜索容差 1e−7。采样输出用于发现冲突，不能证明全时间性质。

| 核查 | 结果 |
|---|---|
| paper-all | f(x0)=0；精确代数，无积分依赖 |
| legacy-all / weak | terminal≈(7.28777,−.42380)/(3.20723,1.41469)；细分末状态差≈2.77e−7/2.83e−9 |
| trap legacy / caption | terminal≈(13.34639,−6.67693)/(13.37461,−6.71184)，细分差<1.3e−9；性质差见 §3 |
| INC-0 | sampled aggregate budget 范围 [−186.8302,0]；有限时终点(13.23989,−9.11120)非 target |
| INC-ω | 正确 budget 范围 [−12874.0754,0]，旧图公式 [−15031.1013,0]，最大差2157.0259 |
| sigma 临界值、EXT eta0、证书 | 与 §2–3 中代数结果一致 |

MATLAB R2025b 安装存在，用户已打开。当前工具无已连接 MATLAB 会话；一次 sandbox CLI 尝试无诊断退出，后续外部启动许可未获批准，未再尝试绕过。因此没有 clean-session MATLAB、YALMIP 或 SDP solver 成功运行证据。历史 baseline 中“未安装 MATLAB”不再作为现状。缺 helper/workspace 等阻碍来自静态直接证据，与安装状态无关；不阻碍完成 Phase 0。

## 8. 验收与后续

| Phase 0 验收项 | 证据 |
|---|---|
| 每个相关论文实验均有去向 | FIGURE_MANIFEST 29图、非图正文案例与补充实验；缺源码项不静默省略 |
| 每个重要 legacy 脚本有分类 | script_classification.csv 的65/65文件及 §4 |
| 每个拟公开图说明比较 | manifest 各图行与核心比较分组；网站最终选图尚未决定 |
| prototype 遗漏明确 | §6 与 manifest 对照列 |
| 测试不替代科研完整性 | §6–7 的分层证据与运行限制 |

Phase 0 事实审计与最终交叉核查完成。136个输入文件哈希全部保持一致，65个legacy文件分类齐全，29幅论文图全部登记，见 evidence/final_integrity_check.json。仍待作者决定的是 C1/C2 的公开实验定义和 C10 结论措辞。其他缺图可按 brief 允许的“新参数但保留数学比较”规划，不据此省略实验。Phase 1 建议先冻结经审阅的实验登记与纸面/legacy参数版本，再修复最小可运行实验和结果证据；具体公共 API、MATLAB 结构、网站终选均未设计。参见 `../OPEN_QUESTIONS.md`、`../DECISIONS.md`。本次只提交审计与记忆，停在阶段审阅边界。
