# 阶段A：首次读者记录（已冻结）

日期：2026-09-19
角色：首次接触项目的研究读者、科学编辑与图形评审者（同一AI的模拟首读，不是真实用户实验）
冻结点：在阅读项目内部完成报告、论文、数学证据和结果文件之前。

## 方法与污染声明

实际阅读顺序如下：

1. `AGENTS.md`；
2. `audit/reader_review/SESSION_PROMPT.md`；
3. `audit/reader_review/REVIEW_BRIEF.md` 的工作边界与交付规则；
4. 根目录 `README.md`；
5. `README.md` 所列六个 `experiments/run_*.m` 入口的文件名和开头用途注释；
6. `audit/implementation/figures/` 的18张PNG，按 T1、S1、S2、P1、X1、I1 分组，逐张以完整图打开。

流程有一个必须保留的限制：读取任务书时，工具输出意外包含了原应留到阶段B的研究核查表；项目记忆摘要也已暴露少量术语和结论边界。因此这不是严格盲读。以下记录不借内部报告补图，只写从 README、入口名、函数开头注释和图内文字能够直接得到或仍需猜测的内容。后续核查只能追加“阶段B更正”，不能改写本节。

## 30秒入口印象

我能知道这是一个“vector-payoff games”的 MATLAB 研究重建，主题横跨 Nash 集合、稳定性、收益性质、坐标变换和激励设计；但我仍不知道一个 vector-payoff game 与普通博弈相比多了什么、为何值得研究、六个入口怎样组成一条论证链，以及作者最重要的研究认识是哪一句。

README 没有展示图、概念例子、论文引用或可复制运行命令。它把新读者首先指向 `PROJECT_STATE.md`、figure manifest 和 R1 verification review；因此若坚持不进入内部审计层，我无法从入口建立研究故事。函数名可定位代码，却不能告诉我依赖、启动目录、预计时长、输出位置或哪张图对应哪个入口。

我对作者希望我记住的内容的初步猜测是：多目标权重会把权重域映射为 Nash 集；该集合的几何与分段动力学影响稳定性、收益改善、变换和激励设计。但这主要是由六个模块名拼出来的，不是 README 直接讲清的。

## 逐图组首读

### T1：权重域、Nash像与应用

实际打开：`T1_cube_face_correspondence.png`、`T1_prism_face_correspondence.png`、`T1_production_pollution.png`、`T1_nonquadratic_schematic.png`。

- 我认为问题是：权重参数空间的面、边、点如何对应到一个 weighted Nash image，以及该结构在生产—污染控制例子中长什么样。
- cube/prism 两张图直接给出左右两个三维对象，并声称所有面、边、顶点对应；相同顶点标签帮助配对。不过视角遮挡和半透明叠层使若干面难以逐一核实，图例只解释面条件，不解释映射机制，也没有箭头或配对表。读者能看到“结构被带过去”，但难以仅凭图证明“all ... correspond”。
- 生产—污染图最容易找到入口：红/蓝是两位agent针对 profit/environment 的 BR，紫色是 weighted Nash image，标题明确警告它不是集中式 social Pareto set。仍缺的是 BR 的全称、为何四条边界的交集填出紫区、坐标是否无量纲，以及这对污染问题意味着什么。
- nonquadratic 图明确标为 schematic only，紫色弯曲区域被红蓝零集夹住；它能传达“非二次时集合可弯曲”，但没有图例、轴、映射前后对照，也无法判断它在研究链中是结论、直觉还是占位示意。
- 猜测的记忆点：权重域的组合结构可能保留在 Nash 像中，且 Nash 像不是社会Pareto集合。不能从图推出映射双射的条件或一般定理，也不能把示意曲线当作某个数值模型结果。

### S1：五类稳定性

实际打开：`S1_five_case_overview.png`、`S1_eigenvectors_transitions.png`。

- 我认为问题是：相同类型的分段博弈动力学为何出现四种稳定行为和一种不稳定鞍点行为。
- overview 的红/蓝 BR、紫色 Nash set、黑色多条轨迹和淡蓝向量场有内嵌说明，五个 case 的相对位置可比较；但 `stable-CW`、`stable-real`、`stable-CCW`、`stable-mixed` 没有定义，黑轨迹的时间方向只靠小黑点/曲线形状难辨，红色“不稳定代表轨迹”与红色 agent 1 BR 共色。
- eigenvectors 图把锥形区域、灰色特征方向、红色射线/箭头放在四个面板中，标题含 0/1/2-transitive 与 branch 编号。作为首次读者，我几乎不能从图内解释 transitive 的含义、为何某条特征射线在锥内会导致切换或退出、它与五case总览中哪条轨迹对应。
- 猜测的记忆点：稳定性不能只看终点，而要看分支特征结构和跨区域转移。不能从几条轨迹推出全局稳定，也不能仅从 `stable-*` 标题理解分类判据。

