# 可分发的独立修改 prompts

日期：2026-09-19
使用方法：每个 fenced block 都可作为一个独立 session 的完整用户 prompt。RR-01、RR-02、RR-03、RR-04 可在互相独立的 worktree 中并行；RR-05 等它们合并后再运行；RR-06 最后运行。不要让多个 session 同时修改 README。

## RR-01（P0）：安全的一键复现与公开输出合同

```text
项目目录：/Users/lei/ZehuiGuo/vector-payoff-games-rebuild

任务ID：RR-01 / CR-P0-01 / CR-P0-02。

问题与读者误读：README把六个MATLAB函数称为reproducible entries，但没有可复制命令、输出索引或安全默认值。T1和I1若省略第二个参数，会写入tracked的audit/implementation/figures，首次读者可能在“复现”时覆盖提交图。results/、论文和R1 pack又被Git忽略，不能当作新clone已有内容。

目标受众：首次clone、安装了MATLAB但未读论文的研究读者。

必须传达的一句话：从仓库根目录运行一个公开入口，所有生成物只写到results/public，六组实验分别输出图、CSV和MAT，运行前后tracked worktree不变。

先读：AGENTS.md；audit/reader_review/COMMUNICATION_REVIEW.md 的 CR-P0-01/02；audit/reader_review/PUBLICATION_BLUEPRINT.md 的“安全复现”；六个 experiments/run_*.m 与 experiments/run_r1_integration_review.m。不要把R1 packaging entry误作六组实验启动器。

修改范围（本任务独占）：
- 新增 experiments/run_public_reproduction.m；
- 新增 docs/REPRODUCING.md；
- 如确有必要，可新增 tests/verify_public_reproduction.m 或一个只读校验脚本；
- 不修改README、不修改现有六个科研入口、不修改参数、算法、tracked figures、audit旧报告或原始材料。

科学不变量：
- T1中M(weight)和b(weight)使用同一权重；
- S1/S2的新构造身份、case顺序与稳定性判据不变；
- P1前三组仍是新exact family，trap仍用actual legacy scaled-own-gradient；
- X1的x(t)、eta(x(t))、独立z(t)分开；
- I1只修改J_1^i，INC-0 same-game omega对照与INC-omega different-game supplement分开；
- 成功运行、trajectory或finite grid不得写成theorem proof。

具体工作：
1. wrapper接受可选output root，默认repo/results/public；为T1和I1显式提供各自figures子目录，绝不依赖会覆盖audit figures的默认值。
2. 依次调用T1/S1/S2/P1/X1/I1；收集每组返回report的最小metadata；生成一个人可读的输出索引（可为tracked schema说明+runtime CSV/MD），说明每组图/表/MAT在哪里。
3. wrapper启动时检查当前目录/路径，内部加入并最终清理experiments path；失败时指出具体task，不吞异常。
4. docs/REPRODUCING.md写MATLAB R2025b Update 7为已测试版本；其他版本未验证。说明source_material/reference/results不随clone提供且六组运行不需要本地论文。
5. 给macOS已知路径和MATLAB已在PATH两种命令示例；不要硬编码为只有作者机器能运行。
6. 在干净临时输出目录实际运行。检查六组预期文件存在，且git status除执行前已有用户文件外没有新增tracked修改。

验收：
- 从repo root一条MATLAB命令完成六组并打印输出索引；
- T1/I1图位于results/public/<task>/figures，不触碰audit/implementation/figures；
- 18类图输出和21类非图输出的schema可对应，但无需复制R1本地包；
- docs中的每条仓库内链接存在；
- 运行后tracked git diff为空；
- 不以“tests pass”替代上述文件级与科学边界检查。

记忆与状态：完成后仅把“安全公开复现入口已实现/验证”写入PROJECT_STATE、DECISIONS和OPEN_QUESTIONS的简短增量；若用户明确要求更新Codex记忆，写明这是已实现而非建议。

提交与停止：创建只含本任务文件和状态增量的本地commit；保留所有用户现有未提交文件；不push、不发布、不部署；报告commit hash和实际MATLAB命令后停止。
```

## RR-02（P1/P2）：T1/S1/S2 几何与稳定性图的读者版

