# Project state

## 当前阶段

2026-09-18：P1三种收益性质与独立trap已完成实现、证据图、独立核查及MATLAB R2025b batch复跑。前三组共享同一自身动力学，仅改变外部性，已有连续时间精确符号证书；trap忠实使用实际legacy参数及scaled-own-gradient规则。独立`dt=.001`见证为`0.020<1.819`，MATLAB `dt=.002`见证为`0.020<1.820`，均使两项收益严格下降。S1仍保持代数完成、MATLAB待复跑状态。

## 最新完成

- P1的nonweak、all-payoff nondecreasing、weak-but-not-all是三个独立组；前两者不是由trap代替。精确公式分别给出四负、四非负、每agent一正一负的总收益导数。
- `Gamma`只表示外部性非负，`Omega`表示总导数非负；`own + externality = total`已在图、CSV与`P1.md`中分解，未把`Gamma`外直接当成`Omega`外。
- trap保留`A/b/x0/alpha=[1,1.2,1,2]`和实际scaled helper；有限网格弱改进margin与内部两时刻支配表均已保存，明确不冒充连续时间证明。
- `experiments/run_p1_payoff_properties.m`已由MATLAB R2025b成功生成三张已视觉检查PNG、完整CSV和MAT报告；独立`verify_p1.py`的JSON/CSV/PNG也通过。原始材料和旧原型未修改。

## 下一session

按IMPLEMENTATION_PLAN.md进入I1激励与预算；可复用P1的收益分解诊断，但须新增完整budget identity、target/omega/sigma及原改系统比较。P1与S1均已停止，不顺带开展X1。

## 保持的边界

不要求参数/画法复刻；须保留主要数学内容及case区别。原型和旧case代码是参考而非基线。缺原图脚本可自主构造并记录。有限网格/测试通过不等于定理证明或内容完整。网站尚未发布，当前不设计公共API、不自动创建session、不使用subagent。

MATLAB不在shell的`PATH`中，但已定位并成功调用`/Applications/MATLAB_R2025b.app/bin/matlab`。P1运行通过；S1尚未复跑。P1 trap的逐时弱性质仍是有限网格证据（独立`dt=.001`、MATLAB输出`dt=.002`）；前三组另有精确连续时间公式。

## 当前阻碍

没有必须现在询问作者的问题。P1已无运行环境待办；S1仍可在后续单独做MATLAB干净会话复跑。OPEN_QUESTIONS.md保存后期执行待办。每个后续session只做对应任务、更新记忆并本地提交后停止。
