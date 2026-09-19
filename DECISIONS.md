# Decisions

2026-09-17；Phase 0 最终记录。输入完整性与图/脚本覆盖已交叉核查。

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D1 | 仅事实审计；不重构、不设计API、不改原始材料、不推送、不使用subagent | 用户及PROJECT_BRIEF明确要求 | 全项目 | Phase1必须另行审阅后开始 | 作者 |
| D2 | 原型仅作证据，不作正确基线；测试通过不代表科研覆盖 | brief及原型实际缺少比较 | P四类实验，AUDIT §6 | 按图和实验登记确定后续范围 | 作者要求＋直接证据 |
| D3 | 分开登记paper/legacy参数，不静默“纠正”实质冲突 | T4.3(b)、T5.1、拓扑参数不同 | AUDIT §3/5 | 作者确认前保留两个版本 | agent判断，依据直接证据 |
| D4 | 保留全部重要比较和缺源码实验；允许标明的新参数重建 | brief允许参数/画法变化；manifest逐图审计 | 29图、T3.7、INC-ω | 不以缺脚本为由省略；网站选图尚未决定 | 作者范围＋agent处置建议 |
| D5 | Γ与Ω、社会Pareto与Nash、η(x(t))与独立变换轨迹分别表达 | 数学定义与非双射映射 | TCh2/4/5、E5/6 | 禁止用近似概念代替关键比较 | 直接证据 |
| D6 | 明确budget identity含omega项；初值锚定，aggregate≤0 | T5.5/5.6/5.23–24、test5_3遗漏 | INC-0/INC-ω | 后续修复图中预算并明确缩放，不改现存源码 | 直接证据 |
| D7 | 独立NumPy仅作代数/有限网格证据，不宣称MATLAB复现或定理证明 | 实际工具执行记录 | audit/evidence | MATLAB干净会话与solver验证留后续 | 直接证据 |
| D8 | 按用户要求暂停保存，随后获准恢复并完成Phase0终验 | 本轮暂停及“是不是可以继续了”指令 | 本次任务 | 完成本地提交后停止；仍不进入Phase1 | 作者 |

其余详细判断和来源见 audit/AUDIT.md；尚待作者确认的内容只列 OPEN_QUESTIONS.md，不冒充已确认科研决定。