### S2：退化与非紧边界

实际打开：`S2_rank_degenerate_five_cases.png`、`S2_noncompact_three_configurations.png`。

- 我认为问题是：原来的五类行为在 rank-degenerate 情况下是否仍可分类，以及非紧 Nash 集会出现哪些几何形态。
- rank-degenerate 图保留红/蓝 BR、紫色集合、黑轨迹，并用金色星标出 rank-zero Nash pinch；文字明确说有限窗口不是紧致性的证明。这一限定有效，但 `rank-zero`、`pinch`、determinant signs、Theorem 3.11 均未在入口定义，紫色集合在部分面板很窄且难找。
- noncompact 三图的 funnel/wing 命名有视觉记忆点，标题列 determinant 数组，面板内直接写 `noncompact by Prop. 3.1 (mixed signs)`。首次读者不知道数组四项对应什么，也不能从窗口内截断的紫区看出无界；结论事实上依赖未链接的命题而不是可见图形。
- 猜测的记忆点：退化并不消灭稳定性分类，mixed determinant signs 可给出非紧集合。不能把裁剪窗口或少量轨迹当成非紧性/稳定性证明。

### P1：收益性质、分解与trap

实际打开：`P1_three_payoff_properties.png`、`P1_rate_decomposition.png`、`P1_weak_pareto_trap.png`。

- 我认为问题是：沿动态路径，各agent的多个收益能否同时改善；总变化如何拆成自身贡献与外部性；“weak Pareto trap”展示跨时刻的局部改善为何可能误导。
- 三性质九宫格把 phase、payoff changes、total derivatives 并排，行标题写 nonweak / all objectives nondecreasing / weak but not all；这是明确的比较框架。但没有坐标轴标签/刻度、初值终值、Gamma/Omega定义；首行只看中图似乎只有三条曲线，顶部虽列四个收益颜色，重合关系不明。
- rate decomposition 标题给出 `total rate = own contribution + externality`，每格脚注解释粗线/细线/灰线，概念上很重要；但曲线密集、无坐标标签、同色线靠粗细区分，在约900px时难判断哪项造成符号改变，也看不出它与上一图哪一格一一对应。
- trap 图左侧给路径与失效区域，中间标两个时刻和 agent 2 两个收益的变化，右侧给 total/own/externality。红色文字 `Delta J2=[...]` 最接近读者可复述的结论；但 `t1=0.020; t2=1.819` 为什么被选、两条数值对应哪两个目标、trap 的判定逻辑仍需说明。
- 猜测的记忆点：总收益导数含外部性，因此只看agent自己的更新方向会错判全体收益变化；弱性质不能替代逐目标或跨时刻检查。不能从这三条新例子推断论文原图被精确复现，也不能把trap自动当作 nonweak 的证据。

### X1：非双射变换与稳定性

实际打开：`X1_domain_map.png`、`X1_fiber_collapse.png`、`X1_trajectories_lyapunov.png`。

- 我认为问题是：一个非双射坐标变换如何把二维区域、条带、Nash集压缩为象空间的象限、轴和原点，以及在原空间/变换空间分别积分时稳定性信息如何比较。
- domain map 左右面板标题已经给出 2-D domains→quadrant subsets、strips→axes、Nash→origin；但颜色多且主要靠颜色对应，右图纹理过密，`D^(i,j)` 未定义，读者无法知道为什么不同原区域会重叠。
- fiber collapse 用同色空心点标出一条fiber上的多个 x，并在右图压成轴上一点；“inverse on an axis is set-valued; no representative is selected”很清楚，是本组最自解释的图。仍缺 κ、fiber 与各 D 标签的入门定义。
- trajectories/Lyapunov 明确区分 solid `eta(x(t))` 与 dashed independently integrated `z(t)`，也明确说 norm 短时增加不等于不稳定；但四面板信息负担很高，A/B separation segment、mapped one-active segment、V certificate 的关系需正文引导。若只看右上图，容易把两条曲线的差异误读成数值误差或“变换失败”。
- 猜测的记忆点：多对一变换丢失状态信息，点态映射轨迹与独立变换系统轨迹不是同一对象；稳定性要看证书而非欧氏范数单调。不能把坐标变换说成稳定化控制。

### I1：激励几何、预算与前后比较

实际打开：`I1_design_geometry.png`、`I1_sigma_budget.png`、`I1_before_after.png`、`I1_INC_omega.png`。

