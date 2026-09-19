# Project state

## 当前阶段

2026-09-19：R1整合与展示评审完成。T1、S1、S2、P1、X1、I1六个入口分别在独立MATLAB R2025b clean-batch进程中全量复跑，第七个进程核对18张图与21个非图产物并生成本地评审包。32个manifest条目均有实际输出、明确示意或讨论性归档处置；所有必需数值实验均已交付。

## R1最新完成

- 完整报告：`audit/implementation/R1.md`；逐项覆盖表：`audit/implementation/r1_coverage.csv`；运行记录与图哈希：`audit/evidence/r1_matlab_run.json`。
- 本地图包：`results/r1/20260919-review-pack/`，含18张干净MATLAB图、索引和说明；`results/`保持Git忽略，图包不是发布物。
- 仓库范围保留全部实验；网站只按作者认可候选分层。S1五case作为紧凑附图候选，并明确不稳定active-cone方向、充分条件不适用、非双射信息丢失三者不同。
- P1提交图的独立渲染来源与本次干净MATLAB图分开登记；数值结论一致，不把独立渲染冒充MATLAB产物。
- 全仓核查确认旧Q1错误数组只保留于历史/更正证据，没有进入六个实验入口或R1结论。

## S2最新完成

- 五例共享显式二次收益族、nearest-BR规则及秩零Nash点`(0,0)`；D1–D4四分支全`det>0`，D5四分支全`det<0`，保留顺/逆时针、实特征向量混合转移及saddle区别。
- 三个非紧例均满足general position但违反Assumption 2；四分支determinant为混合符号，故按Proposition 3.1全局确认noncompact。recession-angle采样只描述构型，不作为证明。
- `cdc2023`仅作候选参考；正文`(c)/(e)`不一致没有用文件名猜测解决。参数、BR、Nash集合、代表轨迹、假设边界和32分支诊断见`audit/implementation/S2.md`。
- MATLAB R2025b Update 7最终从新建空目录生成两张PNG、四张CSV及MAT；独立标准库核查器复算8例/32分支。首次结构体初始化错误已修复后从头复跑。

## T1最新完成

- 采用Chapter 2 Examples 2.9/2.10的paper字面own-gradient blocks：cube使用paper的`-.6/-.5`，prism使用agent 2首系数`-1`；legacy符号另存，不混入运行参数。cube旧脚本固定`M`的缺陷没有继承。
- 对每个权重解`M(w)x+b(w)=0`。MATLAB采样得到cube/prism最小`rcond`分别`.221483942414/.24`、最小Jacobian绝对行列式`100/13.65`、最大方程残差`2.67e-15/1.80e-15`。论文Examples 2.9/2.10给出的微分同胚结论负责全局双射身份；有限采样只作实现诊断，不替代证明。
- 生产/污染图严格使用Example 2.11四个公式，紫色区域标为weighted Nash image，未计算或命名集中式社会Pareto集。非二次图明确标为无来源参数的概念示意。
- 只登记论文给出的controlled-coordinate derivative blocks，不从own rows补齐完整Hessian或虚构社会福利。参数、版本、运行证据和限制见`audit/implementation/T1.md`。

## 此前完成（X1）

- X1按论文(50)–(51)自含补足缺失`testfun3`；原系统与变换系统各自用RK4积分，`eta(x(t))`只作逐点映射，未用插值或映射代替独立解。
- 原空间紫色Nash域及八个周围域到象限子集、四半轴和原点的对应已直接标注；另图显示四条秩一纤维各自坍缩到一个轴点。首个`D^(0,1)`区段在MATLAB为`[.047,.174]`，两轨迹从此分离。轴上逆像保持未定义/集合值，不调用旧`testfun3_3`任选一点。
- 论文四舍五入`T`在四分支均有严格裕量：最弱衰减`12.6690660020`、最弱正性`2.2440811913`；`U/W`逐元素非负，故未求新证书。原网格拉回`V(eta(x))`、变换等高线及两轨迹上的V均已输出。
- 论文给定参数直接算得`eta(x0)=(-2.5,-13.25)`而非正文`(-2.5,-13.5)`；图6 A到B的像范数也由`8.3005`降至`2.3310`，与正文不等号方向相反。两项均记录为不影响证书的最小来源差异。
- X1结合S1明确区分：active-cone正特征值见证的系统不稳定、充分条件无法使用、以及非双射压缩造成的信息丢失，三者不能互相替代。

## 独立读者与科研传播审阅

2026-09-19：审阅已完成。严格保留了先首读、后查内部审计/论文/实现报告的顺序；首读阶段受到一次提前显示任务书Phase B清单的程序性污染，已在`audit/reader_review/FIRST_READ.md`原样披露，没有回填成“无污染”记录。

- 五份交付：`FIRST_READ.md`、`REVIEW_INVENTORY.csv`、`COMMUNICATION_REVIEW.md`、`PUBLICATION_BLUEPRINT.md`、`FOLLOWUP_PROMPTS.md`。
- 实际核查18张提交图、18张R1干净MATLAB图、21个非图结果、32项manifest、六个实验入口、三篇来源PDF及M0–R1报告；并在1100/900/390像素宽度检查全部提交图。
- 结论：科研实现完成不等于传播准备完成。当前主要P0障碍是公共clone缺乏可自检的安全运行入口/示例结果、README没有建立研究问题到图与证据的连续主线、以及P1公开图源权威性仍需作者选择。
- 本轮只写审阅、内容蓝图和独立修改prompt；未修改科研实现、参数或结果，未替换任何图，未推送、部署或发布。

## 下一session

建议先并行执行`FOLLOWUP_PROMPTS.md`中的RR-01至RR-04，再由RR-05统一改README，最后由RR-06准备个人主页素材包。所有建议仍是待实施任务，不得把本次审阅文档写成已经完成的发布改造。

## 保持的边界

不要求参数/画法复刻；须保留主要数学内容及case区别。原型和旧case代码是参考而非基线。缺原图脚本可自主构造并记录。有限网格/测试通过不等于定理证明或内容完整。网站尚未发布，当前不设计公共API、不自动创建session、不使用subagent。

MATLAB不在shell的`PATH`中，但已定位并成功调用`/Applications/MATLAB_R2025b.app/bin/matlab`。T1、X1、I1、P1、S1与S2均运行通过。T1四张、X1三张、I1四张、S1两张、S2两张提交图均为MATLAB实际输出；T1的有限权重网格只检查实现，不替代Chapter 2的微分同胚结论；S2的finite-window图与recession采样不替代Proposition 3.1的noncompact证明；X1的独立Python核查不是MATLAB证据或定理证明，P1 trap的逐时弱性质仍是有限网格证据。

## 当前阻碍

科研实现与R1没有运行环境阻碍。对外传播前有四项作者决定：许可证、推荐引用/公开论文链接、P1公开图的权威生成器、个人主页最终选图与篇幅。这些不推翻科研完成状态，但会阻碍正式公开发布。

## RR-01安全公开复现入口

2026-09-19：已实现并验证`experiments/run_public_reproduction.m`与`docs/REPRODUCING.md`。MATLAB R2025b Update 7从仓库根目录在空临时输出目录依次完成T1/S1/S2/P1/X1/I1，核对18类图和21类非图科研产物；T1/I1图显式写入各自`figures/`子目录，运行前后tracked diff为空。成功运行仍只属于执行证据，不替代理论证明。