## 作者审阅后的更新（优先于上表旧判断）

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D9 | 撤回旧Q1 gradient转录作为正确论文证据；pseudo-gradient须与own-gradient区分 | 作者纠正＋PDF上标agent/下标objective视觉复核 | T4.3、旧JSON ch4纸面项；AUTHOR_REVIEW Q1 | M0重新建立符号/RHS/实际仿真对应，不能继承旧“已确认静止缺陷” | 作者指出问题；agent确认具体转录错误 |
| D10 | trap重建使用实际仿真参数，图注可能记录笔误不否定研究内容 | 作者明确答复Q2 | G trap/helper、T5.1、ACC Fig1 | 不再要求在图注/代码间重新批准；记录实际分支规则并验证性质 | 作者 |
| D11 | 特定条件下不能满足设计要求；满足theorem条件则相应保证成立 | 作者Q3；ACC Theorem2及可行性条件 | T5.4/Chapter6、ACC(20)/(32)–(38) | 关闭一般不可实现疑问；区分必要、充分、特定构造 | 作者＋直接证据 |
| D12 | AI可补3.5–3.7；3.5高优先、3.7必做但较后；图和参数无需一致 | 作者Q4 | S1/S2任务卡 | 按数学case身份验收，不等原图脚本；已有case仅候选参考 | 作者 |
| D13 | 原候选图组认可；两agent五case含不稳定例可作解释候选 | 作者Q5 | T3.5、eigenvector分析、E变换方法 | 仓库全部保留；网站推荐紧凑总览/附图，不在当前终选 | 作者；具体呈现为agent推荐 |
| D14 | 作者审阅修订session当时只定义问题与计划；后续任务须另行明确授权 | 当时作者任务要求 | IMPLEMENTATION_PLAN，M0–R1 | 本次用户已明确授权并完成M0；仍不自动扩展到S1或网站 | 作者 |
| D15 | 新增root.pdf按作者所指ACC参考纳入；保留原始文件名及指纹 | 作者新增文件；完整阅读7页3图 | audit/evidence/added_sources.json、AUTHOR_REVIEW | 图目录增加ACC三图，新增可行性解释，不能假定原图参数齐备 | 作者来源说明＋直接证据 |
| D16 | 冻结M0记号契约：`J_j^i`上标agent/下标objective；代码`Aij`为agent-first；pseudo-gradient必须注明选择规则 | T p26–31/p55视觉复核；ACC(7)；E(27)–(28)；legacy helpers | M0、S1/P1/I1/X1 | 后续参数表和图例统一按该契约；不得复用旧上下标转录 | 直接证据 |
| D17 | T4.3纸面字面版与legacy实际版分开保存；实际非静止由中间两项对象归属及线性项版本差异解释 | 纸面视觉顺序须由`11,21,12,22`重排；legacy脚本直接使用代码`11,12,21,22`顺序；(b)另改`b` | Q1、P1 | 纸面(b)RHS(0,0)不标为已复现；legacy(b)RHS(15,0)可作来源明确的重建起点；(c)同样保留双版本 | 静态公式＋源码核查 |
| D18 | 最近BR与scaled-gradient只在每agent缩放曲率匹配时视为全局等价；trap保留scaled规则标签 | `alpha_1^i|a_1^i|=alpha_2^i|a_2^i|`；trap agent1为2对2.4 | M0、P1 | 逐实验保存规则名和缩放；具体点同分支不冒充全局等价 | 公式推导＋源码核查 |

## S1实施更新

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D19 | S1不用legacy文件名认case；采用满足Remark3.9斜率序的五套新参数，并用统一own curvature `-1`与unit alpha隔离几何差异 | 作者允许自构参数；T Remark3.9；M0规则等价条件 | S1 Case1–5 | case身份由斜率、20个分支矩阵、域与Nash几何共同给出 | 作者范围＋直接计算 |
| D20 | 四稳定例必须四分支全`det>0`且Hurwitz；不稳定例保留四分支全`det<0`，并以正特征值ray位于selected active cone内作直接见证 | T Theorem3.10及Case5证明段 | S1 branch diagnostics | 多初值轨迹只作插图，不能代替稳定性依据；不外推mixed-det | 论文条件＋独立代数 |
| D21 | Case1/3保留无实特征向量的顺/逆时针旋转；Case2/4显式标0/1/2-transitive域；坐标变换只作后续分析工具，不改变Case5真实不稳定性 | T Lemma3.6、Remarks3.7–3.8；作者Q5 | S1、后续X1 | X1不得把映射像的收敛写成原系统自动稳定 | 论文＋作者要求 |
| D25 | S1提交图以MATLAB R2025b实际输出为准；独立Python渲染移至ignored results且不得覆盖MATLAB证据 | 作者要求完成MATLAB运行；本机实际batch执行 | S1 figures/runtime record | 后续图区分MATLAB产物与独立核查，不能以替代渲染冒充MATLAB运行 | 作者要求＋运行证据 |

## P1实施更新

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D22 | 三种收益性质使用同一可解析自身动力学、仅改变线性外部性的新参数族；不声称精确复现Fig4.3，也不复用撤回的Q1转录 | 作者允许参数/图不同；M0 provenance限制；T(4.3)–(4.6) | P1 nonweak/all/weak | 可用精确`z=e^{-t}`公式隔离own、externality、total及Gamma/Omega | 作者范围＋直接代数 |
| D23 | nonweak必须保留独立四负导数组；weak组每agent一正一负；all组四项非负，trap不承担前三组任何身份 | P1任务卡验收 | P1三组＋trap | 后续展示不可合并nonweak与trap | 作者任务卡＋直接证据 |
| D24 | trap忠实采用实际legacy `A/b/x0/alpha`与scaled rule；使用内部`0.020<1.819`见证，不追随caption的首尾时刻；有限网格弱margin不称连续证明 | AUTHOR_REVIEW Q2；G helper；ACC Definition3 | P1 trap | I1可复用诊断，但若需定理保证必须另证连续条件 | 作者决定＋实际源码＋数值核查 |