```text
项目目录：/Users/lei/ZehuiGuo/vector-payoff-games-rebuild

任务ID：RR-02 / CR-P1-03 / CR-P2-01 / CR-P2-02（T1/S1/S2 owner）。

问题与读者误读：T1 cube/prism的对应关系受3D遮挡，S1的稳定身份容易被误读成trajectory分类，S1红色unstable witness与agent-1 BR角色冲突，S2 noncompact容易被有限窗口误读为证明。多面板图在390px无法读出判据。

目标受众：GitHub正文读者与个人主页访问者；技术原图仍服务论文级核查。

必须传达的一句话：权重域到Nash集合的结构、稳定/不稳定case和noncompact边界分别由定理条件、分支/eigenstructure/cone transitions、以及mixed determinant signs认证，轨迹和有限窗口只是说明。

输入与依赖：先读audit/reader_review/COMMUNICATION_REVIEW.md的T1/S1/S2节、PUBLICATION_BLUEPRINT.md和对应T1/S1/S2报告。可与RR-01、RR-03、RR-04并行，使用独立worktree。无需等待README任务。

修改范围（本任务独占）：
- experiments/run_t1_topology_applications.m；
- experiments/run_s1_five_cases.m；
- experiments/run_s2_degenerate_noncompact.m；
- experiments/configs/t1_topology_parameters.m仅在标签元数据确有需要时修改，不改数值；
- 对应8张audit/implementation/figures/T1_*.png、S1_*.png、S2_*.png；
- 新增docs/assets/t1_s1_s2/下的移动端/主页派生图和caption清单；
- 新增一个本任务报告audit/reader_review/followups/RR02_GRAPHICS.md；
- 不修改README、P1/X1/I1文件或共享文档。

科学不变量：
- cube/prism保持paper参数，M和b共同加权；全局bijection/diffeomorphism来自论文条件而非采样点；
- production紫色是weighted Nash image，不是centralized social Pareto；nonquadratic保持schematic only；
- S1保持四stable一unstable；case identity由slopes、全部branch matrices、eigenstructure、active cones和theorem assumptions认证；
- S2是新构造，不称exact thesis parameters；rank-degenerate与noncompact分开；mixed-sign noncompact不适用Theorem 3.11；finite window不是compactness proof；
- 不改任何数值参数、ODE规则、case顺序或诊断容差。

具体工作：
1. T1 cube/prism加入映射方向或紧凑face/vertex key，减少遮挡；正文版可保留3D，另做900/390px可读派生图。
2. production图保留Nash≠social Pareto标题；明确BR全称与轴的单位/无量纲约定。
3. S1 overview解决红色角色冲突，加trajectory方向，并给每case一个最小判据标签；eigen图定义0/1/2-transitive且给灰/黑/红角色图例。
4. S2 rank-degenerate把new construction/Assumption 4前置；noncompact加recession direction并让analytic criterion先于trajectory。
5. 全部图同时使用颜色+线型/标记/直接标签；标题不塞长免责句，限制移入紧邻caption。
6. MATLAB在全新输出目录运行；数值CSV/MAT与修改前一致（允许PNG像素变化）；逐张原尺寸及1100/900/390px打开检查。

验收：
- 900px可读每张图的一句话结论；390px派生资产每卡只承载一个比较；
- cube/prism读者能配对至少faces与vertices而不猜；
- S1读者能区分BR、代表trajectory与unstable eigenray；
- S2 caption明确analytic noncompact certificate且不把窗口当证明；
- 数值参数、branch diagnostics和case classification完全不变；
- tracked原图全部保留，不因主页精选删除边界case。

记忆与状态：只记录已完成的图形呈现修改及未改变的科学不变量；不要把主页终选写成已决定。

提交与停止：创建本地commit，仅含本任务范围与状态增量；保留用户现有未提交文件；不push、不发布、不部署；报告输出路径、视觉检查方法和commit hash后停止。
```

## RR-03（P1）：P1/I1 的 MATLAB provenance、收益分解与激励图

