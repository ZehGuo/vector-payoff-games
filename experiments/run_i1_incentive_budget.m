function report = run_i1_incentive_budget(outputDir, figureDir, derivedFigureDir)
%RUN_I1_INCENTIVE_BUDGET Rebuild I1 incentive and budget comparisons.
% State order is x=[x^1;x^2]; payoff order is [J_1^1,J_2^1,J_1^2,J_2^2].
% Only J_1^i is incentivized.  The implemented field uses nearest-BR.
% DERIVEDFIGUREDIR optionally receives two compact reader-facing cards.

repoRoot=fileparts(fileparts(mfilename('fullpath')));
if nargin<1 || isempty(outputDir), outputDir=fullfile(repoRoot,'results','i1'); end
if nargin<2 || isempty(figureDir), figureDir=outputDir; end
if nargin<3, derivedFigureDir=''; end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
if ~exist(figureDir,'dir'), mkdir(figureDir); end
if ~isempty(derivedFigureDir) && ~exist(derivedFigureDir,'dir'), mkdir(derivedFigureDir); end

inc0=makeGame('INC-0',[5,-440;30,-20;360,0;58.5,0],[.7,4,1,2],[16;-15],.05,[.3,.7],[0,0],8);
incw=makeGame('INC-omega',[5,730;30,-295;360,0;180,0],[.5,2.5,.5,2],[21;-35],3,[.5,.5],[1,4],5);
omega0=inc0; omega0.name='same game, omega=0';
omegap=makeGame('same game, omega=0.25',[5,-440;30,-20;360,0;58.5,0],[.7,4,1,2],[16;-15],.05,[.3,.7],[.25,.25],8);

report=struct;
report.INC0=runGame(inc0);
report.INComega=runGame(incw);
report.sameGameOmega0=staticChecks(omega0);
report.sameGameOmegaPositive=staticChecks(omegap);
report.sigma=sigmaData();

plotDesignGeometry(inc0,omega0,omegap,report.INC0,fullfile(figureDir,'I1_design_geometry.png'));
plotSigma(report.sigma,fullfile(figureDir,'I1_sigma_budget.png'));
plotBeforeAfter(report.INC0,fullfile(figureDir,'I1_before_after.png'));
plotSupplement(report.INComega,fullfile(figureDir,'I1_INC_omega.png'));
if ~isempty(derivedFigureDir)
    plotTrajectoryCard(report.INC0,fullfile(derivedFigureDir,'I1_trajectory_card.png'));
    plotTransferCard(report.INC0,fullfile(derivedFigureDir,'I1_aggregate_transfer_card.png'));
end

writeConditionCsv(fullfile(outputDir,'i1_condition_checks.csv'),report);
writeTrajectoryCsv(fullfile(outputDir,'i1_trajectory_summary.csv'),report);
save(fullfile(outputDir,'i1_report.mat'),'report','inc0','incw','omega0','omegap');
fprintf('I1 outputs written to %s and %s\n',outputDir,figureDir);
fprintf('INC-0 budget max %.3g; INC-omega corrected budget max %.3g.\n', ...
    max(report.INC0.aggregateTransfer),max(report.INComega.aggregateTransfer));
end

function g=makeGame(name,bRows,eta,x0,sigma,zeta,omega,horizon)
g.name=name;
g.A=cat(3,[-4,1;1,-10],[-4,-1;-1,-3],[-16,8;8,-16],[-5,-1;-1,-2]);
g.b=bRows'; g.eta=eta(:)'; g.x0=x0; g.sigma=sigma; g.zeta=zeta(:)'; g.omega=omega(:)'; g.horizon=horizon;
g.AU=zeros(2); g.bU=zeros(2,1);
for j=1:4, g.AU=g.AU+g.eta(j)*g.A(:,:,j); g.bU=g.bU+g.eta(j)*g.b(:,j); end
g.target=-g.AU\g.bU;
g.At=cat(3,zeta(1)*sigma*g.AU-omega(1)*g.A(:,:,2),g.A(:,:,2), ...
    zeta(2)*sigma*g.AU-omega(2)*g.A(:,:,4),g.A(:,:,4));
g.bt=[zeta(1)*sigma*g.bU-omega(1)*g.b(:,2),g.b(:,2), ...
      zeta(2)*sigma*g.bU-omega(2)*g.b(:,4),g.b(:,4)];
