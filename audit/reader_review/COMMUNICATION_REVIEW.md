# 独立读者理解与对外传播准备度审阅

日期：2026-09-19
范围：README、六个科研入口与 R1 整合入口、18 张提交图、18 张 R1 干净 MATLAB 图、21 个干净非图结果、32 个 figure-manifest 条目、M0–R1 报告、作者决定和三篇论文。
性质：研究读者/科学编辑/图形评审；不是重新证明论文，也不把同一 AI 的模拟首读称为真实用户研究。

## 结论先行

科研实现已经形成一条可审计的完整链条；公开传播尚未形成一条可独立阅读和安全复现的链条。二者不能互相替代。

- **科学实现完成度：高。** T1–I1 的参数身份、分支规则、诊断、图和限制在代码、CSV/MAT、任务报告与 R1 中相互对应；撤回的 Q1 数组没有进入当前实验入口。六个实验在 R1 中由独立 MATLAB 进程运行，R1 再以第七个进程整合。
- **GitHub 传播准备度：未达到可直接发布。** README 只有模块清单，没有研究问题、概念链、图、术语、可复制命令、输出映射、引用或许可。新 clone 也拿不到 `results/`、论文或 R1 审阅包。
- **个人主页传播准备度：有强素材，但尚未形成精选叙事。** `T1_production_pollution`、`X1_fiber_collapse`、`P1_weak_pareto_trap` 的中间比较、`I1_before_after` 的轨迹面板都能承担短叙事；多面板原图不能原封不动承担手机端首屏。
- **没有发现需要改科研参数才能修复的当前传播错误。** 主要工作是建立解释层、明确来源层级、提供安全运行入口、拆分/重排图。真正需要作者决定的事项仅是许可、公开引用/论文链接权利、主页终选以及 P1 对外权威渲染版本。

## 审阅方法与覆盖

1. `FIRST_READ.md` 在内部审计、论文和结果解释之前冻结；任务书意外提前显示阶段 B 清单的污染已如实记录。
2. 18 张提交图逐张以原分辨率打开；另用 macOS `sips` 生成 1100、900、390 像素宽副本并逐张打开。这里是静态缩放检查，不冒充浏览器响应式测试。
3. 18 张 R1 图逐张原分辨率打开并与提交图对应。T1/S1/S2/X1/I1 的差异主要是渲染尺寸/元数据；P1 提交图是独立渲染版，R1 是 MATLAB 原生版，视觉和图例结构有实质差异。
4. 21 个干净非图产物均检查。CSV 核对表头、行数、代表首尾值和关键 margin；MAT v5 文件解析顶层尺寸与 struct 字段，并以 CSV/报告核对必要数值，不以文件存在代替读取。
5. 32 个 manifest 条目逐项与 `r1_coverage.csv` 和实际交付对应。合并交付、示意图、讨论性处置与数值图没有混成“32 张复现图”。
6. 三篇 PDF 做全页文本提取并阅读，关键公式/图页另行渲染检查上下标和版面。特别确认 `J_j^i` 的上标是 agent、下标是 objective。
7. 没有全量重跑 MATLAB；本轮没有发现需要通过再次运行才能回答的具体缺口。MATLAB 可执行文件确认为 `/Applications/MATLAB_R2025b.app/bin/matlab`。

逐项记录见 `REVIEW_INVENTORY.csv`。

## 阶段 A 与阶段 B 的差异