```text
项目目录：/Users/lei/ZehuiGuo/vector-payoff-games-rebuild

任务ID：RR-03 / CR-P1-04 / CR-P1-05 / CR-P2-01（P1/I1 owner）。

问题与读者误读：P1当前tracked图是独立渲染版，R1 clean pack是MATLAB版；若不说明会误称tracked图为clean MATLAB。独立版在900px整洁但缺真实轴/刻度，MATLAB版有轴却曲线拥挤。I1多面板容易被读成“当前数值例满足完整定理”，sigma图上下集合/补集convention与raw formula标签也难读。

目标受众：希望理解payoff变化与incentive条件边界的GitHub读者；主页只取精简比较。

必须传达的一句话：total payoff rate由own-direction contribution与externality共同决定；incentive数值例同时展示行为、原/改payoff与aggregate transfer，但完整invariant-domain theorem condition尚未证明。

输入与依赖：读COMMUNICATION_REVIEW的P1/I1节、P1.md、I1.md、AUTHOR_REVIEW Q2/Q3、R1_FIGURE_INDEX.csv。可与RR-01、RR-02、RR-04并行，独立worktree。

修改范围（本任务独占）：
- experiments/run_p1_payoff_properties.m；
- experiments/run_i1_incentive_budget.m；
- 对应7张audit/implementation/figures/P1_*.png、I1_*.png；
- 新增docs/assets/p1_i1/的移动端/主页派生图和caption清单；
- 新增audit/reader_review/followups/RR03_GRAPHICS.md；
- 不修改README、T1/S1/S2/X1、科研参数或旧audit结论。

科学不变量：
- J_j^i上标agent、下标objective；full/own/selected pseudo-gradient/total derivative不混；
- P1前三组仍是new exact comparison family，不称exact Fig.4.3；trap仍是actual legacy A/b/x0/alpha和scaled-own-gradient；finite-grid weak margin不是连续证明；
- Gamma、Omega、own、externality、total保持原定义；trap不替代nonweak；
- I1只修改J_1^i；target、omega、sigma、initial anchoring与完整aggregate budget identity不变；
- INC-0 same-game omega比较与INC-omega different-game supplement分开；未证明N_x0 containment，不得写完整theorem guarantee；强D(U) subset D_bud失败不等于一般不可能。

具体工作：
1. 以MATLAB入口和clean numerical result为P1数值authority，重新生成tracked public figures；可继承独立版的清晰分组，但必须有轴、时间、真实刻度和一致图例。旧独立渲染只保留有明确历史/来源说明的位置，不混标。
2. P1三性质每行写逻辑判定；rate图给全局legend/zero line；trap明确t1/t2选择和J_1^2、J_2^2对应。
3. I1 design按social Pareto/Nash→domains→same-game omega→behavior编号；sigma统一阴影与complement语义并修复raw公式；before/after给terminal distance和budget sign convention；INC-omega继续放补充层。
4. 生成主页派生图：P1 trap两时刻+一个rate decomposition；I1 trajectory+aggregate transfer。完整技术图仍保留。
5. 在新目录运行MATLAB，比较所有CSV关键margin和MAT字段；不得通过重画改变数值。逐图以1100/900/390px实际打开。

验收：
- 每张tracked P1图可从caption追到MATLAB入口、数据和渲染来源；
- 900px能读出每个rate符号和trap判定，390px派生卡不依赖九宫格；
- I1图旁明确列出algebra checked / trajectory observed / invariant containment unproved；
- INC-omega标题/说明仍写different game；
- 关键CSV数值、参数、ODE分支与修改前一致；
- 不将视觉改善或运行通过当作theorem证明。

记忆与状态：记录P1 public authority的实际落地选择、图形修改和仍未证明的I1条件；不要写成论文原图精确复现。

提交与停止：创建本地commit，仅含本任务范围与状态增量；保留用户未提交文件；不push、不发布、不部署；报告provenance、数值对比、视觉检查和commit hash后停止。
```

## RR-04（P1/P2）：X1 非双射变换的解释图