g.ct=zeros(1,4);
g.ct(1)=pay(g.A(:,:,1),g.b(:,1),0,g.x0)-zeta(1)*sigma*pay(g.AU,g.bU,0,g.x0)+omega(1)*pay(g.A(:,:,2),g.b(:,2),0,g.x0);
g.ct(3)=pay(g.A(:,:,3),g.b(:,3),0,g.x0)-zeta(2)*sigma*pay(g.AU,g.bU,0,g.x0)+omega(2)*pay(g.A(:,:,4),g.b(:,4),0,g.x0);
end

function r=runGame(g)
sample=(0:.002:g.horizon)'; opts=odeset('RelTol',1e-10,'AbsTol',1e-12,'MaxStep',.01);
[to,xo]=ode45(@(~,x)rhs(g.A,g.b,x),sample,g.x0,opts);
[t,x]=ode45(@(~,z)rhs(g.At,g.bt,z),sample,g.x0,opts);
r=staticChecks(g); r.game=g; r.t=t; r.x=x; r.to=to; r.xo=xo;
r.originalOnOriginal=payoffChanges(g.A,g.b,zeros(1,4),xo,g.x0);
r.originalOnIncentivized=payoffChanges(g.A,g.b,zeros(1,4),x,g.x0);
r.modifiedOnIncentivized=payoffChanges(g.At,g.bt,g.ct,x,g.x0);
n=numel(t); r.aggregateTransfer=zeros(n,1); r.directTransfer=zeros(n,1); r.omittedOmegaTransfer=zeros(n,1);
r.weighted=zeros(n,2); r.externalityGamma=zeros(n,2);
for k=1:n
    z=x(k,:)'; dU=pay(g.AU,g.bU,0,z)-pay(g.AU,g.bU,0,g.x0);
    d=r.originalOnIncentivized(k,:);
    r.aggregateTransfer(k)=g.sigma*dU-(d(1)+g.omega(1)*d(2)+d(3)+g.omega(2)*d(4));
    r.directTransfer(k)=r.modifiedOnIncentivized(k,1)-d(1)+r.modifiedOnIncentivized(k,3)-d(3);
    r.omittedOmegaTransfer(k)=g.sigma*dU-d(1)-d(3);
    r.weighted(k,:)=[r.modifiedOnIncentivized(k,1)+g.omega(1)*d(2),r.modifiedOnIncentivized(k,3)+g.omega(2)*d(4)];
    f=rhs(g.At,g.bt,z); [full,~]=gradients(g.At,g.bt,z);
    r.externalityGamma(k,1)=(full(2,1)+g.omega(1)*full(2,2))*f(2);
    r.externalityGamma(k,2)=(full(1,3)+g.omega(2)*full(1,4))*f(1);