| 首读判断 | 科学核查后的准确解释 | 传播后果 |
|---|---|---|
| 六组像平行实验 | 它们是一条链：权重域与 Nash 集合 → 分段动力学与边界 case → 收益/外部性 → 非双射变换 → 有条件的激励设计 | README 应按问题链组织，函数清单降为导航 |
| 图中的稳定/非紧似乎来自轨迹 | S1 身份来自斜率、20 个分支矩阵、特征结构、active cones 与定理；S2 非紧来自混合行列式符号与 Proposition 3.1 | 轨迹只作说明；caption 必须就近给证据层级 |
| 紫色区域可泛称 Pareto 区域 | T1 紫色是 weighted Nash image；I1 才有单独的 social Pareto samples | 所有公开 caption 必须避免把 Nash 与社会 Pareto 混称 |
| payoff 图中的导数可视为 agent 自己的梯度 | full gradient、own-direction contribution、selected pseudo-gradient 和 total payoff derivative 是不同对象 | 必须有一张符号/分解小图或公式 |
| trap 是 nonweak 的另一个例子 | trap 使用实际 legacy scaled-own-gradient 规则，证明目标是跨时刻退化；它不替代 nonweak case | P1 三类新构造与 legacy trap 必须分段说明 |
| X1 两条变换空间曲线只是数值误差 | `eta(x(t))` 是逐点评价，`z(t)` 是独立积分；非双射轴上没有选代表逆像 | 这是研究要点，应提升 `fiber_collapse` 的公开优先级 |
| I1 图说明数值实例满足完整定理 | 当前例验证许多代数项和轨迹/预算观测，但未证明完整 `N_x0` 包含；强 `D(U)⊂D_bud` 失败只否定该证书 | 公开文案只能说“observed/checked under listed conditions”，不能写“the theorem guarantees this run” |

## 逐图组评审

### T1：权重如何生成 Nash 集合

**应传达的一句话：** 向量收益没有预设唯一权重，因此权重域会生成一整个 Nash 集合；在满足论文秩/可逆条件时，面、边、顶点的结构被映射过去。

| 图 | 读者应看哪里 | 能得出的结论 | 不能推出 | 最小有效修改 |
|---|---|---|---|---|
| `T1_cube_face_correspondence.png` | 左右相同 `C1…C8` 和同色面 | cube 的六面/边/顶点有明确对应 | 不能由点云或这一视角证明全局双射 | 加一条 `weight → solve M(w)x+b(w)=0 → Nash point` 箭头；图旁链接对应 CSV；caption 写定理条件 |
| `T1_prism_face_correspondence.png` | `P1…P6` 与五个面条件 | prism 也保留组合结构 | 不能把遮挡面当作已视觉核实 | 增加 2D 面—面索引表或交互/分面小图；移动图例避免视图外侧 |
| `T1_production_pollution.png` | 紫区与四条 profit/environment BR | 应用中的 weighted Nash image | 不是集中式 social Pareto set | 保留标题警告；在正文先定义 BR 与两轴单位/无量纲约定；作为 GitHub/主页首选 |
| `T1_nonquadratic_schematic.png` | 红蓝曲线围成的紫区 | 非二次 own-gradient 零集可形成弯曲图像 | 不是某个来源模型的数值结果 | 只放概念/限制小节；caption 首句写 schematic；不与前三图并列为同等级复现证据 |

900/1100 px 下生产图和 schematic 可独立阅读；cube/prism 顶点与图例需放大。390 px 下只有生产图的轮廓仍可讲，cube/prism 必须拆图或点击放大。

### S1：为什么同一类系统会稳定或不稳定

**应传达的一句话：** 五种行为由 BR 斜率排序、四个 active branch 矩阵、特征方向是否留在 cone 内以及域转移共同决定；轨迹只是代表。

| 图 | 读者应看哪里 | 能得出的结论 | 不能推出 | 最小有效修改 |
|---|---|---|---|---|
| `S1_five_case_overview.png` | 前四紫区附近轨迹收敛，对比 Case 5 红 witness 外出 | 四稳定、一不稳定的认证 case 总览 | 不能靠终点或五条截图推广到所有参数 | 给每个 case 加一行判据徽标：slope order / det sign / active eigenray；红 witness 改用与 agent-1 BR 不冲突的线型 |
| `S1_eigenvectors_transitions.png` | cone 内特征射线和 0/1/2-transitive 标题 | branch 特征方向与出口数量相关；Case 5 正特征射线持续 active | 不能把坐标变换说成稳定化 | 图旁先定义 transitive；加方向箭头与和 overview 的 case 链接；建立灰/黑/红的图例 |