```text
项目目录：/Users/lei/ZehuiGuo/vector-payoff-games-rebuild

任务ID：RR-04 / CR-P1-03 / CR-P2-01 / CR-P2-02（X1 owner）。

问题与读者误读：X1 domain map颜色/纹理过密，D^(i,j)未定义；fiber collapse最能解释信息丢失却只列repository support；trajectory图的eta(x(t))与独立z(t)容易被看成数值误差或“变换稳定化”。390px四面板不可读。

目标受众：不熟悉non-bijective coordinate transformation的控制/博弈读者。

必须传达的一句话：映射把二维域压到象限子集、条带压到轴、Nash集合压到原点；轴上逆像是整条fiber，因此pointwise eta(x(t))与independently integrated z(t)是不同对象。

输入与依赖：读COMMUNICATION_REVIEW的X1节、X1.md、IFAC extension相关定义/Example和R1 index。可与RR-01/02/03并行，独立worktree。

修改范围（本任务独占）：
- experiments/run_x1_transformation_stability.m；
- 3张audit/implementation/figures/X1_*.png；
- 新增docs/assets/x1/的移动端/主页派生图和caption清单；
- 新增audit/reader_review/followups/RR04_GRAPHICS.md；
- 不修改README或其他模块。

科学不变量：
- x(t)、pointwise eta(x(t))、independent z(t)严格分开；
- axis inverse保持set-valued，不选代表逆像；
- local image subsets不称whole-quadrant surjectivity；
- transformation不是controller或stabilizer；系统unstable、certificate不适用、mapping information loss三件事不混；
- 保留paper printed eta0=-13.5与computed -13.25、printed norm inequality方向问题的记录，不悄悄替换为“精确复现”；
- certificate、branch/boundary checks和数值参数不变。

具体工作：
1. domain map增加D标签释义key，减弱右图纹理，并用边界/marker辅助颜色。
2. fiber collapse提升为public candidate；直接标注fiber与single image point，caption定义kappa和set-valued inverse；做390px上下版。
3. trajectory图按(1) original x(t)、(2) pointwise eta(x(t))、(3) independent z(t)、(4) certificate编号；把A/B separation做清楚的inset；正文解释norm暂增不等于instability。
4. MATLAB新目录运行并比较x1_trajectories.csv、report字段、certificate margins；只改呈现。
5. 原尺寸和1100/900/390px实际打开；检查线型而非纯颜色承担区分。

验收：
- 未读论文者能从fiber图准确说出“many x map to one point”；
- 900px能区分solid eta(x(t))与dashed z(t)，390px派生卡一次只讲一个对象；
- caption明确local subset、set-valued inverse和not stabilization；
- CSV、report与certificate数值不变；
- 不以trajectory趋近替代全局stability theorem。

记忆与状态：记录X1 public candidate与已实现派生资产；主页终选仍标待作者决定。

提交与停止：本地commit后停止；仅提交本任务文件和状态增量；保留用户未提交文件；不push、不发布、不部署。
```

## RR-05（P1）：README、概念说明与完整结果叙事整合

```text
项目目录：/Users/lei/ZehuiGuo/vector-payoff-games-rebuild

任务ID：RR-05 / CR-P1-01 / CR-P1-02 / CR-P1-03（唯一README owner）。

前置依赖：RR-01、RR-02、RR-03、RR-04已完成并合并；若某项未完成，先读取其最新状态与产物，不要猜图名/命令。作者的LICENSE、citation和公开paper links若尚未决定，明确列为release blockers，不代选。

问题与读者误读：当前README只有模块清单，要求读者先进入PROJECT_STATE/AUDIT；没有“为什么是一个set”、研究链、符号、代表图、caption、复现命令或public/local分层。

目标受众：有基础数学/编程背景、未读论文的GitHub访问者。

必须传达的一句话：这个仓库展示从vector-payoff Nash-set geometry到piecewise dynamics、welfare、non-bijective representation和conditional incentive design的一条完整、分层且可复现的研究链。

修改范围（本任务独占）：
- README.md；
- 新增/修改docs/CONCEPTS_AND_NOTATION.md、docs/RESULTS.md、docs/PROVENANCE.md；
- 只链接RR-01的docs/REPRODUCING.md，不修改其命令逻辑；
- 可新增CITATION.cff仅在作者已提供并确认正式信息时；不得自行创建LICENSE或选择许可证；
- 不修改MATLAB、参数、数值结果或图片像素。

科学不变量：遵守M0–R1全部边界，尤其J_j^i索引、M和b共同加权、Nash≠social Pareto、S1/S2认证层级、P1新构造/legacy trap分离、X1三对象分离、I1 theorem condition边界。不得写“first/optimal/complete proof”等未经论文和作者记录支持的新颖性词。

具体工作：
1. 按PUBLICATION_BLUEPRINT的README结构写英文公开稿：problem→contributions→representative figure→research chain→reading routes→results→reproduction→provenance/limitations→papers/citation/license。
2. README嵌5–7张代表图；其余18图由docs/RESULTS.md逐图提供question/comparison/look/takeaway/do-not-infer/caption/alt text。
3. notation页定义J_j^i、BR、X*(J)、D、selected pseudo-gradient、own/externality/total、Gamma/Omega、eta/z、sigma/omega。
4. provenance页明确paper/legacy/new construction/schematic/independent renderer/clean MATLAB层级及ignored本地材料。
5. 所有公开链接用新clone可取得的tracked路径；不链接results/r1、本地PDF或reference。
6. 用隔离临时clone或git ls-files清单检查链接；按30秒/3分钟/15分钟路线人工走读；900/390px检查嵌图。

验收：
- 30秒可说出问题和Nash-set核心；3分钟可区分own/externality/total与eta/z；15分钟能找到六入口、每组结果和限制；
- README不要求先读AUDIT；audit作为“how this reconstruction was verified”的深入链接保留；
- 一条已验证命令生成public outputs且运行不改tracked files；
- 每张图有caption和alt text；
- 无链接指向ignored-only文件；
- license/citation未决定时显式阻断release，不伪造。

记忆与状态：记录读者入口已实现、实际链接/命令和仍待作者选择的release blockers。更新PROJECT_STATE/DECISIONS/OPEN_QUESTIONS时不要把发布写成完成。

提交与停止：创建本地commit，仅含文档与状态增量；保留用户未提交文件；不push、不部署、不发布；报告commit hash、链接检查和未决作者事项后停止。
```

