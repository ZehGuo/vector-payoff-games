function report = run_s2_degenerate_noncompact(outputDir)
%RUN_S2_DEGENERATE_NONCOMPACT Reconstruct thesis Fig. 3.6/3.7 case content.
%
% This is a new, explicitly documented construction.  It does not claim that
% cdc2023 filenames or parameters reproduce the thesis figures.  State order is
% x=[x^1;x^2].  Agent 1 BRs are x^1=p_j*x^2+c_j and agent 2 BRs are
% x^2=q_j*x^1+d_j.  Every own curvature and sensitivity is one in magnitude,
% so the nearest-BR rule selects by |h_j^i| and ties select objective 1.

if nargin < 1 || isempty(outputDir)
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    outputDir = fullfile(repoRoot,'results','s2');
end
if ~exist(outputDir,'dir'), mkdir(outputDir); end

degenerate = defineDegenerateCases();
noncompact = defineNoncompactCases();
report.degenerate = diagnoseGames(degenerate,'degenerate');
report.noncompact = diagnoseGames(noncompact,'noncompact');

writeCaseSummary(fullfile(outputDir,'s2_case_summary.csv'),degenerate,report.degenerate);
writeBranchDiagnostics(fullfile(outputDir,'s2_branch_diagnostics.csv'),degenerate,report.degenerate);
writeNoncompactSummary(fullfile(outputDir,'s2_noncompact_summary.csv'),noncompact,report.noncompact);
writeTrajectories(fullfile(outputDir,'s2_trajectory_summary.csv'),degenerate,noncompact);
plotDegenerate(degenerate,report.degenerate,fullfile(outputDir,'S2_rank_degenerate_five_cases.png'));
plotNoncompact(noncompact,report.noncompact,fullfile(outputDir,'S2_noncompact_three_configurations.png'));
save(fullfile(outputDir,'s2_report.mat'),'degenerate','noncompact','report');

fprintf('S2 outputs written to %s\n',outputDir);
fprintf('Rank-degenerate set: four all-positive determinant cases and one all-negative case.\n');
fprintf('Noncompact set: three general-position games with mixed determinant signs.\n');
end

function games = defineDegenerateCases()
slopes = {
    [ 0.8, 0.3], [-0.6,-0.2]; ...
    [ 0.6, 0.4], [ 0.8, 0.2]; ...
    [-0.3,-0.7], [ 0.8, 0.5]; ...
    [ 0.8, 0.5], [-0.4, 0.3]; ...
    [ 1.1, 1.3], [ 2.0, 1.6]};
orders = {
    'p1>p2>0>q2>q1';
    'q1>p1>p2>q2>0';
    'q1>q2>0>p1>p2';
    'p1>p2>q2>0>q1';
    'q1>q2>p2>p1>0'};
labels = {'stable-CW','stable-real','stable-CCW','stable-mixed','unstable-saddle'};
for k=1:5
    g=makeGame(sprintf('D%d',k),labels{k},slopes{k,1},slopes{k,2}, ...
        [0,0],[1,-1],[-4,4,-4,4]);
    g.caseNumber=k; g.slopeOrder=orders{k}; g.expectedStable=k<5;
    g.source='new S2 construction; slopes reused from certified S1 case identities';
    games(k)=g; %#ok<AGROW>
end
end

function games = defineNoncompactCases()
% Each game satisfies general position but has mixed determinant signs.
% Proposition 3.1, rather than a finite plotting window, certifies noncompactness.
base(1)=makeGame('N1','one-saddle-branch funnel',[0.4,1.6],[0.5,1.0],[-1,1],[-1,1],[-10,10,-12,12]);
base(2)=makeGame('N2','three-saddle-branch funnel',[0.6,1.4],[0.8,2.0],[-2,1],[1,-2],[-10,10,-15,15]);
base(3)=makeGame('N3','opposite-wing geometry',[-0.8,0.8],[-0.7,1.8],[-1,1],[1,-1],[-10,10,-12,12]);
for k=1:3
    g=base(k); g.caseNumber=k; g.slopeOrder='mixed branch determinants';
    g.expectedStable=false;
    g.source='new S2 construction guided only by the major Fig. 3.7 geometries';
    games(k)=g; %#ok<AGROW>
end
end

function game=makeGame(id,label,p,q,c,d,window)
game.id=id; game.label=label; game.p=p; game.q=q; game.c=c; game.d=d;
game.alpha1=[1,1]; game.alpha2=[1,1]; game.window=window;
for j=1:2
    game.A{1,j}=[-1,p(j);p(j),-1]; game.b{1,j}=[c(j);0];
    game.A{2,j}=[-1,q(j);q(j),-1]; game.b{2,j}=[0;d(j)];
    game.constant{1,j}=0; game.constant{2,j}=0;