1100 px 可读，900 px 需要正文解释；390 px 只能看出“五格/四格”，无法读出判据。适合仓库技术层，主页只用简化五格总览或单个稳定/不稳定对照。

### S2：rank-degenerate 与 noncompact 边界

**应传达的一句话：** Assumption 4 的 rank-zero pinch 仍可按五类判定；混合 determinant signs 则产生不满足同号假设的非紧几何，有限窗口本身不是证明。

| 图 | 读者应看哪里 | 能得出的结论 | 不能推出 | 最小有效修改 |
|---|---|---|---|---|
| `S2_rank_degenerate_five_cases.png` | 金色 rank-zero 点、紫集、Case 5 红 witness | 新构造覆盖四 stable 与一 unstable | 不是 thesis 参数逐像素复现 | 正文并列定义 Assumption 3/4；caption 将“新构造”提前，减少右侧小字 |
| `S2_noncompact_three_configurations.png` | 各面板 mixed determinant 数组与紫色 recession wing | N1–N3 满足 analytic mixed-sign certificate | 不能从裁剪窗口看到“无穷远” | 用箭头标 recession direction；caption 首句引用 Proposition 3.1 的判据，轨迹降为插图 |

该组不是主页基线，但 noncompact 三联图可作为“边界条件为什么重要”的扩展。390 px 必须逐面板拆开。

### P1：收益是否真的改善

**应传达的一句话：** agent 朝自己的选定目标移动，不等于所有 payoff 都增加；总导数等于 own-direction contribution 加 externality，弱性质还可能存在跨时刻 trap。

| 图 | 读者应看哪里 | 能得出的结论 | 不能推出 | 最小有效修改 |
|---|---|---|---|---|
| `P1_three_payoff_properties.png` | 三行从 nonweak → all → weak-not-all 的相同列结构 | 新构造隔离三种 payoff 性质 | 不是 thesis Fig. 4.3 精确参数 | 对外版使用真实坐标/时间标签；在每行写一条逻辑判定而非只写颜色；解释重合曲线 |
| `P1_rate_decomposition.png` | total/own/externality 的符号如何相加 | externality 可改变 total rate 的符号 | 灰线不是第三种动力学 | 增加全局图例和零线标签；减少同一 panel 的曲线数，或按目标分两页 |
| `P1_weak_pareto_trap.png` | 中间面板 `t1<t2` 的两个 payoff 均下降，右图给原因分解 | 当前 legacy 规则上存在跨时刻 trap witness | finite grid 不是连续全时证明；trap 不等于 nonweak | 明确两数分别对应 `J_1^2,J_2^2`；把选取时刻理由写入 caption；保留 finite-grid 限定 |

版本结论：提交版 P1 是独立渲染器，900 px 更整洁但缺刻度/轴；R1 MATLAB 版有轴、图例和标准 provenance，却在多线图中更拥挤。当前远端只能得到提交版，不能把它称作 clean MATLAB 图。推荐后续以 MATLAB 数据/入口为权威重新做一套 tracked public figures，保留提交版的分组结构和 R1 版的轴/图例；在完成前，提交版可用，但 caption 必须标明独立渲染与验证来源。

### X1：非双射变换会丢什么

**应传达的一句话：** 二维区域可被压成象限子集，条带压成轴，Nash 集压到原点；因此逆像是集合，`eta(x(t))` 不能与独立积分的 `z(t)` 混为一谈。

| 图 | 读者应看哪里 | 能得出的结论 | 不能推出 | 最小有效修改 |
|---|---|---|---|---|
| `X1_domain_map.png` | 左侧 `D^(i,j)` 与右侧象限/轴标签 | 局部窗口的域映到特定象限子集或轴 | 不是整个象限的满射 | 加四种域含义表；右图减弱点纹理并用形状/边界辅助颜色 |
| `X1_fiber_collapse.png` | 左侧同色多个 x 压成右侧一个轴点 | 非双射信息损失和 set-valued inverse | 没有选取一个代表逆像 | 升为公开主图；把 `kappa` 定义放进 caption；为手机拆成上下两图 |
| `X1_trajectories_lyapunov.png` | 右上 solid 与 dashed 分离，下面 norm 与 V 的不同角色 | pointwise image 与 independent trajectory 不同；norm 暂增不等于不稳定 | 变换不是控制器，不能“稳定化”原不稳定系统 | 按 1→2→3 阅读顺序编号；将 A/B separation 单独做 inset；caption 解释 V 是证书对象 |