## I1实施更新

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D26 | I1统一使用含`omega`的完整`J_sum^omega`预算恒等式；`test5_3`漏项只作错误对照，不作为预算定义 | T(5.18)-(5.24)、ACC(23)-(27)、直接代数 | INC-0、INC-omega | 后续任何budget图必须逐时检查完整identity和`p(x0)=0` | 论文＋源码审查＋独立核查 |
| D27 | omega单因素解释使用同一INC-0游戏固定`eta/x0/sigma/zeta/target`比较`0`与`.25`；INC-omega仍为不同游戏补充 | T Fig5.3、ACC Fig2及任务卡 | I1 omega图 | 不得再用test3/test5跨游戏差异冒充omega单因素作用 | 任务卡＋控制变量构造 |
| D28 | INC-0的`omega=0`不引用要求正`lambda`的Lemma；INC-omega虽通过锚定/凹性/general-position/det等代数项，但未证明完整`N_x0`包含 | AUTHOR_REVIEW Q3、Theorem5.4/ACC Theorem2 | I1条件表 | 数值轨迹与理论保证分层；强包含失败不写成普遍不可实现 | 作者解释＋论文条件＋数值核查 |

## X1实施更新

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D29 | X1固定保留`x(t)`、逐点像`eta(x(t))`和从`eta(x0)`独立积分的`z(t)`三对象；不得用映射/插值替代第三者 | E(43)/(50)及Fig6；任务卡 | X1轨迹CSV和证据图 | 后续展示继续使用三种不同线型/来源标签 | 论文＋作者要求＋MATLAB运行 |
| D30 | 轴上逆像保持集合值/未定义，不调用`testfun3_3`返回任意点；独立变换ODE仅给出显式前向轴规则`z_i<=0`选objective 1 | E(49)秩一说明；legacy轴上错误归零 | X1 branch/boundary检查 | 任何后续原空间回拉必须保留整条纤维或明确额外选择条件 | 论文＋源码核查 |
| D31 | 先按论文四舍五入`T`直接核验(58)–(60)；四分支严格裕量充足，故不运行旧YALMIP脚本也不求新证书 | E Proposition3/SectionV；独立与MATLAB特征值 | X1 Lyapunov图/裕量表 | 证书为给定证书验证，不冒充重新求解；`U/W`要求逐元素非负而非PSD | 论文＋独立计算＋MATLAB运行 |
| D32 | 变换法适用限于论文假设和局部符号/域对应；系统不稳定、充分条件不适用、非双射信息丢失分别表述 | AUTHOR_REVIEW Q5；S1 Case5；X1网格/轨迹 | S1/X1/R1展示 | 不用坐标像的收敛抹去active-cone不稳定，也不用求证失败证明不稳定 | 作者要求＋论文＋运行证据 |
| D33 | X1映射图按IFAC Fig5的关系重画但使用已核验参数：原域/Nash直接标注，变换侧只画局部窗口实际像子集；另图以完整纤维到轴点表达多对一，不画轴点到任意原点的逆箭头 | 作者可视化建议；E Fig5–6；E(49)秩一结论 | X1三张提交图 | 后续不得用整象限填色暗示满射，也不得用代表逆像掩盖信息丢失 | 作者建议＋论文＋MATLAB视觉核查 |

