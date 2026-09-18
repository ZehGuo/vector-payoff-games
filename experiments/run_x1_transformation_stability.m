function report = run_x1_transformation_stability(outputDir)
%RUN_X1_TRANSFORMATION_STABILITY Rebuild the IFAC-extension transformation example.
%
% This entry keeps three objects separate:
%   (1) x(t), integrated in the original state space;
%   (2) eta(x(t)), evaluated pointwise on that trajectory; and
%   (3) z(t), integrated independently from z(0)=eta(x0) with (50).
% No inverse image is selected on a collapsed axis.  The paper's printed
% certificate is verified before either trajectory is integrated.

if nargin < 1 || isempty(outputDir)
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    outputDir = fullfile(repoRoot,'results','x1');
end
if ~exist(outputDir,'dir'), mkdir(outputDir); end

game = defineGame();
certificate = verifyPrintedCertificate(game);
assert(certificate.passes,'The printed certificate failed; do not continue to trajectories.');

dt = 1e-3;
tFinal = 5;
x0 = [6.5;-10];
[t,x] = integrateRK4(@(y) originalRhs(game,y),x0,tFinal,dt);
etaImage = zeros(size(x));
originalBranch = zeros(size(x));
for k = 1:size(x,1)
    [etaImage(k,:),originalBranch(k,:)] = etaMap(game,x(k,:)');
end
z0 = etaImage(1,:)';
[tz,z] = integrateRK4(@(y) transformedRhs(game,y),z0,tFinal,dt);
assert(isequal(t,tz),'The two integrations must use the same fixed time grid.');

separation = vecnorm(etaImage-z,2,2);
firstSeparated = find(separation > 1e-3,1,'first');
axisMask = any(originalBranch==0,2) & ~all(originalBranch==0,2);
axisRuns = contiguousRuns(axisMask);
assert(~isempty(firstSeparated) && ~isempty(axisRuns), ...
    'Expected a mapped/independent split and a one-active original segment.');
% The first one-active run is the A-to-B interval where the two eta-space
% curves first split.  Later one-active runs are retained in the CSV.
run = axisRuns(1,:);

branchCheck = verifyBranchConsistency(game);
boundaryCheck = verifyBoundaries(game,certificate);
fprintf('Branch check: points=%d residual=%.12g pass=%d.\n', ...
    branchCheck.fullActiveGridPoints,branchCheck.maxChainRuleResidual,branchCheck.passes);
fprintf('Boundary check: tie=[%d,%d], tie gap=%.12g, V jumps=[%.12g,%.12g], pass=%d.\n', ...
    boundaryCheck.tieSelection(1),boundaryCheck.tieSelection(2), ...
    abs(boundaryCheck.tieDistances(1,1)-boundaryCheck.tieDistances(1,2)), ...
    boundaryCheck.axisVJumpHorizontal,boundaryCheck.axisVJumpVertical,boundaryCheck.passes);
assert(branchCheck.passes && boundaryCheck.passes,'Branch or boundary checks failed.');

Vimage = lyapunovValues(etaImage,certificate);
Vz = lyapunovValues(z,certificate);
plotDomainMap(game,fullfile(outputDir,'x1_domain_map.png'));
plotFiberCollapse(game,fullfile(outputDir,'x1_fiber_collapse.png'));
plotTrajectories(game,t,x,etaImage,z,run,certificate, ...
    fullfile(outputDir,'x1_trajectories_lyapunov.png'));
writeTrajectories(fullfile(outputDir,'x1_trajectories.csv'), ...
    t,x,etaImage,z,originalBranch,separation,Vimage,Vz);

report = struct();
report.source = 'IFAC extension Section V printed parameters';
report.stateOrder = {'x^1','x^2'};
report.objectiveOrder = {'J_1^1','J_2^1','J_1^2','J_2^2'};
report.selectionRule = 'nearest BR; inactive when own gradients have opposite signs or zero product';
report.tieRuleOriginal = 'equal active distances choose objective 1';
report.axisRuleTransformed = 'z_i <= 0 chooses objective 1; z_i > 0 chooses objective 2';
report.inverseOnAxes = 'undefined/set-valued; no representative returned';
report.dt = dt;
report.tFinal = tFinal;
report.x0 = x0;
report.eta0Computed = z0;
report.eta0Printed = [-2.5;-13.5];
report.eta0PrintedResidual = norm(z0-report.eta0Printed);
report.firstSeparationTime = t(firstSeparated);
report.maxSeparation = max(separation);
report.axisSegmentTime = [t(run(1)),t(run(2))];
report.axisSegmentBranches = originalBranch(run(1),:);
report.axisSegmentEtaEndpoints = [etaImage(run(1),:);etaImage(run(2),:)];
report.axisSegmentNormEndpoints = [norm(etaImage(run(1),:));norm(etaImage(run(2),:))];
report.imageNormPositiveSteps = sum(diff(vecnorm(etaImage,2,2))>1e-8);
report.imageVPositiveSteps = sum(diff(Vimage)>1e-8);
report.independentVPositiveSteps = sum(diff(Vz)>1e-8);
report.certificate = certificate;
report.branchCheck = branchCheck;
report.boundaryCheck = boundaryCheck;
save(fullfile(outputDir,'x1_report.mat'),'game','report','t','x','etaImage','z');

fprintf('X1 outputs written to %s\n',outputDir);
fprintf('Printed certificate strict margins: decay %.6g, positivity %.6g.\n', ...
    certificate.strictDecayMargin,certificate.strictPositivityMargin);
fprintf('Computed eta(x0)=[%.6g, %.6g], not the printed [%.6g, %.6g].\n', ...
    z0(1),z0(2),report.eta0Printed(1),report.eta0Printed(2));
fprintf('Mapped and independently integrated trajectories first separate at t=%.6g.\n', ...
    report.firstSeparationTime);
end

function game = defineGame()
game.A = cell(2,2); game.b = cell(2,2);
game.A{1,1}=[-2,-1;-1,-3]; game.b{1,1}=[8;0];
game.A{1,2}=[-4,-4;-4,-12]; game.b{1,2}=[30;0];
game.A{2,1}=[-7,1;1,-2]; game.b{2,1}=[4;0];
game.A{2,2}=[-3,1;1,-1]; game.b{2,2}=[12;0];
game.alpha=[0.5,0.25;5,1];
end

function cert = verifyPrintedCertificate(game)
% Paper equations (58)-(60), using the four-decimal T printed in Section V.
T=[6.2058,-1.0547,-2.5757,0.1138; ...
  -1.0547,4.3862,3.9895,0.6236; ...
  -2.5757,3.9895,6.2058,-2.8365; ...
   0.1138,0.6236,-2.8365,4.3862];
U=[0,1;1,0]; W=U;
assert(all(U(:)>=0) && all(W(:)>=0),'U and W must be entrywise nonnegative.');
template=struct('selected',[],'Atilde',[],'E',[],'P',[], ...
    'decayEigenvalues',[],'positivityEigenvalues',[], ...
    'maxDecayEigenvalue',NaN,'minPositivityEigenvalue',NaN);
branches=repmat(template,2,2);
worstDecay=-Inf; smallestPositive=Inf;
for j1=1:2
    for j2=1:2
        R=coordinateMatrix(game,j1,j2);
        D=diag([game.alpha(1,j1)*game.A{1,j1}(1,1), ...
                game.alpha(2,j2)*game.A{2,j2}(2,2)]);
        At=R*D;
        E=diag([2*j1-3,2*j2-3]);
        F=[E;eye(2)]; P=F'*T*F;
        decay=At'*P+P*At+E'*U*E;
        positivity=P-E'*W*E;
        decayEig=eig((decay+decay')/2);
        positivityEig=eig((positivity+positivity')/2);
        branches(j1,j2)=struct('selected',[j1,j2],'Atilde',At,'E',E,'P',P, ...
            'decayEigenvalues',decayEig,'positivityEigenvalues',positivityEig, ...
            'maxDecayEigenvalue',max(decayEig), ...
            'minPositivityEigenvalue',min(positivityEig));
        worstDecay=max(worstDecay,max(decayEig));
        smallestPositive=min(smallestPositive,min(positivityEig));
    end
end
cert=struct('T',T,'U',U,'W',W,'branches',branches, ...
    'entrywiseNonnegativeU',all(U(:)>=0),'entrywiseNonnegativeW',all(W(:)>=0), ...
    'worstDecayEigenvalue',worstDecay, ...
    'smallestPositivityEigenvalue',smallestPositive, ...
    'strictDecayMargin',-worstDecay,'strictPositivityMargin',smallestPositive, ...
    'passes',worstDecay<0 && smallestPositive>0);
end

function R=coordinateMatrix(game,j1,j2)
R=[game.A{1,j1}(1,:)/game.A{1,j1}(1,1); ...
   game.A{2,j2}(2,:)/game.A{2,j2}(2,2)];
end

function [eta,selected,distances]=etaMap(game,x)
eta=zeros(2,1); selected=zeros(2,1); distances=zeros(2,2);
for i=1:2
    d=zeros(1,2);
    for j=1:2
        d(j)=(game.A{i,j}(i,:)*x+game.b{i,j}(i))/game.A{i,j}(i,i);
    end
    distances(i,:)=d;
    if d(1)*d(2)<=0
        selected(i)=0; eta(i)=0;
    elseif abs(d(1))<=abs(d(2))
        selected(i)=1; eta(i)=d(1);
    else
        selected(i)=2; eta(i)=d(2);
    end
end
eta=eta'; selected=selected';
end

function f=originalRhs(game,x)
[~,selected]=etaMap(game,x); f=zeros(2,1);
for i=1:2
    j=selected(i);
    if j>0
        f(i)=game.alpha(i,j)*(game.A{i,j}(i,:)*x+game.b{i,j}(i));
    end
end
end

function f=transformedRhs(game,z)
% Equation (50) is integrated directly.  This is not eta(x(t)).
% The axes have no unique original inverse; only a deterministic forward
% branch is chosen here.  The nonpositive side uses objective 1.
j=[1+(z(1)>0),1+(z(2)>0)];
R=coordinateMatrix(game,j(1),j(2));
D=diag([game.alpha(1,j(1))*game.A{1,j(1)}(1,1), ...
        game.alpha(2,j(2))*game.A{2,j(2)}(2,2)]);
f=R*D*z;
end

function [t,y]=integrateRK4(rhs,y0,tFinal,dt)
n=round(tFinal/dt); t=(0:n)'*dt; y=zeros(n+1,numel(y0)); y(1,:)=y0(:)';
for k=1:n
    q=y(k,:)'; k1=rhs(q); k2=rhs(q+dt*k1/2);
    k3=rhs(q+dt*k2/2); k4=rhs(q+dt*k3);
    y(k+1,:)=(q+dt*(k1+2*k2+2*k3+k4)/6)';
end
end

function runs=contiguousRuns(mask)
edges=diff([false;mask(:);false]); starts=find(edges==1); stops=find(edges==-1)-1;
runs=[starts,stops];
end

function out=verifyBranchConsistency(game)
[X,Y]=meshgrid(linspace(-5,16,91),linspace(-11,8,83));
maxResidual=0; count=0; outsideAssumedSignMap=0;
for k=1:numel(X)
    x=[X(k);Y(k)]; [eta,selected]=etaMap(game,x);
    if all(selected>0) && all(abs(eta)>1e-8)
        signSelected=[1+(eta(1)>0),1+(eta(2)>0)];
        if any(signSelected~=selected)
            outsideAssumedSignMap=outsideAssumedSignMap+1;
            continue;
        end
        lhs=coordinateMatrix(game,selected(1),selected(2))*originalRhs(game,x);
        rhs=transformedRhs(game,eta');
        maxResidual=max(maxResidual,norm(lhs-rhs)); count=count+1;
    end
end
out=struct('fullActiveGridPoints',count,'maxChainRuleResidual',maxResidual, ...
    'fullActivePointsOutsideAssumedSignMap',outsideAssumedSignMap, ...
    'passes',count>0 && maxResidual<1e-10);
end

function out=verifyBoundaries(game,cert)
% Active distance ties choose objective 1 in etaMap, matching legacy <=.
xTie=[7;7]; [~,selTie,distTie]=etaMap(game,xTie);
% On z axes no inverse is requested.  Adjacent P matrices must agree on-axis.
z1=[1;0]; z2=[0;1];
v12=z1'*cert.branches(1,1).P*z1-z1'*cert.branches(1,2).P*z1;
v21=z2'*cert.branches(1,1).P*z2-z2'*cert.branches(2,1).P*z2;
out=struct('tieProbe',xTie,'tieDistances',distTie,'tieSelection',selTie, ...
    'axisInverseReturned',false,'axisVJumpHorizontal',abs(v12), ...
    'axisVJumpVertical',abs(v21),'passes',selTie(1)==1 && ...
    abs(distTie(1,1)-distTie(1,2))<1e-12 && abs(v12)<1e-12 && abs(v21)<1e-12);
end

function V=lyapunovValues(Z,cert)
V=zeros(size(Z,1),1);
for k=1:size(Z,1)
    j=[1+(Z(k,1)>0),1+(Z(k,2)>0)]; P=cert.branches(j(1),j(2)).P;
    V(k)=Z(k,:)*P*Z(k,:)';
end
end

function plotDomainMap(game,path)
fig=figure('Color','w','Visible','off','Position',[40,40,1500,690]);
palette=domainPalette(); xBounds=[0,12]; yBounds=[-11,7];
[X,Y]=meshgrid(linspace(xBounds(1),xBounds(2),300),linspace(yBounds(1),yBounds(2),300));
C=zeros(size(X)); E=zeros(numel(X),2);
for k=1:numel(X)
    [e,s]=etaMap(game,[X(k);Y(k)]); C(k)=3*s(1)+s(2); E(k,:)=e;
end

ax1=subplot(1,2,1,'Parent',fig);hold(ax1,'on');axis(ax1,'equal');box(ax1,'on');
imagesc(ax1,X(1,:),Y(:,1),C);set(ax1,'YDir','normal');colormap(ax1,palette);caxis(ax1,[-.5,8.5]);
plotGameGeometry(ax1,game,xBounds,yBounds,true);
for code=0:8
    mask=C==code;
    if any(mask(:))
        text(ax1,median(X(mask)),median(Y(mask)),domainLabel(code), ...
            'HorizontalAlignment','center','FontWeight','bold','FontSize',9, ...
            'BackgroundColor','w','Margin',1);
    end
end
xlim(ax1,xBounds);ylim(ax1,yBounds);grid(ax1,'on');
xlabel(ax1,'x^1');ylabel(ax1,'x^2');
title(ax1,{'Original partition inside D_1^1 \cap D_1^2', ...
    'purple X^*(J)=D^{(0,0)}; curves are the four BR boundaries'});

ax2=subplot(1,2,2,'Parent',fig);hold(ax2,'on');axis(ax2,'equal');box(ax2,'on');grid(ax2,'on');
% The pale backgrounds indicate signs only.  Colored samples are the actual
% images of the finite original-space window; no full quadrant is claimed.
patch(ax2,[0,8,8,0],[0,0,8,8],[.88,.88,.88],'FaceAlpha',.18,'EdgeColor','none');
patch(ax2,[-10,0,0,-10],[0,0,8,8],[.88,.88,.88],'FaceAlpha',.18,'EdgeColor','none');
patch(ax2,[-10,0,0,-10],[-14,-14,0,0],[.88,.88,.88],'FaceAlpha',.18,'EdgeColor','none');
patch(ax2,[0,8,8,0],[-14,-14,0,0],[.88,.88,.88],'FaceAlpha',.18,'EdgeColor','none');
for code=[4,5,7,8,1,2,3,6]
    mask=C(:)==code;
    scatter(ax2,E(mask,1),E(mask,2),5,palette(code+1,:),'.');
end
plot(ax2,[-10,8],[0,0],'k-','LineWidth',1.6);plot(ax2,[0,0],[-14,8],'k-','LineWidth',1.6);
plot(ax2,0,0,'o','Color',palette(1,:),'MarkerFaceColor',palette(1,:),'MarkerSize',9);
for code=1:8
    mask=C(:)==code;
    if any(mask)
        p=median(E(mask,:),1); offset=.18*[sign(p(1)+(p(1)==0)),sign(p(2)+(p(2)==0))];
        text(ax2,p(1)+offset(1),p(2)+offset(2),domainLabel(code), ...
            'FontWeight','bold','FontSize',9,'BackgroundColor','w','Margin',1);
    end
end
text(ax2,.25,.25,'D^{(0,0)}','FontWeight','bold','Color',palette(1,:),'BackgroundColor','w');
xlim(ax2,[-10,8]);ylim(ax2,[-14,8]);
xlabel(ax2,'$\tilde{x}^1=\eta^1(x)$','Interpreter','latex');
ylabel(ax2,'$\tilde{x}^2=\eta^2(x)$','Interpreter','latex');
title(ax2,{'Actual image subsets of the same local window', ...
    '2-D domains \rightarrow quadrant subsets; strips \rightarrow axes; Nash \rightarrow origin'});
exportgraphics(fig,path,'Resolution',160);close(fig);
end

function plotFiberCollapse(game,path)
fig=figure('Color','w','Visible','off','Position',[40,40,1500,650]);
palette=domainPalette(); xBounds=[0,12]; yBounds=[-11,7]; targets=[1,0;2,0;0,1;0,2];
[X,Y]=meshgrid(linspace(xBounds(1),xBounds(2),260),linspace(yBounds(1),yBounds(2),260));
kappa=zeros(4,1);
for q=1:4
    vals=[];
    for k=1:numel(X)
        [e,s]=etaMap(game,[X(k);Y(k)]);
        if all(s==targets(q,:)), vals(end+1)=e(1+(targets(q,1)==0)); end %#ok<AGROW>
    end
    vals=sort(vals);kappa(q)=vals(max(1,round(.55*numel(vals))));
end

ax1=subplot(1,2,1,'Parent',fig);hold(ax1,'on');axis(ax1,'equal');box(ax1,'on');grid(ax1,'on');
plotGameGeometry(ax1,game,xBounds,yBounds,false);
fiberHandles=gobjects(4,1);
for q=1:4
    [fx,fy]=fiberPoints(game,targets(q,:),kappa(q),xBounds,yBounds);
    code=3*targets(q,1)+targets(q,2); col=palette(code+1,:);
    fiberHandles(q)=plot(ax1,fx,fy,'-','Color',col,'LineWidth',4);
    keep=find(isfinite(fx));
    if ~isempty(keep)
        marks=keep(round(linspace(1,numel(keep),min(6,numel(keep)))));
        plot(ax1,fx(marks),fy(marks),'o','Color',col,'MarkerFaceColor','w','MarkerSize',5);
    end
end
xlim(ax1,xBounds);ylim(ax1,yBounds);xlabel(ax1,'x^1');ylabel(ax1,'x^2');
title(ax1,{'Representative rank-one fibers in the original space', ...
    'multiple marked x values on each fiber have exactly the same image'});
fiberLabels=cell(1,4);
for q=1:4
    fiberLabels{q}=sprintf('$D^{(%d,%d)}, %ckappa=%+.2f$', ...
        targets(q,1),targets(q,2),char(92),kappa(q));
end
legend(fiberHandles,fiberLabels,'Interpreter','latex','Location','southwest');

ax2=subplot(1,2,2,'Parent',fig);hold(ax2,'on');axis(ax2,'equal');box(ax2,'on');grid(ax2,'on');
plot(ax2,[-10,8],[0,0],'k-','LineWidth',1.6);plot(ax2,[0,0],[-14,8],'k-','LineWidth',1.6);
for q=1:4
    code=3*targets(q,1)+targets(q,2); col=palette(code+1,:);
    if targets(q,1)>0, p=[kappa(q),0]; else, p=[0,kappa(q)]; end
    plot(ax2,p(1),p(2),'o','Color',col,'MarkerFaceColor',col,'MarkerSize',11);
    dy=.25;if all(targets(q,:)==[1,0]),dy=.75;end
    text(ax2,p(1)+.25,p(2)+dy,sprintf('$\\eta(L_{\\kappa}^{%d,%d})=(%+.2f,%+.2f)$', ...
        targets(q,1),targets(q,2),p(1),p(2)),'Interpreter','latex', ...
        'Color',col,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','left');
end
plot(ax2,0,0,'o','Color',palette(1,:),'MarkerFaceColor',palette(1,:),'MarkerSize',11);
text(ax2,.25,-.65,'\eta(X^*(J))=(0,0)','Color',palette(1,:),'FontWeight','bold','BackgroundColor','w');
xlim(ax2,[-10,12]);ylim(ax2,[-14,8]);
xlabel(ax2,'$\tilde{x}^1=\eta^1(x)$','Interpreter','latex');
ylabel(ax2,'$\tilde{x}^2=\eta^2(x)$','Interpreter','latex');
title(ax2,{'Fibers collapse to single axis points', ...
    'the inverse on an axis is set-valued; no representative is selected'});
exportgraphics(fig,path,'Resolution',160);close(fig);
end

function plotTrajectories(game,t,x,etaImage,z,run,cert,path)
fig=figure('Color','w','Visible','off','Position',[40,40,1500,880]);
ax1=subplot(2,2,1,'Parent',fig);hold(ax1,'on');axis(ax1,'equal');box(ax1,'on');grid(ax1,'on');
[X,Y]=meshgrid(linspace(-5,16,160),linspace(-11,8,150)); Z=zeros(size(X));
for k=1:numel(X), e=etaMap(game,[X(k);Y(k)]); Z(k)=lyapunovValues(e,cert); end
plotGameGeometry(ax1,game,[-5,16],[-11,8],false);
contour(ax1,X,Y,Z,[5,20,50,100,200,400],'Color',[.45,.55,.45]);
plot(ax1,x(:,1),x(:,2),'Color',[0,.45,.15],'LineWidth',2.2);
plot(ax1,x(run(1):run(2),1),x(run(1):run(2),2),'Color',[.90,.25,.05],'LineWidth',3.0);
plot(ax1,x(1,1),x(1,2),'ko','MarkerFaceColor','k');
plot(ax1,x(run(1),1),x(run(1),2),'o','Color',[.90,.25,.05],'MarkerFaceColor','w','LineWidth',1.5);
plot(ax1,x(run(2),1),x(run(2),2),'o','Color',[.90,.25,.05],'MarkerFaceColor',[.90,.25,.05]);
text(ax1,x(run(1),1)+.25,x(run(1),2),'A','FontWeight','bold');
text(ax1,x(run(2),1)+.25,x(run(2),2),'B','FontWeight','bold');
xlim(ax1,[-5,16]);ylim(ax1,[-11,8]);xlabel(ax1,'x^1');ylabel(ax1,'x^2');
title(ax1,{'(1) independently integrated original x(t)','contours: pullback V(\eta(x)) on original grid'});

ax2=subplot(2,2,2,'Parent',fig);hold(ax2,'on');axis(ax2,'equal');box(ax2,'on');grid(ax2,'on');
[E1,E2]=meshgrid(linspace(-10,8,180),linspace(-14,8,180)); G=[E1(:),E2(:)]; VG=lyapunovValues(G,cert);
[~,hContour]=contour(ax2,E1,E2,reshape(VG,size(E1)),[5,20,50,100,200,400],'Color',[.45,.55,.45]);
plot(ax2,[-10,8],[0,0],'k-','LineWidth',1.2,'HandleVisibility','off');
plot(ax2,[0,0],[-14,8],'k-','LineWidth',1.2,'HandleVisibility','off');
hEta=plot(ax2,etaImage(:,1),etaImage(:,2),'-','Color',[0,.45,.15],'LineWidth',2.3);
hZ=plot(ax2,z(:,1),z(:,2),'--','Color',[.55,0,.75],'LineWidth',2.3);
hSegment=plot(ax2,etaImage(run(1):run(2),1),etaImage(run(1):run(2),2),'-','Color',[.90,.25,.05],'LineWidth',3);
hInitial=plot(ax2,etaImage(1,1),etaImage(1,2),'ko','MarkerFaceColor','k');
plot(ax2,etaImage(run(1),1),etaImage(run(1),2),'o','Color',[.90,.25,.05],'MarkerFaceColor','w','LineWidth',1.5);
plot(ax2,etaImage(run(2),1),etaImage(run(2),2),'o','Color',[.90,.25,.05],'MarkerFaceColor',[.90,.25,.05]);
text(ax2,etaImage(run(1),1)+.25,etaImage(run(1),2),'\eta(A)','FontWeight','bold');
text(ax2,etaImage(run(2),1)+.25,etaImage(run(2),2),'\eta(B)','FontWeight','bold');
xlim(ax2,[-10,8]);ylim(ax2,[-14,8]);
xlabel(ax2,'$\tilde{x}^1$','Interpreter','latex');ylabel(ax2,'$\tilde{x}^2$','Interpreter','latex');
title(ax2,{'(2) solid: pointwise image \eta(x(t))','(3) dashed: independently integrated transformed z(t)'});
legend(ax2,[hContour,hEta,hZ,hSegment,hInitial], ...
    {'V contours','\eta(x(t))','z(t) independent','mapped one-active segment','common initial value'}, ...
    'Location','northeast');

ax3=subplot(2,2,3,'Parent',fig);hold(ax3,'on');box(ax3,'on');grid(ax3,'on');
plot(ax3,t,vecnorm(etaImage,2,2),'Color',[0,.45,.15],'LineWidth',1.7);
plot(ax3,t,vecnorm(z,2,2),'--','Color',[.55,0,.75],'LineWidth',1.7);
xline(ax3,t(run(1)),'Color',[.90,.25,.05]);xline(ax3,t(run(2)),'Color',[.90,.25,.05]);
xlabel(ax3,'t');ylabel(ax3,'Euclidean norm');title(ax3,'Norm can temporarily increase; this is not instability by itself');
legend(ax3,{'||\eta(x(t))||_2','||z(t)||_2','separation segment bounds'});

ax4=subplot(2,2,4,'Parent',fig);hold(ax4,'on');box(ax4,'on');grid(ax4,'on');
plot(ax4,t,lyapunovValues(etaImage,cert),'Color',[0,.45,.15],'LineWidth',1.7);
plot(ax4,t,lyapunovValues(z,cert),'--','Color',[.55,0,.75],'LineWidth',1.7);
xlabel(ax4,'t');ylabel(ax4,'V');title(ax4,'Piecewise-quadratic certificate along both eta-space curves');
legend(ax4,{'V(\eta(x(t)))','V(z(t)) independent'});
exportgraphics(fig,path,'Resolution',160);close(fig);
end

function palette=domainPalette()
% Codes are 3*j1+j2.  D^(0,0) is purple and all corresponding original/image
% pieces retain the same color across the two mapping figures.
palette=[.55,.20,.70; .15,.45,.85; .05,.68,.82; .90,.42,.12; ...
         .90,.72,.18; .64,.78,.25; .78,.20,.18; .30,.68,.30; .12,.55,.22];
end

function label=domainLabel(code)
j1=floor(code/3);j2=mod(code,3);label=sprintf('D^{(%d,%d)}',j1,j2);
end

function plotGameGeometry(ax,game,xBounds,yBounds,showAssumptionBoundary)
% Draw the four own-gradient zero sets and the exact Nash polygon.
verts=zeros(4,2); q=0;
for j1=1:2
    for j2=1:2
        q=q+1;R=coordinateMatrix(game,j1,j2);
        r=[game.b{1,j1}(1)/game.A{1,j1}(1,1);game.b{2,j2}(2)/game.A{2,j2}(2,2)];
        verts(q,:)=(-R\r)';
    end
end
h=convhull(verts(:,1),verts(:,2));
palette=domainPalette();
patch(ax,verts(h,1),verts(h,2),palette(1,:),'FaceAlpha',.50, ...
    'EdgeColor',[.40,.08,.52],'LineWidth',2.4);
xx=linspace(xBounds(1),xBounds(2),500); cols={[.72,.10,.10],[.95,.45,.05],[.08,.30,.78],[.00,.58,.65]};q=0;
for i=1:2
    for j=1:2
        q=q+1;A=game.A{i,j};b=game.b{i,j};
        if i==1, yy=-(A(1,1)*xx+b(1))/A(1,2);else, yy=-(A(2,1)*xx+b(2))/A(2,2);end
        plot(ax,xx,yy,'Color',cols{q},'LineWidth',1.35);
    end
end
if showAssumptionBoundary
    xline(ax,0,'k--','LineWidth',1.0);yline(ax,7,'k--','LineWidth',1.0);
end
xlim(ax,xBounds);ylim(ax,yBounds);
end

function [fx,fy]=fiberPoints(game,target,kappa,xBounds,yBounds)
t=linspace(0,1,700);fx=nan(size(t));fy=nan(size(t));
if target(1)>0
    row=game.A{1,target(1)}(1,:)/game.A{1,target(1)}(1,1);
    r=game.b{1,target(1)}(1)/game.A{1,target(1)}(1,1);
    fy=yBounds(1)+(yBounds(2)-yBounds(1))*t;fx=(kappa-r-row(2)*fy)/row(1);
else
    row=game.A{2,target(2)}(2,:)/game.A{2,target(2)}(2,2);
    r=game.b{2,target(2)}(2)/game.A{2,target(2)}(2,2);
    fx=xBounds(1)+(xBounds(2)-xBounds(1))*t;fy=(kappa-r-row(1)*fx)/row(2);
end
for k=1:numel(t)
    if fx(k)<xBounds(1)||fx(k)>xBounds(2)||fy(k)<yBounds(1)||fy(k)>yBounds(2)
        fx(k)=nan;fy(k)=nan;continue
    end
    [~,s]=etaMap(game,[fx(k);fy(k)]);
    if any(s~=target),fx(k)=nan;fy(k)=nan;end
end
end

function writeTrajectories(path,t,x,e,z,b,sep,Ve,Vz)
fid=fopen(path,'w');cleaner=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'t,x1,x2,eta_x1,eta_x2,z1_independent,z2_independent,j1_original,j2_original,separation,V_eta_x,V_z\n');
for k=1:numel(t)
    fprintf(fid,'%.9g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%d,%d,%.12g,%.12g,%.12g\n', ...
        t(k),x(k,1),x(k,2),e(k,1),e(k,2),z(k,1),z(k,2),b(k,1),b(k,2),sep(k),Ve(k),Vz(k));
end
end