`fiber_collapse` 是整套项目中最强的“方法限制”解释图，建议从 repository-support 提升为主页候选；这仍是编辑推荐，不是作者终选。

### I1：有条件的激励设计

**应传达的一句话：** 只修改每个 agent 的第一类 payoff，通过 target、omega、sigma、初值锚定与 aggregate budget 协同设计；数值例展示行为和预算，但没有补齐完整 invariant-domain theorem certificate。

| 图 | 读者应看哪里 | 能得出的结论 | 不能推出 | 最小有效修改 |
|---|---|---|---|---|
| `I1_design_geometry.png` | social Pareto vs Nash、同一游戏 omega 对照、前后轨迹 | target 与 Nash geometry 不同，omega 移动边界 | 不能把绿色 social Pareto 点云叫 weighted Nash | 加跨四面板编号和一句流程；左上补图例；先定义 target/omega |
| `I1_sigma_budget.png` | 上排 ellipse→hyperbola→exterior ellipse；下排 common exclusion | sigma 改变预算边界拓扑 | 强证书失败不等于设计一般不可能 | 统一 `D_bud` 与补集阴影 convention；修正底部 raw formula 字符；把 common exclusion 放 caption |
| `I1_before_after.png` | 左上黑/紫路径，右下黑色 aggregate transfer | 行为改变，同时报告原 payoff 与总代价 | 终点不等于 target；不能称为完整 theorem guarantee | 左上可作主页裁剪；技术版保留四格并在 caption 给 terminal distance 和预算符号约定 |
| `I1_INC_omega.png` | 标题的 different-game 警告与右下旧/完整预算差异 | omega 项不可从预算恒等式遗漏 | 不是 same-game one-factor comparison | 保留在仓库审计/补充层，不作主页主图；caption 先说明为何存在该 supplement |

1100 px 可读，900 px 的六格 sigma 与四格设计已经接近下限；390 px 所有 I1 组合图都应拆成单面板卡片。

## 公开仓库可取得性与复现路径

### 当前 clone 实际拥有

- 六个科研入口、R1 整合入口和 T1 配置；
- 18 张 `audit/implementation/figures/` 提交图；
- M0–R1 报告、manifest 与提交 CSV；
- 不拥有 `source_material/`、`reference/`、`results/`、R1 review pack、三篇 PDF 或 21 个干净非图结果。

因此，下列表述目前不能出现在 README：

- “打开 `results/r1/...` 查看验证包”；
- “三篇论文随仓库提供”；
- “提交图全部是本次 clean MATLAB 输出”（P1 不是）；
- “运行默认 T1/I1 即可安全复现到 `results/`”。T1 与 I1 的第二个默认输出目录是 tracked `audit/implementation/figures/`，会覆盖提交图。

### 当前代码入口的实际行为

- MATLAB 函数位于 `experiments/`，从仓库根目录运行前需要 `addpath('experiments')`。
- S1/S2/P1/X1 接受一个 `outputDir`，默认写 `results/<task>`。
- T1/I1 接受 `outputDir,auditFigureDir`；若省略第二项，会写入 tracked figure 目录。这对维护者合理，对首次复现者不安全。
- R1 入口只验证并打包已有 clean-run roots，不负责启动六个实验；它不是新读者的一键入口。
- 现有 README 没有 MATLAB 版本、命令、预计产物、参数位置、失败诊断或输出—图映射。

## 优先问题清单