end
end

function reports=diagnoseGames(games,kind)
for k=1:numel(games)
    validateGeneralPosition(games(k));
    r=diagnoseOne(games(k));
    dets=reshape([r.branches.det],1,[]);
    if strcmp(kind,'degenerate')
        assert(isNash(games(k),[0;0]));
        h=ownGradients(games(k),[0;0]);
        assert(all(abs(h(1,:))<1e-12),'Agent 1 must have rank zero at the pinch point.');
        if games(k).expectedStable, assert(all(dets>0)); else, assert(all(dets<0)); end
        p2=sameAgentIntersection(games(k),2);
        assert(~isNash(games(k),p2),'Only the agent-1 BR intersection should be in X*.');
        r.rankZeroPoint=[0;0]; r.otherSameAgentIntersection=p2;
        r.theorem311Applies=true;
    else
        assert(any(dets>0)&&any(dets<0),'Noncompact certificate requires mixed signs.');
        r.rankZeroPoint=[NaN;NaN]; r.otherSameAgentIntersection=[NaN;NaN];
        r.theorem311Applies=false;
    end
    r.assumption1=true;
    r.assumption2=all(dets>0)||all(dets<0);
    r.noncompactCertificate=any(dets>0)&&any(dets<0);
    r.recession=sampleRecession(games(k));
    reports(k)=r; %#ok<AGROW>
end
end

function r=diagnoseOne(game)
r.branches=repmat(struct(),2,2); r.corners=zeros(2,4); n=0;
for j1=1:2
    for j2=1:2
        n=n+1;
        A=[-1,game.p(j1);game.q(j2),-1];
        xstar=A\(-[game.c(j1);game.d(j2)]);
        ev=eig(A);
        r.branches(j1,j2).j1=j1; r.branches(j1,j2).j2=j2;
        r.branches(j1,j2).A=A; r.branches(j1,j2).det=det(A);
        r.branches(j1,j2).eigenvalues=ev; r.corners(:,n)=xstar;
    end
end
end

function validateGeneralPosition(game)
tol=1e-9;
lines=[1,-game.p(1),-game.c(1);1,-game.p(2),-game.c(2); ...
       -game.q(1),1,-game.d(1);-game.q(2),1,-game.d(2)];
pairs=nchoosek(1:4,2);
for k=1:size(pairs,1)
    pair=pairs(k,:); M=lines(pair,1:2);
    assert(abs(det(M))>tol,'Parallel BR lines violate Assumption 1.');
    x=M\(-lines(pair,3)); other=setdiff(1:4,pair);
    assert(all(abs(lines(other,1:2)*x+lines(other,3))>tol),'Triple BR intersection.');
end
assert(all(abs(game.p)>tol)&&all(abs(game.q)>tol),'Axis-aligned BR line.');
end

function x=sameAgentIntersection(game,agent)
if agent==1
    x=[1,-game.p(1);1,-game.p(2)]\[game.c(1);game.c(2)];
else
    x=[-game.q(1),1;-game.q(2),1]\[game.d(1);game.d(2)];
end
end

function h=ownGradients(game,x)
h=[-x(1)+game.p*x(2)+game.c; game.q*x(1)-x(2)+game.d];
end

function j=chooseBranch(h)
if h(1)*h(2)<=0, j=0; elseif abs(h(1))<=abs(h(2)), j=1; else, j=2; end
end

function f=pseudoGradient(game,x)
h=ownGradients(game,x); j1=chooseBranch(h(1,:)); j2=chooseBranch(h(2,:));
f=[0;0]; if j1>0, f(1)=h(1,j1); end; if j2>0, f(2)=h(2,j2); end
end

function tf=isNash(game,x)
h=ownGradients(game,x); tf=h(1,1)*h(1,2)<=1e-10 && h(2,1)*h(2,2)<=1e-10;
end

function rec=sampleRecession(game)
theta=linspace(0,2*pi,7201); theta(end)=[]; inside=false(size(theta));
for k=1:numel(theta)
    v=[cos(theta(k));sin(theta(k))];
    a=-v(1)+game.p*v(2); b=game.q*v(1)-v(2);
    inside(k)=a(1)*a(2)<=1e-12 && b(1)*b(2)<=1e-12;
end
rec.sampleCount=sum(inside); rec.angleDegrees=360*mean(inside);
rec.hasNonzeroDirection=any(inside);
end

