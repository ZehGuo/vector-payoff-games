function report = run_s2_degenerate_noncompact(outputDir,assetDir)
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
if nargin<2, assetDir=''; end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
if ~isempty(assetDir) && ~exist(assetDir,'dir'), mkdir(assetDir); end

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
if ~isempty(assetDir)
    plotRankCard(degenerate(2),report.degenerate(2),fullfile(assetDir,'S2_rank_degenerate_stable_card.png'));
    plotRankCard(degenerate(5),report.degenerate(5),fullfile(assetDir,'S2_rank_degenerate_unstable_card.png'));
    for k=1:3
        plotNoncompactCard(noncompact(k),report.noncompact(k),fullfile(assetDir,sprintf('S2_noncompact_%s_card.png',noncompact(k).id)));
    end
end
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
        style='-'; marker='none';
        if k==5 && s==1, color=[.72,.08,.55]; width=2.5; style='--'; marker='>'; end
        plot(ax,tr(:,1),tr(:,2),style,'Color',color,'LineWidth',width,'Marker',marker,'MarkerIndices',round(linspace(1,size(tr,1),min(5,size(tr,1)))));
        plot(ax,tr(1,1),tr(1,2),'o','Color',color,'MarkerFaceColor',color,'MarkerSize',3);
        addTrajectoryArrow(ax,tr,color,.58);
    end
    plot(ax,0,0,'kp','MarkerFaceColor',[1,.75,.1],'MarkerSize',9);
    title(ax,sprintf('D%d: %s',k,ternary(games(k).expectedStable,'stable','unstable')),'Interpreter','none');
    if games(k).expectedStable
        criterion='all det>0 -> stable (Thm. 3.11)';
    else
        criterion='all det<0 -> unstable (Thm. 3.11)';
    end
    text(ax,.02,.97,criterion,'Units','normalized','VerticalAlignment','top','FontSize',8,'FontWeight','bold','BackgroundColor','w','Margin',2);
    xlabel(ax,'x^1'); ylabel(ax,'x^2');