| ID | 优先级 | 具体证据与可能误读 | 最小有效修改 | 验收 |
|---|---|---|---|---|
| CR-P0-01 | P0 | README 宣称六个 reproducible entries，却无命令；T1/I1 默认会覆盖 tracked figures | 新增安全 wrapper/文档，所有 public runs 显式写 `results/public/...` | 新 clone 从根目录一条命令/一组复制命令生成六组输出且 `git status` 不变 |
| CR-P0-02 | P0 | `results/` 与论文被忽略，但内部报告大量引用本地路径 | README 明确 public/local 分层；把必要小型参数/结论表以 tracked 文档或链接呈现 | 所有公开链接在 clone 中存在；无链接指向被忽略路径 |
| CR-P0-03 | P0（发布门槛） | 根目录无 LICENSE/CITATION，README 无正式论文引用 | 作者选择许可并确认可公开论文链接；添加引用元数据 | GitHub 页面能回答“如何引用/能否复用代码”；不擅自选许可 |
| CR-P1-01 | P1 | README 让读者先读 PROJECT_STATE/AUDIT 才能理解 | 写 public-first README：问题、贡献、概念链、代表图、结果、复现、证据边界 | 30 秒能说出研究问题，3 分钟能讲出六组链条 |
| CR-P1-02 | P1 | `J_j^i`、BR、`X*(J)`、`D`、Gamma/Omega、sigma/omega 未在入口定义 | 增加一页符号与动态图解 | 不读审计报告即可区分 agent/objective、own/externality/total |
| CR-P1-03 | P1 | 18 图无 README 入口/caption/alt text | 建立分组画廊和逐图 caption，正文只放代表图 | 每图都有一句主张、证据层级、不可推出项与 alt text |
| CR-P1-04 | P1 | P1 tracked 独立渲染与 R1 MATLAB 渲染可能被混称 | 选定对外 authority，或明确双来源；优先 MATLAB 数据驱动重制 tracked 版 | 图注能追到入口和数据；有轴/刻度；不称独立渲染为 clean MATLAB |
| CR-P1-05 | P1 | I1 容易被写成“数值例已满足定理全部条件” | 在图旁分列 algebra checked / trajectory observed / invariant containment unproved | 文案不越过 Theorem 5.4/论文 Theorem 2 的条件 |
| CR-P2-01 | P2 | 900/390 px 多面板符号不可读 | 仓库保留完整图；另导出单面板/两面板 public derivatives | 900 px 可读主结论；390 px 每卡只承载一个比较 |
| CR-P2-02 | P2 | 颜色常是唯一编码，S1 红线有角色冲突，X1 纹理密 | 加线型/标记/直接标签，修复角色冲突 | 灰度或色觉受限时仍能辨认主要比较 |
| CR-P2-03 | P2 | 标题塞满结论/限制，caption 缺失 | 标题只命名比较；解释和限制移入紧邻 caption | 图内不过载，限制又不离开证据位置 |

## 应保留的有效做法

- 多处图标题主动写出“not social Pareto”“schematic only”“finite window is not a compactness proof”“different game, not a one-factor control”，这些边界应保留。
- R1 index 把每张图的 repository role、website status 和 claim boundary 分开，是形成公开 caption 的好原料。
- X1 明确区分 solid pointwise image 与 dashed independent integration，I1 明确展示 aggregate transfer，P1 明确分解 own/externality/total；这些是研究精髓，不应为了简洁删掉。
- S1/S2 保留不稳定和 noncompact 边界 case，使仓库不只展示“成功例”。主页可以精选，但仓库不能因此删减范围。

## 需要作者决定的事项

1. **代码许可。** 这是权利/发布选择，编辑不能代选。
2. **正式引用与公开论文链接。** 需要确认期望的 citation 文本、DOI/公开版本及 PDF 展示权；本地 PDF 不应自动发布。
3. **主页终选。** 推荐新增 `X1_fiber_collapse`，并把 S1/S2 放扩展层；最终仍由作者决定。
4. **P1 对外 authority。** 推荐以 MATLAB 入口和 clean result 为数值 authority，重做一套 tracked public rendering；作者需确认是否保留现有独立渲染作为历史/解释版。

除此之外，没有发现必须由作者裁定的新科学冲突。论文/旧材料中的表述疑点应继续服从已记录的作者决定和当前实现边界，不重新开启 Q1–Q5。