function [t,x]=simulate(game,x0,tFinal,dt)
n=ceil(tFinal/dt); t=zeros(n+1,1); x=zeros(n+1,2); x(1,:)=x0(:)';
for k=1:n
    y=x(k,:)'; k1=pseudoGradient(game,y); k2=pseudoGradient(game,y+.5*dt*k1);
    k3=pseudoGradient(game,y+.5*dt*k2); k4=pseudoGradient(game,y+dt*k3);
    z=y+dt*(k1+2*k2+2*k3+k4)/6; t(k+1)=k*dt; x(k+1,:)=z';
    if norm(z)>100 || (isNash(game,z)&&norm(pseudoGradient(game,z))<1e-10)
        t=t(1:k+1); x=x(1:k+1,:); return;
    end
end
end

function starts=representativeStarts(game,kind)
if strcmp(kind,'degenerate')
    starts=[-2,-1;2,-1;-2,2;2,2];
    if game.caseNumber==5, starts=[starts;0.45,0.65]; end
else
    w=game.window; starts=[w(1)+2,w(3)+2;w(2)-2,w(4)-2;w(1)+2,w(4)-2;w(2)-2,w(3)+2;0,0];
end
end

function plotDegenerate(games,reports,path)
fig=figure('Color','w','Visible','off','Position',[50,50,1500,850]);
for k=1:5
    ax=subplot(2,3,k,'Parent',fig); hold(ax,'on'); box(ax,'on'); grid(ax,'on'); axis(ax,'equal');
    pts=[reports(k).corners,reports(k).otherSameAgentIntersection,[0;0]];
    lo=min(pts,[],2)-1.5; hi=max(pts,[],2)+1.5;
    drawFieldAndNash(ax,games(k),[lo(1),hi(1),lo(2),hi(2)]);
    starts=representativeStarts(games(k),'degenerate');
    for s=1:size(starts,1)
        [~,tr]=simulate(games(k),starts(s,:)',5,0.015);
        color=[0.1,0.1,0.1]; width=1.0;
        if k==5 && s==1, color=[0.88,0.05,0.05]; width=2.3; end
        plot(ax,tr(:,1),tr(:,2),'-','Color',color,'LineWidth',width);
        plot(ax,tr(1,1),tr(1,2),'o','Color',color,'MarkerFaceColor',color,'MarkerSize',3);
    end
    plot(ax,0,0,'kp','MarkerFaceColor',[1,.75,.1],'MarkerSize',9);
    title(ax,sprintf('Case %d: %s',k,games(k).label),'Interpreter','none');
    xlabel(ax,'x^1'); ylabel(ax,'x^2');
end
ax=subplot(2,3,6,'Parent',fig); axis(ax,'off');
text(ax,0,.95,{'S2 rank-degenerate construction','red/blue: agent 1/2 BRs','purple: X*(J) in the shown window', ...
    'gold marker: rank-zero Nash pinch','black: representative trajectories','red: unstable representative', ...
    'Case identity: determinant signs + Theorem 3.11.','The finite window is not a compactness proof.'}, ...
    'VerticalAlignment','top','FontSize',11);
exportPng(fig,path); close(fig);
end

function plotNoncompact(games,reports,path)
fig=figure('Color','w','Visible','off','Position',[50,50,1500,520]);
for k=1:3
    ax=subplot(1,3,k,'Parent',fig); hold(ax,'on'); box(ax,'on'); grid(ax,'on'); axis(ax,'equal');
    drawFieldAndNash(ax,games(k),games(k).window);
    starts=representativeStarts(games(k),'noncompact');
    for s=1:size(starts,1)
        [~,tr]=simulate(games(k),starts(s,:)',7,0.015);
        plot(ax,tr(:,1),tr(:,2),'k-','LineWidth',1.05);
        plot(ax,tr(1,1),tr(1,2),'ko','MarkerFaceColor','k','MarkerSize',3);
    end
    dets=reshape([reports(k).branches.det],1,[]);
    title(ax,{sprintf('%s: %s',games(k).id,games(k).label), ...
        sprintf('mixed det [%s]',strjoin(compose('%.2f',dets),', '))},'Interpreter','none');
    xlabel(ax,'x^1'); ylabel(ax,'x^2');
    text(ax,.02,.02,'noncompact by Prop. 3.1 (mixed signs)','Units','normalized', ...
        'FontSize',9,'BackgroundColor','w','Margin',2);
end
exportPng(fig,path); close(fig);
end

function drawFieldAndNash(ax,game,window)
xlim(ax,window(1:2)); ylim(ax,window(3:4));
[X,Y]=meshgrid(linspace(window(1),window(2),151),linspace(window(3),window(4),151));
mask=false(size(X));
for n=1:numel(X), mask(n)=isNash(game,[X(n);Y(n)]); end
contourf(ax,X,Y,double(mask),[.5,.5],'FaceColor',[.62,.38,.70],'FaceAlpha',.30,'LineColor','none');
[Xq,Yq]=meshgrid(linspace(window(1),window(2),19),linspace(window(3),window(4),19)); U=zeros(size(Xq)); V=U;
for n=1:numel(Xq)
    f=pseudoGradient(game,[Xq(n);Yq(n)]); z=max(norm(f),1e-12); U(n)=f(1)/z; V(n)=f(2)/z;
end
quiver(ax,Xq,Yq,U,V,.42,'Color',[.65,.69,.76],'LineWidth',.55);
xx=linspace(window(1),window(2),500);
for j=1:2
    plot(ax,xx,(xx-game.c(j))/game.p(j),'Color',[.85,.15+.18*(j-1),.18],'LineWidth',1.35);
    plot(ax,xx,game.q(j)*xx+game.d(j),'Color',[.10,.33+.19*(j-1),.85],'LineWidth',1.35);
end
end

function exportPng(fig,path)
try, exportgraphics(fig,path,'Resolution',160); catch, print(fig,path,'-dpng','-r160'); end
end

function writeCaseSummary(path,games,reports)
fid=fopen(path,'w'); cleaner=onCleanup(@() fclose(fid));
fprintf(fid,'case,label,p1,p2,q1,q2,c1,c2,d1,d2,det_min,det_max,stability,rank_zero_x1,rank_zero_x2,other_intersection_x1,other_intersection_x2,assumption1,assumption2,theorem311_applies\n');
for k=1:numel(games)
    dets=reshape([reports(k).branches.det],1,[]);
    if games(k).expectedStable, st='asymptotically stable'; else, st='unstable'; end
    o=reports(k).otherSameAgentIntersection;
    fprintf(fid,'%d,%s,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%s,0,0,%.12g,%.12g,1,1,1\n', ...
        k,games(k).label,games(k).p,games(k).q,games(k).c,games(k).d,min(dets),max(dets),st,o(1),o(2));
end
end

function writeBranchDiagnostics(path,games,reports)
fid=fopen(path,'w'); cleaner=onCleanup(@() fclose(fid));
fprintf(fid,'case,j1,j2,a11,a12,a21,a22,det,eig1_real,eig1_imag,eig2_real,eig2_imag,corner_x1,corner_x2\n');
for k=1:numel(games), for j1=1:2, for j2=1:2
    b=reports(k).branches(j1,j2); ev=b.eigenvalues;
    fprintf(fid,'%d,%d,%d,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n', ...
        k,j1,j2,b.A(1,1),b.A(1,2),b.A(2,1),b.A(2,2),b.det,real(ev(1)),imag(ev(1)),real(ev(2)),imag(ev(2)),reports(k).corners(:,2*(j1-1)+j2));
end, end, end
end

function writeNoncompactSummary(path,games,reports)
fid=fopen(path,'w'); cleaner=onCleanup(@() fclose(fid));
fprintf(fid,'case,label,p1,p2,q1,q2,c1,c2,d1,d2,det11,det12,det21,det22,assumption1,assumption2,theorem311_applies,mixed_sign_certificate,recession_angle_sample_deg\n');
for k=1:numel(games)
    dets=[reports(k).branches(1,1).det,reports(k).branches(1,2).det,reports(k).branches(2,1).det,reports(k).branches(2,2).det];
    fprintf(fid,'%s,%s,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,1,0,0,1,%.12g\n', ...
        games(k).id,games(k).label,games(k).p,games(k).q,games(k).c,games(k).d,dets,reports(k).recession.angleDegrees);
end
end

function writeTrajectories(path,degenerate,noncompact)
fid=fopen(path,'w'); cleaner=onCleanup(@() fclose(fid));
fprintf(fid,'group,case,trajectory,x0_1,x0_2,t_final,x_final_1,x_final_2,final_is_nash,max_norm\n');
groups={degenerate,noncompact}; names={'degenerate','noncompact'};
for g=1:2, games=groups{g};
    for k=1:numel(games)
        starts=representativeStarts(games(k),names{g});
        for s=1:size(starts,1)
            [t,x]=simulate(games(k),starts(s,:)',7,0.015);
            fprintf(fid,'%s,%s,%d,%.12g,%.12g,%.12g,%.12g,%.12g,%d,%.12g\n', ...
                names{g},games(k).id,s,starts(s,:),t(end),x(end,:),isNash(games(k),x(end,:)'),max(vecnorm(x,2,2)));
        end
    end
end
end