## RR-06（P2）：可移植主页图文包，不建站不发布

```text
项目目录：/Users/lei/ZehuiGuo/vector-payoff-games-rebuild

任务ID：RR-06 / homepage portable content pack。

前置依赖：RR-02/03/04的public derivatives与RR-05的最终研究说明已合并。作者若未终选图片，使用PUBLICATION_BLUEPRINT推荐序列生成“provisional editorial selection”，明确不是final approval。不得读取或修改实际个人网站仓库，除非用户另行给出授权。

问题与读者误读：完整18图适合repository evidence，不适合个人主页；若原样搬运，多面板、审计限制和公式会淹没研究价值，且390px不可读。

目标受众：对研究方向感兴趣但不熟悉vector-payoff games的主页访问者。

必须传达的一句话：多个未排序目标把Nash point变成Nash set；作者研究其geometry、dynamics、welfare与有预算约束的conditional design，并诚实展示变换/定理的边界。

修改范围（本任务独占）：
- 新增publication/homepage/README.md；
- 新增publication/homepage/story.md、captions.md、asset_manifest.csv；
- 复制或生成只来自已批准tracked public derivatives的静态资产到publication/homepage/assets/；
- 不改README、MATLAB、audit figures、科研参数、个人网站代码；不部署。

科学不变量：Nash≠social Pareto；trajectory不证明theorem；P1 trap与nonweak分开；X1 transform不等于stabilization；I1未证明完整invariant containment；不同game的INC-omega不作单因素因果；不自动发布本地PDF。

具体工作：
1. 写英文短叙事：motivation→geometry→local motion/externality/trap→fiber information loss→conditional design→deep links。
2. 推荐资产顺序：T1 production；可选cube/prism；P1 trap+rate；X1 fiber（提升建议）；I1 trajectory+aggregate transfer；S1 stable/unstable和S2 noncompact仅扩展。
3. 每段给headline、60–100词正文、caption、alt text、repository/paper link target。
4. asset_manifest记录源tracked path、derivative method、provenance、mobile/desktop尺寸、claim boundary和author approval status。
5. 实际检查1100与390px静态稿；每个移动端卡只讲一个比较，不靠颜色唯一编码。
6. 列出作者最终需要勾选的图、license/citation/paper links，但不反复追问已决定的科学问题。

验收：
- 不读论文者从story能准确说出研究问题和至少两个关键认识；
- 390px无九宫格/六宫格缩图承担主证据；
- 每个asset可追到tracked源和生成方式；
- 文案没有越过theorem/provenance边界；
- 产物可交给任意网站实现者，不绑定框架；
- 没有push、deploy或修改真实站点。

记忆与状态：记录“主页内容包已准备/仍未终选或发布”，不要写“网站已完成”。

提交与停止：创建本地commit，仅含publication/homepage及状态增量；保留用户未提交文件；不push、不发布、不部署；报告commit hash和待作者选择后停止。
```

## 建议的首批分发

同时分发 RR-01、RR-02、RR-03、RR-04，各自使用独立 worktree。它们文件所有权不重叠：RR-01 只管安全运行，RR-02 只管 T1/S1/S2，RR-03 只管 P1/I1，RR-04 只管 X1。合并后再分发 RR-05；作者确认发布选择后再分发 RR-06。