- 我认为问题是：通过修改某类收益把动态引向目标，同时检查社会福利域、预算域和转移成本；sigma/omega 控制不同几何要素。
- design geometry 四面板把社会Pareto vs Nash、target/domains、同一游戏的 omega 边界变化、激励前后轨迹放在一图，研究链完整但跨度过大。左上绿色点云、四色直线无图例；右上 D(U,x0)、D(Jsum,x0)、Dbud 未定义；读者也不知道 target 为什么可选。
- sigma 图清楚展示 interior ellipse→hyperbola→exterior ellipse 的拓扑变化，并另列 ACC-style 比较；但上下两行似乎使用不同集合/补集 convention，`common exclusion identity`、阴影代表允许还是排除均无法从图内稳定判断。公式字符在900px下很小。
- before/after 图的左上轨迹是直观核心；另外三图的原收益、改后收益与 aggregate transfer 很重要，但四个 J 的上/下标、哪类收益被修改、黑线预算正负的规范都没有入口解释。量级差异让若干曲线贴近零线，看图难比较。
- INC-omega 标题明确警告这是不同游戏、不是单因素 omega 控制；右下还对比完整预算与遗漏omega项的旧公式，限定非常有效。作为公开精选图却过于审计化：数值量级大、公式标签密集，若没有正文会让读者把“纠错”误当项目主贡献。
- 猜测的记忆点：激励能改变到达目标的行为，但必须同时报告原收益、修改后收益和完整预算；sigma改变预算边界拓扑，omega比较需区分同一游戏与另一个补充实验。不能从图断言当前数值例子满足所有定理前提，也不能把不同游戏的结果归因于omega单因素。

## 跨图首读障碍（冻结判断）

1. **入口缺研究问题与主张。** README 给模块名和审计链接，却没有“普通博弈→向量收益→Nash集合→动力学/设计”的最小概念链。
2. **图存在，但仓库入口看不到。** 18张图没有从 README 形成画廊、代表比较或caption；读者必须猜目录。
3. **符号层级缺口大。** `BR`、`X*(J)`、`D^(i,j)`、Gamma/Omega、own/externality、sigma/omega、J上下标均未在面向读者入口定义。
4. **多张图把结论写进标题，但证据关系未解释。** “all correspond”“stable”“noncompact”“certificate”等需要正文给条件与证据层级，不能靠标题自证。
5. **运行路线不可复制。** 只有函数名，无启动目录、路径初始化、命令、输出位置、依赖/版本与“哪条命令得到哪张图”。
6. **公开叙事与内部审计混在一起。** 边界警告普遍认真且必要，但首屏缺正面动机与贡献；新读者被迫先读状态/审计材料。
7. **桌面全分辨率尚可，正文缩放不稳。** 多数2×2、3×3、五面板图在约900px宽度会丢失标签和曲线差异；390px手机若不拆图/提供分面导航，主要只能读标题。

## 首读时认为最有效的图

- `T1_production_pollution.png`：问题语境最具体，Nash与社会Pareto的边界警告清楚。
- `X1_fiber_collapse.png`：一个多对一变换如何丢信息可以从左右配对直接讲清。
- `I1_before_after.png` 左上面板：原轨迹与激励轨迹的行为差异直观；完整四面板适合技术层，不适合直接做主页首图。
- `P1_weak_pareto_trap.png` 中间面板：若补足时刻选择与符号定义，可以形成具体的“局部/跨时刻判断”故事。

## 冻结声明

以上为阶段A记录。下一阶段将核对真实研究含义、来源、参数、结果结构、论文依据和公开可取得性；任何发现将单列为“阶段B更正”，不回写本节为“一开始就看懂”。

## 阶段B更正（不改写上述首读）

- 六组不是并列图册，而是 topology → stability/boundaries → payoff/externality → non-bijective transformation → conditional incentive design 的研究链。
- T1 cube/prism 的结构结论由 paper theorem/regularity conditions 支撑，采样与图只是实现诊断；production 紫区确为 weighted Nash image，不是 social Pareto。
- S1/S2 case 身份来自斜率、全部分支矩阵、特征结构、active cones 与定理假设；S2 noncompact 由 mixed determinant signs 与 Proposition 3.1 认证。
- P1 前三组是新 exact comparison family；trap 才使用作者确认的 legacy scaled-own-gradient 规则。tracked P1 图是独立渲染，R1 pack 中另有 MATLAB 原生渲染，不能混标来源。
- X1 的 `x(t)`、逐点 `eta(x(t))` 与独立积分 `z(t)` 是三个对象；paper printed `eta0` 与 norm inequality 的差异已在当前报告中明确处理。
- I1 已核对锚定、预算恒等式、多项代数条件与数值轨迹，但完整 invariant-set containment 未证明；强证书失败不能推成一般不可实现。
- 18 张提交图在 Git 中；18 张 R1 clean 图、21 个 clean 非图结果、三篇 PDF 与 legacy/reference 都被忽略，新 clone 不可取得。README 不能把这些本地材料当公开交付。
- 实际 1100/900/390px 静态缩放检查确认：单图与少量双联图在桌面可读；六/九宫格在900px接近下限，390px须拆分。该检查不是浏览器用户测试。
