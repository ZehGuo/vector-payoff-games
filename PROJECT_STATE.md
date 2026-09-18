# Project state

## 当前阶段

2026-09-18：I1激励与预算已完成实现、四张证据图、独立核查及MATLAB R2025b batch复跑。INC-0、同游戏omega对照、sigma三段与ACC共同排除区、INC-omega补充及完整预算恒等式均已保留；旧`test5_3`遗漏的omega预算项已纠正。P1与S1此前亦已完成。

## 最新完成

- I1明确区分社会Pareto集合、Nash集合和社会福利target；INC-0原/改BR、轨迹、原/改收益与全时域aggregate transfer已成组输出。
- sigma临界值复算为`.4096591512/.5265853903`，保留内部椭圆、双曲/抛物区间、外部椭圆三段，并增加ACC式两个budget补集与共同排除区解释。
- 同一INC-0游戏控制其余量比较`omega=0`与`.25`；INC-omega仍标为不同游戏补充。完整预算使用`J_sum^omega`，补充例末值为`-12874.075388`，旧遗漏omega式会给`-15031.101323`。
- 两例均通过锚定、完整恒等式、own凹性、general position和四分支det核查；但未证明完整`N_x0`包含，强`D(U,x0) subset D_bud`证书亦失败。因此只报告精确恒等式与采样轨迹，不冒充定理保证，也不写成普遍不可实现。

## 下一session

按IMPLEMENTATION_PLAN.md进入X1坍缩变换、独立动力学与证书。I1、P1与S1均已停止，不顺带开展T1或S2。

## 保持的边界

不要求参数/画法复刻；须保留主要数学内容及case区别。原型和旧case代码是参考而非基线。缺原图脚本可自主构造并记录。有限网格/测试通过不等于定理证明或内容完整。网站尚未发布，当前不设计公共API、不自动创建session、不使用subagent。

MATLAB不在shell的`PATH`中，但已定位并成功调用`/Applications/MATLAB_R2025b.app/bin/matlab`。I1、P1与S1均运行通过。I1四张提交图、S1两张提交图均为MATLAB实际输出；P1 trap的逐时弱性质仍是有限网格证据，前三组另有精确连续时间公式。

## 当前阻碍

没有必须现在询问作者的问题。I1、P1与S1均无运行环境待办。OPEN_QUESTIONS.md保存后期执行待办。每个后续session只做对应任务、更新记忆并本地提交后停止。