## T1实施更新

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D34 | T1采用Examples 2.9/2.10的paper字面own-gradient blocks，paper/legacy符号分别登记；所有权重同时作用于`M`与`b` | T p21–22视觉公式；legacy cube固定`M`而prism加权两者 | T1 cube/prism | 不继承cube固定矩阵缺陷；后续不得把legacy符号图标成paper参数 | 论文＋源码核查＋作者任务 |
| D35 | cube与prism分别按6/5个面、12/9条边、8/6个顶点成对着色和编号；满射是覆盖已定义Nash像，双射另要求权重唯一 | T Example2.8正文及Examples2.9/2.10微分同胚结论 | T1两张面对应图与CSV | 有限网格/Jacobian只作实现诊断；全局双射身份引用论文条件，不由点云冒充证明 | 论文＋MATLAB运行 |
| D36 | Chapter 2仅给own-gradient blocks时不补齐完整收益Hessian；Example2.11紫色区域只称weighted Nash image，非二次图只称示意 | T p21–23；任务卡边界 | T1应用图/非二次图 | 不把own-row几何补齐当原始社会福利，不把集中式社会Pareto集称Nash | 论文＋作者要求 |

## S2实施更新

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D37 | Fig3.6五例复用S1已认证斜率身份并改截距，使agent 1两条BR在Nash点`(0,0)`秩零；不按`cdc2023`文件名或正文`(c)/(e)`矛盾猜测原图对应 | Assumption4、Theorem3.11、AUTHOR_REVIEW Q4 | S2 D1–D5 | case身份继续由四分支det/eigenstructure与定理条件给出；轨迹只作代表 | 作者授权＋论文＋独立/MATLAB核查 |
| D38 | Fig3.7用三组满足general position但mixed determinant signs的新参数表达主要noncompact构型 | Proposition3.1、Assumption2、Fig3.7 | S2 N1–N3 | noncompact由充要条件确认；有限窗口与recession角采样不得写成紧性证明 | 论文＋作者授权＋直接计算 |
| D39 | mixed-det非紧例不套用Theorem3.11的全正/全负结论；单个saddle分支或有限轨迹不升级为全局稳定性判定 | Theorem3.11前件、任务卡边界 | S2 noncompact图/报告 | R1须将“定理不适用”与“系统已证不稳定”分开 | 论文＋任务卡 |

## R1整合与展示评审更新

| ID | 决定内容 | 依据 | 相关论文/代码/实验 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D40 | R1以六个独立MATLAB进程复跑科研入口，再以第七个进程验收和组包；退出码、文件存在、视觉检查和科研比较分别记录 | R1任务卡及实际运行 | T1/S1/S2/P1/X1/I1、`r1_matlab_run.json` | 以后不得只以测试/退出码声明全范围完成 | 作者要求＋运行证据 |
| D41 | manifest的数值实验必须有实际输出；无完整数值来源的示意/论证图可明确归档或合并解释，但不能伪称复现，也不能从科研记录删除 | R1任务卡、32项逐条覆盖表 | `r1_coverage.csv` | 仓库范围完整性与独立图数量分开计算 | 作者要求＋逐项审阅 |
| D42 | 网站候选只从作者认可组分层；S1五case为紧凑附图候选，S2 noncompact与X1 fiber的升级属于新选图建议 | AUTHOR_REVIEW Q5、实际18图视觉评审 | `R1_FIGURE_GUIDE.md` | 未经审阅不改变网站重要图组，不因美观删除仓库实验 | 作者范围＋R1建议 |
| D43 | P1提交图的独立渲染与R1干净MATLAB渲染保留不同provenance标签；R1图包采用MATLAB输出，不以视觉或数值相似冒充同一生成器 | P1报告与R1实跑文件 | P1三图、review pack | 以后图源声明必须绑定实际生成入口 | 直接运行证据 |

## 2026-09-19：独立读者审阅