end
r.budgetIdentityMaxError=max(abs(r.aggregateTransfer-r.directTransfer));
r.sampledBudgetMax=max(r.aggregateTransfer); r.sampledGammaMin=min(r.externalityGamma,[],1);
r.originalTerminal=xo(end,:); r.incentivizedTerminal=x(end,:); r.targetDistance=norm(x(end,:)'-g.target);
end

function r=staticChecks(g)
r.name=g.name; r.target=g.target; r.Ueigen=eig(g.AU); r.ownCurvature=[g.At(1,1,1),g.At(1,1,2),g.At(2,2,3),g.At(2,2,4)];
r.branchDet=zeros(1,4); c=0;
for j1=1:2, for j2=3:4, c=c+1; r.branchDet(c)=det([g.At(1,:,j1);g.At(2,:,j2)]); end, end
[r.minPairDet,r.minTripleResidual]=generalPosition(g.At,g.bt);
r.anchor=[pay(g.At(:,:,1),g.bt(:,1),g.ct(1),g.x0)-pay(g.A(:,:,1),g.b(:,1),0,g.x0), ...
          pay(g.At(:,:,3),g.bt(:,3),g.ct(3),g.x0)-pay(g.A(:,:,3),g.b(:,3),0,g.x0)];
r.targetStationarity=[norm((g.At(:,:,1)+g.omega(1)*g.A(:,:,2))*g.target+g.bt(:,1)+g.omega(1)*g.b(:,2)), ...
                      norm((g.At(:,:,3)+g.omega(2)*g.A(:,:,4))*g.target+g.bt(:,3)+g.omega(2)*g.b(:,4))];
end

function [minDet,minResidual]=generalPosition(A,b)
rows=[A(1,:,1);A(1,:,2);A(2,:,3);A(2,:,4)]; offs=[b(1,1);b(1,2);b(2,3);b(2,4)]; ds=[]; rs=[];
for i=1:4, for j=i+1:4
    M=[rows(i,:);rows(j,:)]; ds(end+1)=abs(det(M)); %#ok<AGROW>
    if abs(det(M))>1e-12
        x=-M\[offs(i);offs(j)];
        for k=1:4, if k~=i && k~=j, rs(end+1)=abs(rows(k,:)*x+offs(k))/norm(rows(k,:)); end, end %#ok<AGROW>
    end
end, end
minDet=min(ds); minResidual=min(rs);
end

function f=rhs(A,b,x)
[~,h]=gradients(A,b,x); f=zeros(2,1);
for i=1:2
    ids=(2*i-1):(2*i); v=h(ids); if v(1)*v(2)<=0, continue; end
    rho=[abs(v(1)/A(i,i,ids(1))),abs(v(2)/A(i,i,ids(2)))];
    if rho(1)<=rho(2), j=ids(1); else, j=ids(2); end
    f(i)=h(j);
end
end

function [full,own]=gradients(A,b,x)
full=zeros(2,4); for j=1:4, full(:,j)=A(:,:,j)*x+b(:,j); end
own=[full(1,1),full(1,2),full(2,3),full(2,4)];
end

function v=pay(A,b,c,x), v=.5*x'*A*x+b'*x+c; end

function out=payoffChanges(A,b,c,X,x0)
n=size(X,1); out=zeros(n,4);
for j=1:4
    base=pay(A(:,:,j),b(:,j),c(j),x0);
    for k=1:n, out(k,j)=pay(A(:,:,j),b(:,j),c(j),X(k,:)')-base; end
end
end

function s=sigmaData()
s.A=cat(3,[-2,1;1,-3],[-2,-1;-1,-10],[-4,1;1,-4],[-5,-1;-1,-2]);
s.b=[5,20,90,72;-5,124,0,0]; s.eta=[1,3,1,3]; s.omega=[1,1]; s.x0=[18.5;-8.71];
s.AU=zeros(2);s.bU=zeros(2,1);for j=1:4,s.AU=s.AU+s.eta(j)*s.A(:,:,j);s.bU=s.bU+s.eta(j)*s.b(:,j);end
s.AJ=sum(s.A,3);s.bJ=s.b(:,1)+s.b(:,2)+s.b(:,3)+s.b(:,4);
p=[det(s.AU), -(s.AU(1,1)*s.AJ(2,2)+s.AU(2,2)*s.AJ(1,1)-2*s.AU(1,2)*s.AJ(1,2)),det(s.AJ)];
s.critical=sort(roots(p)); s.regimeSigma=[.35,.47,.56]; s.accSigma=[3,.551];
end

function plotDesignGeometry(g,g0,gp,r,path)
fig=figure('Color','w','Position',[80,80,1450,920]);
subplot(2,2,1); plotParetoNash(g); title('1  Social Pareto samples vs decentralized Nash set');
subplot(2,2,2); plotDomains(g); title('2  Target, x_0, welfare and budget boundaries');
subplot(2,2,3); plotOmegaCompare(g0,gp); title('3  Same game: omega moves the Nash geometry');
subplot(2,2,4); plot(r.xo(:,1),r.xo(:,2),'k--','LineWidth',1.8);hold on;plot(r.x(:,1),r.x(:,2),'m-','LineWidth',2);scatter(g.x0(1),g.x0(2),45,'k','filled');scatter(g.target(1),g.target(2),55,'b','filled');grid on;axis equal;xlabel('x^1');ylabel('x^2');legend('original','incentivized','x_0','target','Location','best');title('Behavior before and after incentive');
title('4  Behavior before and after incentive');
sgtitle({'I1 design: social Pareto/Nash -> domains -> same-game omega -> behavior', ...
    'Only J_1^i is modified; the finite endpoint is not identified with the target'});exportgraphics(fig,path,'Resolution',180);close(fig);
end

function plotParetoNash(g)
hold on; cols=lines(4); xx=linspace(-10,40,200); for j=1:4, owner=1+(j>2); row=g.A(owner,:,j); yy=-(row(1)*xx+g.b(owner,j))/row(2);plot(xx,yy,'Color',cols(j,:),'LineWidth',1.1,'HandleVisibility','off');end
pts=[]; step=.08; for w1=0:step:1,for w2=0:step:1-w1,for w3=0:step:1-w1-w2,w4=1-w1-w2-w3;w=[w1,w2,w3,w4];if sum(w>0)==0,continue;end;A=zeros(2);b=zeros(2,1);for j=1:4,A=A+w(j)*g.A(:,:,j);b=b+w(j)*g.b(:,j);end;if rcond(A)>1e-10,pts(end+1,:)=[-A\b]';end,end,end,end %#ok<AGROW>
hp=scatter(pts(:,1),pts(:,2),8,[.2,.65,.25],'filled','MarkerFaceAlpha',.25);
[X,Y]=meshgrid(linspace(-10,40,180),linspace(-50,25,180));mask=false(size(X));for k=1:numel(X),z=[X(k);Y(k)];[~,h]=gradients(g.A,g.b,z);mask(k)=h(1)*h(2)<=0 && h(3)*h(4)<=0;end;contourf(X,Y,double(mask),[.5,.5],'FaceColor',[.2,.35,.85],'FaceAlpha',.18,'LineStyle','none');
hn=patch(nan,nan,[.2,.35,.85],'FaceAlpha',.18,'EdgeColor','none');
xlim([-10,40]);ylim([-50,25]);grid on;xlabel('x^1');ylabel('x^2');legend([hp,hn],{'social Pareto samples','decentralized Nash set'},'Location','best');
end

function plotDomains(g)
[X,Y]=meshgrid(linspace(5,22,240),linspace(-20,2,240));U=zeros(size(X));J=zeros(size(X));B=zeros(size(X));
for k=1:numel(X),z=[X(k);Y(k)];U(k)=pay(g.AU,g.bU,0,z)-pay(g.AU,g.bU,0,g.x0);J(k)=pay(g.A(:,:,1)+g.A(:,:,3),g.b(:,1)+g.b(:,3),0,z)-pay(g.A(:,:,1)+g.A(:,:,3),g.b(:,1)+g.b(:,3),0,g.x0);B(k)=g.sigma*U(k)-J(k);end
contour(X,Y,U,[0,0],'b','LineWidth',2);hold on;contour(X,Y,J,[0,0],'r','LineWidth',2);contour(X,Y,B,[0,0],'m--','LineWidth',2);scatter(g.x0(1),g.x0(2),45,'k','filled');scatter(g.target(1),g.target(2),55,'b','filled');axis equal;grid on;xlabel('x^1');ylabel('x^2');legend('D(U,x_0)','D(J_{sum},x_0)','D_{bud}','x_0','target','Location','best');
end

function plotOmegaCompare(g0,gp)
xl=[8,18];yl=[-14,-5];[X,Y]=meshgrid(linspace(xl(1),xl(2),220),linspace(yl(1),yl(2),220));hold on;
h0=plot(nan,nan,'-','Color',[.85,.15,.15],'LineWidth',2);hp=plot(nan,nan,'--','Color',[.1,.35,.85],'LineWidth',2);
for k=1:2
    gg={g0,gp};gg=gg{k};mask=false(size(X));
    for n=1:numel(X),z=[X(n);Y(n)];[~,h]=gradients(gg.At,gg.bt,z);mask(n)=h(1)*h(2)<=0&&h(3)*h(4)<=0;end
    if k==1,contour(X,Y,double(mask),[.5,.5],'Color',[.85,.15,.15],'LineWidth',2);else,contour(X,Y,double(mask),[.5,.5],'Color',[.1,.35,.85],'LineWidth',2,'LineStyle','--');end
    for j=1:4,owner=1+(j>2);plotLineInBox(gg.At(owner,:,j),gg.bt(owner,j),xl,yl,([.85,.15,.15]*(k==1)+[.1,.35,.85]*(k==2)),k==2);end
end
ht=scatter(g0.target(1),g0.target(2),60,'k','filled');axis equal;xlim(xl);ylim(yl);grid on;xlabel('x^1');ylabel('x^2');legend([h0,hp,ht],{'omega=0 Nash boundary','omega=.25 Nash boundary','fixed target'},'Location','best');
end

function plotSigma(s,path)
fig=figure('Color','w','Position',[70,70,1550,850]); sigmas=[s.regimeSigma,s.accSigma]; titles={'0<sigma<sigma_1: ellipse','sigma_1<sigma<sigma_2: hyperbola','sigma>sigma_2: ellipse','ACC-style complement, sigma=3','ACC-style complement, sigma=.551'};
for p=1:5,subplot(2,3,p);budgetPanel(s,sigmas(p));title(titles{p});end
subplot(2,3,6);commonExclusionPanel(s);title('ACC common exclusion comparison');
sgtitle({'I1: sigma changes the budget-boundary topology', ...
    'Orange always means D_{bud}^c = {aggregate transfer > 0}; unshaded means the budget inequality holds'});exportgraphics(fig,path,'Resolution',180);close(fig);
end

function budgetPanel(s,sigma)
[X,Y]=meshgrid(linspace(-20,40,240),linspace(-25,50,240));B=zeros(size(X));U=zeros(size(X));J=zeros(size(X));
for k=1:numel(X),z=[X(k);Y(k)];U(k)=pay(s.AU,s.bU,0,z)-pay(s.AU,s.bU,0,s.x0);J(k)=pay(s.AJ,s.bJ,0,z)-pay(s.AJ,s.bJ,0,s.x0);B(k)=sigma*U(k)-J(k);end
contourf(X,Y,double(B>0),[.5,.5],'FaceColor',[.9,.5,.15],'FaceAlpha',.35,'LineStyle','none');hold on;contour(X,Y,U,[0,0],'b','LineWidth',1.8);contour(X,Y,J,[0,0],'r','LineWidth',1.8);contour(X,Y,B,[0,0],'k--','LineWidth',1.5);scatter(s.x0(1),s.x0(2),28,'k','filled');axis equal;xlim([-20,40]);ylim([-25,50]);grid on;xlabel('x^1');ylabel('x^2');
text(.02,.03,'orange: aggregate transfer > 0','Units','normalized','FontSize',8,'BackgroundColor','w','Margin',2);
end

function commonExclusionPanel(s)
[X,Y]=meshgrid(linspace(-20,40,240),linspace(-25,50,240));U=zeros(size(X));J=zeros(size(X));B1=zeros(size(X));B2=zeros(size(X));
for k=1:numel(X),z=[X(k);Y(k)];U(k)=pay(s.AU,s.bU,0,z)-pay(s.AU,s.bU,0,s.x0);J(k)=pay(s.AJ,s.bJ,0,z)-pay(s.AJ,s.bJ,0,s.x0);B1(k)=3*U(k)-J(k);B2(k)=.551*U(k)-J(k);end
contourf(X,Y,double(B1>0&B2>0),[.5,.5],'FaceColor',[.95,.75,.15],'FaceAlpha',.38,'LineStyle','none');hold on;contourf(X,Y,double(U>=0&J<0),[.5,.5],'FaceColor',[.2,.65,.3],'FaceAlpha',.55,'LineStyle','none');contour(X,Y,U,[0,0],'b','LineWidth',1.6);contour(X,Y,J,[0,0],'r','LineWidth',1.6);scatter(s.x0(1),s.x0(2),28,'k','filled');axis equal;xlim([-20,40]);ylim([-25,50]);grid on;xlabel('x^1');ylabel('x^2');text(.02,.98,{'yellow: intersection of the two budget complements','green: welfare-improving but weighted-payoff-decreasing set'},'Units','normalized','VerticalAlignment','top','Interpreter','none','FontSize',8,'BackgroundColor','w','Margin',2);
end

function plotBeforeAfter(r,path)
fig=figure('Color','w','Position',[80,80,1500,850]);labels={'J_1^1','J_2^1','J_1^2','J_2^2'};
subplot(2,2,1);xl=[3,21];yl=[-15.5,-4];hold on;for j=1:4,owner=1+(j>2);plotLineInBox(r.game.A(owner,:,j),r.game.b(owner,j),xl,yl,[.45,.45,.45],false);plotLineInBox(r.game.At(owner,:,j),r.game.bt(owner,j),xl,yl,[.2,.55,.85],true);end;hbr0=plot(nan,nan,'-','Color',[.45,.45,.45],'LineWidth',1.2);hbri=plot(nan,nan,'--','Color',[.2,.55,.85],'LineWidth',1.2);ho=plot(r.xo(:,1),r.xo(:,2),'k--','LineWidth',1.8);hi=plot(r.x(:,1),r.x(:,2),'m-','LineWidth',2);hx=scatter(r.game.x0(1),r.game.x0(2),40,'k','filled');ht=scatter(r.game.target(1),r.game.target(2),50,'b','filled');grid on;axis equal;xlim(xl);ylim(yl);legend([hbr0,hbri,ho,hi,hx,ht],{'original BR','incentivized BR','original trajectory','incentivized trajectory','x_0','target'},'Location','best');title('BR, Nash-boundary lines, and trajectories');xlabel('x^1');ylabel('x^2');
subplot(2,2,2);plot(r.to,r.originalOnOriginal,'LineWidth',1.4);yline(0,'k:');grid on;title('Original system: original payoff changes');legend(labels,'Location','best');xlabel('t');
subplot(2,2,3);plot(r.t,r.originalOnIncentivized,'LineWidth',1.4);yline(0,'k:');grid on;title('Incentivized path: original payoff changes');legend(labels,'Location','best');xlabel('t');
subplot(2,2,4);plot(r.t,r.modifiedOnIncentivized,'LineWidth',1.4);hold on;plot(r.t,r.aggregateTransfer,'k','LineWidth',2);yline(0,'k:');grid on;title('Modified payoffs and aggregate transfer');legend([labels,{'p^1+p^2'}],'Location','best');xlabel('t');ylabel('change from t=0');
text(.02,.04,'budget convention: p^1+p^2 <= 0','Units','normalized','FontWeight','bold','BackgroundColor','w','Margin',2);
sgtitle({sprintf('INC-0: before/after behavior; terminal distance to target = %.5f',r.targetDistance), ...
    'Algebra checked | trajectory observed | invariant-set containment unproved'});exportgraphics(fig,path,'Resolution',180);close(fig);
end

function plotSupplement(r,path)
fig=figure('Color','w','Position',[80,80,1500,850]);
subplot(2,2,1);plot(r.xo(:,1),r.xo(:,2),'k--','LineWidth',1.8);hold on;plot(r.x(:,1),r.x(:,2),'m-','LineWidth',2);scatter(r.game.x0(1),r.game.x0(2),45,'k','filled');scatter(r.game.target(1),r.game.target(2),55,'b','filled');axis equal;grid on;legend('original','incentivized','x_0','target');title('INC-omega trajectories');xlabel('x^1');ylabel('x^2');
subplot(2,2,2);plot(r.t,r.originalOnIncentivized,'LineWidth',1.3);yline(0,'k:');grid on;title('Original payoff changes on incentivized path');legend('J_1^1','J_2^1','J_1^2','J_2^2','Location','best');
subplot(2,2,3);plot(r.t,r.modifiedOnIncentivized,'LineWidth',1.3);hold on;plot(r.t,r.weighted,'--','LineWidth',1.8);yline(0,'k:');grid on;title('Modified payoffs and weighted combinations');legend('tilde J_1^1','J_2^1','tilde J_1^2','J_2^2','agent 1 weighted','agent 2 weighted','Location','best');
subplot(2,2,4);plot(r.t,r.aggregateTransfer,'k','LineWidth',2);hold on;plot(r.t,r.omittedOmegaTransfer,'r--','LineWidth',1.7);yline(0,'k:');grid on;title('Corrected budget versus legacy omitted-omega formula');legend('complete p^1+p^2','old formula missing omega terms','Location','best');xlabel('t');
sgtitle({'INC-omega supplementary experiment — DIFFERENT GAME', ...
    'Not a one-factor omega control; complete budget retains both omega-weighted terms'});exportgraphics(fig,path,'Resolution',180);close(fig);
end

function plotTrajectoryCard(r,path)
fig=figure('Color','w','Position',[100,100,900,650]);xl=[3,21];yl=[-15.5,-4];hold on;
for j=1:4,owner=1+(j>2);plotLineInBox(r.game.A(owner,:,j),r.game.b(owner,j),xl,yl,[.65,.65,.65],false);plotLineInBox(r.game.At(owner,:,j),r.game.bt(owner,j),xl,yl,[.2,.55,.85],true);end
h1=plot(r.xo(:,1),r.xo(:,2),'k--','LineWidth',2.2);h2=plot(r.x(:,1),r.x(:,2),'m-','LineWidth',2.6);
h3=scatter(r.game.x0(1),r.game.x0(2),70,'k','filled');h4=scatter(r.game.target(1),r.game.target(2),80,'b','filled');
grid on;axis equal;xlim(xl);ylim(yl);xlabel('x^1');ylabel('x^2');
legend([h1,h2,h3,h4],{'original trajectory','incentivized trajectory','x_0','target'},'Location','southoutside','NumColumns',2);
title({'Incentive changes behavior toward the target',sprintf('finite endpoint distance = %.5f (not zero)',r.targetDistance)});
exportgraphics(fig,path,'Resolution',180);close(fig);
end

function plotTransferCard(r,path)
fig=figure('Color','w','Position',[100,100,900,580]);
plot(r.t,r.aggregateTransfer,'k','LineWidth',2.8);hold on;yline(0,'r--','budget boundary');grid on;
xlabel('time t');ylabel('aggregate transfer  p^1+p^2');
title({'Complete aggregate budget along the observed INC-0 trajectory', ...
    sprintf('sign convention: feasible <= 0; sampled max = %.3g, min = %.3f',max(r.aggregateTransfer),min(r.aggregateTransfer))});
text(.02,.05,{'Algebra checked | trajectory observed','Invariant-set containment remains unproved'}, ...
    'Units','normalized','BackgroundColor','w','Margin',4,'FontWeight','bold');
exportgraphics(fig,path,'Resolution',180);close(fig);
end

function writeConditionCsv(path,r)
fid=fopen(path,'w');c=onCleanup(@()fclose(fid));fprintf(fid,'experiment,max_abs_p_x0,min_own_margin,min_branch_det,min_pair_det,min_triple_residual,max_target_stationarity,budget_identity_error,sampled_budget_max,sampled_gamma_min_1,sampled_gamma_min_2,target_distance\n');
for name={'INC0','INComega'},x=r.(name{1});fprintf(fid,'%s,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n',x.name,max(abs(x.anchor)),-max(x.ownCurvature),min(x.branchDet),x.minPairDet,x.minTripleResidual,max(x.targetStationarity),x.budgetIdentityMaxError,x.sampledBudgetMax,x.sampledGammaMin,x.targetDistance);end
end

function writeTrajectoryCsv(path,r)
fid=fopen(path,'w');c=onCleanup(@()fclose(fid));fprintf(fid,'experiment,original_terminal_x1,original_terminal_x2,incentivized_terminal_x1,incentivized_terminal_x2,target_x1,target_x2,aggregate_transfer_min,aggregate_transfer_final,omitted_omega_transfer_final\n');
for name={'INC0','INComega'},x=r.(name{1});fprintf(fid,'%s,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n',x.name,x.originalTerminal,x.incentivizedTerminal,x.target,min(x.aggregateTransfer),x.aggregateTransfer(end),x.omittedOmegaTransfer(end));end
end

function plotLineInBox(row,off,xl,yl,color,dashed)
pts=[];if abs(row(2))>1e-12,for x=xl,y=-(row(1)*x+off)/row(2);if y>=yl(1)&&y<=yl(2),pts(end+1,:)=[x,y];end,end,end %#ok<AGROW>
if abs(row(1))>1e-12,for y=yl,x=-(row(2)*y+off)/row(1);if x>=xl(1)&&x<=xl(2),pts(end+1,:)=[x,y];end,end,end %#ok<AGROW>
if size(pts,1)>=2,ls='-';if dashed,ls='--';end;plot(pts(1:2,1),pts(1:2,2),'Color',color,'LineStyle',ls,'LineWidth',1.2,'HandleVisibility','off');end
end
