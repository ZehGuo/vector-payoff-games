# Project state

## 当前阶段

2026-09-17：M0符号与动力学契约已完成静态核查，未开始MATLAB重构。初次审计提交2ab0d68的Q1错误继续保持撤回；Q1的新基线为audit/implementation/M0.md。

## 最新完成

- 建立 `J_j^i` 上标agent/下标objective与MATLAB agent-first变量、控制坐标的完整对应，区分完整gradient、own-gradient、pseudo-gradient和总收益导数。
- 核清最近BR与scaled-gradient规则：`alpha_1^i|A_ii^{i1}|=alpha_2^i|A_ii^{i2}|`时全局排序等价；inactive、zero-boundary和tie行为分别记录。
- 重算T4.3三组纸面初值。纸面视觉顺序`J_1^1,J_1^2,J_2^1,J_2^2`必须先按上下标重排；legacy两脚本把中间两项按旧代码顺序归属。T4.3(b)纸面字面RHS为(0,0)，`test6_4_1`实际RHS为(15,0)；纸面(c)为`(0,-36 alpha_1^2)`，`test10_1` legacy版为(8,-6)。
- trap实际helper在初值RHS为(-9.948,0)，但其agent 1缩放不满足全局规则等价条件，后续必须标作scaled-gradient版本。
- 原始137个来源文件均未修改；没有MATLAB运行证据。Fig4.3各子图的精确绘图参数版本仍无法唯一确定，只作为最小provenance问题。

## 下一session

按IMPLEMENTATION_PLAN.md继续S1五case。S1使用M0的符号/分支契约；Q1剩余的Fig4.3精确来源问题留给P1作纸面/legacy双版本标注，不阻塞S1。不得拿旧转录JSON作真值。

## 保持的边界

不要求参数/画法复刻；须保留主要数学内容及case区别。原型和旧case代码是参考而非基线。缺原图脚本可自主构造并记录。有限网格/测试通过不等于定理证明或内容完整。网站尚未发布，当前不设计公共API、不自动创建session、不使用subagent。

先前记录称MATLAB已安装且用户已打开，但本轮shell中没有`matlab`或`octave`入口；未启动MATLAB，也没有新增运行成功声明。后续如需运行须如实记录环境、入口和授权状态。

## 当前阻碍

没有必须现在询问作者的问题。OPEN_QUESTIONS.md保存执行待办和后期选图事项。每个后续session完成任务、更新记忆并本地提交后停止；本轮只提交审阅修订和计划。