end
ax=subplot(2,3,6,'Parent',fig); axis(ax,'off');
text(ax,0,.95,{'NEW CONSTRUCTION under Assumption 4','orange solid/dashed: agent 1 BRs','blue dash-dot/dotted: agent 2 BRs','purple fill: X*(J) in the shown window', ...
    'gold star: rank-zero Nash pinch','black + arrows: representative trajectories','magenta dashed + triangles: unstable witness', ...
    'Identity: determinant signs + Theorem 3.11.','Trajectories and the finite window illustrate only.'}, ...
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
        plot(ax,tr(:,1),tr(:,2),'--','Color',[.18,.18,.18],'LineWidth',1.05);
        plot(ax,tr(1,1),tr(1,2),'ko','MarkerFaceColor','k','MarkerSize',3);
        addTrajectoryArrow(ax,tr,[.18,.18,.18],.55);
    end
    dets=reshape([reports(k).branches.det],1,[]);
    title(ax,sprintf('%s: %s',games(k).id,games(k).label),'Interpreter','none');
    xlabel(ax,'x^1'); ylabel(ax,'x^2');
    text(ax,.02,.98,{sprintf('ANALYTIC CERTIFICATE: mixed det [%s]',strjoin(compose('%.2f',dets),', ')), ...
        '=> X*(J) noncompact (Proposition 3.1)'},'Units','normalized','VerticalAlignment','top', ...
        'FontSize',8,'FontWeight','bold','BackgroundColor','w','Margin',2);
    drawRecessionArrows(ax,games(k));
    text(ax,.02,.02,'Dashed trajectories and finite window: illustration only','Units','normalized', ...
        'FontSize',8,'BackgroundColor','w','Margin',2);
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
    styles1={'-','--'}; styles2={'-.',':'};
    plot(ax,xx,(xx-game.c(j))/game.p(j),styles1{j},'Color',[.86,.38,.08],'LineWidth',1.55);
    plot(ax,xx,game.q(j)*xx+game.d(j),styles2{j},'Color',[.08,.38,.72],'LineWidth',1.65);
end
end

function addTrajectoryArrow(ax,tr,color,fraction)
if size(tr,1)<3, return; end
i=max(1,min(size(tr,1)-1,round(fraction*(size(tr,1)-1))));d=tr(i+1,:)-tr(i,:);
if norm(d)>1e-12,quiver(ax,tr(i,1),tr(i,2),d(1),d(2),0,'Color',color,'LineWidth',1.2,'MaxHeadSize',1.8);end
end

function drawRecessionArrows(ax,game)
theta=linspace(0,2*pi,7201);theta(end)=[];chosen=[];
for k=1:numel(theta)
    v=[cos(theta(k));sin(theta(k))];a=-v(1)+game.p*v(2);b=game.q*v(1)-v(2);
    if a(1)*a(2)<=1e-12 && b(1)*b(2)<=1e-12,chosen=v;break;end
end
if isempty(chosen),return;end
w=game.window;span=.18*min(w(2)-w(1),w(4)-w(3));origin=.15*span*chosen;
quiver(ax,origin(1),origin(2),span*chosen(1),span*chosen(2),0,'Color',[.35,.05,.55],'LineWidth',3,'MaxHeadSize',.5);
quiver(ax,-origin(1),-origin(2),-span*chosen(1),-span*chosen(2),0,'Color',[.35,.05,.55],'LineWidth',3,'MaxHeadSize',.5);
text(ax,.53,.10,'recession direction','Units','normalized','Color',[.35,.05,.55],'FontWeight','bold','BackgroundColor','w','Margin',2);
end

function plotRankCard(game,report,path)
fig=figure('Color','w','Visible','off','Position',[60,60,720,760]);ax=axes(fig);hold(ax,'on');box(ax,'on');grid(ax,'on');axis(ax,'equal');
pts=[report.corners,report.otherSameAgentIntersection,[0;0]];lo=min(pts,[],2)-1.5;hi=max(pts,[],2)+1.5;
drawFieldAndNash(ax,game,[lo(1),hi(1),lo(2),hi(2)]);plot(ax,0,0,'kp','MarkerFaceColor',[1,.75,.1],'MarkerSize',11);
starts=representativeStarts(game,'degenerate');[~,tr]=simulate(game,starts(1,:)',5,.015);
if game.expectedStable,color=[.08,.08,.08];style='-';criterion='STABLE: all det(A)>0 (Theorem 3.11)';else,color=[.72,.08,.55];style='--';criterion='UNSTABLE: all det(A)<0 (Theorem 3.11)';end
plot(ax,tr(:,1),tr(:,2),style,'Color',color,'LineWidth',2.2,'Marker','>','MarkerIndices',round(linspace(1,size(tr,1),min(5,size(tr,1)))));addTrajectoryArrow(ax,tr,color,.58);
title(ax,sprintf('%s: rank-degenerate new construction',game.id));xlabel(ax,'x^1');ylabel(ax,'x^2');
text(ax,.03,.97,{'Assumption 4: rank-zero Nash pinch at gold star',criterion},'Units','normalized','VerticalAlignment','top','FontWeight','bold','BackgroundColor','w','Margin',3);
text(ax,.03,.03,'Trajectory is illustrative; determinant signs and theorem assumptions certify the case.','Units','normalized','FontSize',9,'BackgroundColor','w','Margin',2);
exportPng(fig,path);close(fig);
end

function plotNoncompactCard(game,report,path)
fig=figure('Color','w','Visible','off','Position',[60,60,720,760]);ax=axes(fig);hold(ax,'on');box(ax,'on');grid(ax,'on');axis(ax,'equal');
drawFieldAndNash(ax,game,game.window);drawRecessionArrows(ax,game);dets=reshape([report.branches.det],1,[]);
title(ax,sprintf('%s: noncompact Nash geometry',game.id));xlabel(ax,'x^1');ylabel(ax,'x^2');
text(ax,.03,.97,{sprintf('Mixed det [%s]',strjoin(compose('%.2f',dets),', ')),'=> noncompact by Proposition 3.1'}, ...
    'Units','normalized','VerticalAlignment','top','FontWeight','bold','BackgroundColor','w','Margin',3);
text(ax,.03,.03,'Recession arrow is geometric guidance; the finite window is not the proof.','Units','normalized','FontSize',9,'BackgroundColor','w','Margin',2);
exportPng(fig,path);close(fig);
end

function value=ternary(condition,a,b)
if condition,value=a;else,value=b;end
end

function exportPng(fig,path)
try
    exportgraphics(fig,path,'Resolution',160);
catch
    print(fig,path,'-dpng','-r160');
end
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
for k=1:numel(games)
    for j1=1:2
        for j2=1:2
            b=reports(k).branches(j1,j2); ev=b.eigenvalues;
            fprintf(fid,'%d,%d,%d,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n', ...
                k,j1,j2,b.A(1,1),b.A(1,2),b.A(2,1),b.A(2,2),b.det,real(ev(1)),imag(ev(1)),real(ev(2)),imag(ev(2)),reports(k).corners(:,2*(j1-1)+j2));
        end
    end
end
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