- 决定内容：在M0–R1完成后增加一次首次读者/科学编辑审阅；分别评估GitHub完整阅读与复现路线、个人主页精选图文路线。本轮审阅已经完成，但不修改科研结果。
- 依据：作者最新要求，希望新session逐一阅读成果、判断表达是否清晰并给出可分发prompt；当前README仍以实验入口和审计链接为主，读者叙事需要独立判断。
- 相关内容：README、18张提交图及18张R1 MATLAB图、21个R1非图结果、32条manifest、M0–R1和论文。
- 后续影响：已先记录首读印象再查内部证据；输出审阅报告、双渠道蓝图及修改任务prompt。重要网站图终选与发布仍不在本轮授权内。
- 来源：新增目标来自作者；分阶段审阅方法与产物安排为agent判断。任务书见`audit/reader_review/REVIEW_BRIEF.md`，结果见`audit/reader_review/`五份交付。

## 2026-09-19：传播审阅后的新增决定

| ID | 决定内容 | 依据 | 相关内容 | 后续影响 | 来源 |
|---|---|---|---|---|---|
| D44 | 科研实现完成与传播准备完成分开验收；R1通过不能替代陌生读者可读性、公共clone可复现性或主页叙事验收 | 冻结首读记录、全图宽度检查、公共文件边界核查 | reader review五份交付 | 后续修改必须逐项关闭传播问题，不能引用R1“完成”直接宣称发布就绪 | 作者目标＋独立审阅 |
| D45 | GitHub采用“问题—数学对象—六个模块—证据层级—复现”的完整路线；个人主页采用少量精选图讲“几何—动力学—信息丢失—激励设计”的路线 | 两类读者任务、18图逐图评审 | `PUBLICATION_BLUEPRINT.md` | README和主页不得复制同一密度的材料；仓库保全，主页精选 | 独立审阅建议，尚未实施 |
| D46 | P1公开图的权威生成器由作者选择；在决定前继续保留tracked独立渲染与R1 MATLAB输出的来源差异，不静默替换 | 两套图视觉与provenance对照 | P1三图、R1 review pack | RR-03只能准备候选与标注，不能冒充已作作者选择 | 直接证据＋编辑判断 |
| D47 | 对外发布前须由作者确认许可证、推荐引用/公开论文链接、P1图源和主页终选；本轮不推送、不部署、不发布 | 当前tracked公共边界与本轮授权 | README、主页素材包 | 这些是发布门槛，不是科研结果缺陷 | 作者授权边界＋独立审阅 |
| D48 | 公共复现统一使用安全wrapper；默认只写ignored `results/public`，T1/I1必须显式传入public figures目录，并逐项验收18图/21非图schema | CR-P0-01/02与实际MATLAB R2025b Update 7空目录运行 | `run_public_reproduction.m`、`REPRODUCING.md` | R1仍只作本地组包入口；成功运行、轨迹和有限网格仍不升级为定理证明 | 作者任务＋实际运行证据 |
| D49 | P1 tracked public figures改以MATLAB入口与clean数值结果为权威生成源；独立渲染仅保留历史来源记录，不与当前public PNG混标 | RR-03明确授权；修改前后CSV逐字节相同、MAT字段`isequaln`、三档视觉检查 | P1三张tracked图、P1/I1派生卡与caption清单 | 不称精确Fig.4.3复现；P1 trap finite-grid边界及I1 invariant containment未证明继续保留 | 作者任务＋MATLAB clean run＋视觉核查 |
| D50 | X1 fiber collapse由repository support提升为public candidate，但主页终选仍待作者决定；公开图必须把局部象限子集、集合值fiber inverse、逐点像与独立积分轨迹分开 | RR-04明确授权；IFAC式(43)/(49)、Fig.5/6、clean MATLAB数值不变量与多尺寸视觉检查 | X1三张技术图、五组响应式派生图、caption清单 | 不称whole-quadrant surjectivity，不选轴上代表逆像，不把变换写成controller/stabilizer或用轨迹替代稳定性定理 | 作者任务＋论文＋MATLAB clean run＋视觉核查 |
