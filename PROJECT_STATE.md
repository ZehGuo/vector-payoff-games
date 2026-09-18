# Project state

## 当前阶段

2026-09-18：P1三种收益性质与独立trap已完成实现、证据图和独立核查。前三组共享同一自身动力学，仅改变外部性，已有连续时间精确符号证书；trap忠实使用实际legacy参数及scaled-own-gradient规则，并给出内部`0.020<1.819`的双收益下降见证。S1仍保持完成状态。两个MATLAB入口均已写成，但当前shell无`matlab`/`octave`可执行入口。

## 最新完成

- P1的nonweak、all-payoff nondecreasing、weak-but-not-all是三个独立组；前两者不是由trap代替。精确公式分别给出四负、四非负、每agent一正一负的总收益导数。
- `Gamma`只表示外部性非负，`Omega`表示总导数非负；`own + externality = total`已在图、CSV与`P1.md`中分解，未把`Gamma`外直接当成`Omega`外。
- trap保留`A/b/x0/alpha=[1,1.2,1,2]`和实际scaled helper；有限网格弱改进margin与内部两时刻支配表均已保存，明确不冒充连续时间证明。
- `experiments/run_p1_payoff_properties.m`及独立`verify_p1.py`生成三张已视觉检查PNG、JSON与CSV。原始材料和旧原型未修改，没有MATLAB运行成功声明。

## 下一session

按IMPLEMENTATION_PLAN.md进入I1激励与预算；可复用P1的收益分解诊断，但须新增完整budget identity、target/omega/sigma及原改系统比较。P1与S1均已停止，不顺带开展X1。

## 保持的边界

不要求参数/画法复刻；须保留主要数学内容及case区别。原型和旧case代码是参考而非基线。缺原图脚本可自主构造并记录。有限网格/测试通过不等于定理证明或内容完整。网站尚未发布，当前不设计公共API、不自动创建session、不使用subagent。

先前记录称MATLAB已安装且用户已打开，但本轮shell中仍没有`matlab`或`octave`入口；S1、P1均未启动MATLAB，也没有运行成功声明。独立公式核查与图形渲染不能冒充MATLAB执行。P1 trap的逐时弱性质目前是`dt=0.001`有限网格证据；前三组另有精确连续时间公式。

## 当前阻碍

没有必须现在询问作者的问题。S1/P1的运行环境待办是在可调用MATLAB时做干净会话复跑；不影响已记录的代数身份。OPEN_QUESTIONS.md保存后期执行待办。每个后续session只做对应任务、更新记忆并本地提交后停止。
