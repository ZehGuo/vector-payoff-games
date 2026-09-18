function report = run_s1_five_cases(outputDir)
%RUN_S1_FIVE_CASES Rebuild the five two-agent stability cases from T Remark 3.9.
%
%   REPORT = RUN_S1_FIVE_CASES() constructs four stable slope configurations
%   and one unstable configuration, checks every double-active branch, and
%   writes comparable figures and CSV diagnostics to results/s1.
%
%   The construction is new: it is not a claim that the parameters reproduce
%   the legacy ifac2023 files or the thesis figure pixel-for-pixel.  State order
%   is x = [x^1;x^2], and J_j^i uses superscript i for the agent and subscript j
%   for the objective.  All sensitivities are one, so nearest-BR and
%   scaled-own-gradient selection agree globally in these examples.

if nargin < 1 || isempty(outputDir)
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    outputDir = fullfile(repoRoot, 'results', 's1');
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

cases = defineCases();
report = diagnoseCase(cases(1));
validateCase(cases(1), report(1));
for k = 2:numel(cases)
    report(k) = diagnoseCase(cases(k));
    validateCase(cases(k), report(k));
end

writeCaseSummary(fullfile(outputDir, 's1_case_summary.csv'), cases, report);
writeBranchDiagnostics(fullfile(outputDir, 's1_branch_diagnostics.csv'), cases, report);
plotOverview(cases, report, fullfile(outputDir, 's1_five_case_overview.png'));
plotTransitionExplanation(cases, report, ...
    fullfile(outputDir, 's1_eigenvectors_and_transitions.png'));
save(fullfile(outputDir, 's1_report.mat'), 'cases', 'report');

fprintf('S1 outputs written to %s\n', outputDir);
fprintf('Cases 1-4: every branch det(A)>0 and Hurwitz.\n');
fprintf('Case 5: every branch det(A)<0; the plotted active-cone eigenray has lambda>0.\n');
end

function cases = defineCases()
% Slopes use [s_1^1,s_2^1] for agent 1 and [s_1^2,s_2^2]
% for agent 2.  The two lines of agent 1 meet at p1, and the two lines of
% agent 2 meet at p2.  Their separation ensures Assumption 3 on the compact
% Nash set while keeping the five panels visually comparable.
p1 = [5;6];
p2 = [6;5];
slopes = {
    [ 0.8,  0.3], [-0.6, -0.2]; ... % Case 1
    [ 0.6,  0.4], [ 0.8,  0.2]; ... % Case 2
    [-0.3, -0.7], [ 0.8,  0.5]; ... % Case 3
    [ 0.8,  0.5], [-0.4,  0.3]; ... % Case 4
    [ 1.1,  1.3], [ 2.0,  1.6]  ... % Case 5
    };
orders = {
    's_1^1 > s_2^1 > 0 > s_2^2 > s_1^2';
    's_1^2 > s_1^1 > s_2^1 > s_2^2 > 0';
    's_1^2 > s_2^2 > 0 > s_1^1 > s_2^1';
    's_1^1 > s_2^1 > s_2^2 > 0 > s_1^2';
    's_1^2 > s_2^2 > s_2^1 > s_1^1 > 0'
    };
labels = {'stable-CW', 'stable-real', 'stable-CCW', ...
    'stable-mixed', 'unstable-saddle'};

for k = 1:5
    s1 = slopes{k,1};
    s2 = slopes{k,2};
    c1 = p1(1) - s1*p1(2);
    c2 = p2(2) - s2*p2(1);
    cases(k).id = k; %#ok<AGROW>
    cases(k).label = labels{k};
    cases(k).expectedStable = k < 5;
    cases(k).slopeOrder = orders{k};
    cases(k).s1 = s1;
    cases(k).s2 = s2;
    cases(k).c1 = c1;
    cases(k).c2 = c2;
    cases(k).alpha1 = [1,1];
    cases(k).alpha2 = [1,1];
    cases(k).p1 = p1;
    cases(k).p2 = p2;
    % Symmetric quadratic representatives.  Only row 1 for agent 1 and
    % row 2 for agent 2 enter the pseudo-gradient.
    for j = 1:2
        cases(k).A{1,j} = [-1,s1(j);s1(j),-1];
        cases(k).b{1,j} = [c1(j);0];
        cases(k).A{2,j} = [-1,s2(j);s2(j),-1];
        cases(k).b{2,j} = [0;c2(j)];
        cases(k).constant{1,j} = 0;
        cases(k).constant{2,j} = 0;
    end
end
end

function out = diagnoseCase(game)
out.vertices = zeros(2,4);
out.branches = repmat(struct(), 2, 2);
q = 0;
for j1 = 1:2
    for j2 = 1:2
        q = q + 1;
        A = [-1,game.s1(j1);game.s2(j2),-1];
        rhs = [game.c1(j1);game.c2(j2)];
        xStar = [1,-game.s1(j1);-game.s2(j2),1]\rhs;
        [V,D] = eig(A);
        values = diag(D);
        [~,order] = sort(real(values),'descend');
        values = values(order);
        V = V(:,order);
        [coneStart,coneEnd,coneAngle] = selectedCone(game,xStar,[j1,j2]);
        realEigenvectors = isreal(values);
        eigenRayInCone = false(2,2);
        if realEigenvectors
            for ell = 1:2
                v = real(V(:,ell));
                eigenRayInCone(ell,1) = branchAt(game,xStar+1e-6*v) == 10*j1+j2;
                eigenRayInCone(ell,2) = branchAt(game,xStar-1e-6*v) == 10*j1+j2;
            end
        end
        transition = transitionType(A,coneAngle,values,eigenRayInCone);
        out.vertices(:,q) = xStar;
        out.branches(j1,j2).j1 = j1;
        out.branches(j1,j2).j2 = j2;
        out.branches(j1,j2).A = A;
        out.branches(j1,j2).det = det(A);
        out.branches(j1,j2).eigenvalues = values;
        out.branches(j1,j2).eigenvectors = V;
        out.branches(j1,j2).realEigenvectors = realEigenvectors;
        out.branches(j1,j2).eigenRayInCone = eigenRayInCone;
        out.branches(j1,j2).coneStart = coneStart;
        out.branches(j1,j2).coneEnd = coneEnd;
        out.branches(j1,j2).coneAngle = coneAngle;
        out.branches(j1,j2).transition = transition;
    end
end
out.vertexOrder = convexOrder(out.vertices);
out.transitionCounts = zeros(1,3);
for j1 = 1:2
    for j2 = 1:2
        tr = out.branches(j1,j2).transition;
        if startsWith(tr,'0-transitive'), out.transitionCounts(1) = out.transitionCounts(1)+1; end
        if startsWith(tr,'1-transitive'), out.transitionCounts(2) = out.transitionCounts(2)+1; end
        if startsWith(tr,'2-transitive'), out.transitionCounts(3) = out.transitionCounts(3)+1; end
    end
end
end

function validateCase(game, diagOut)
tol = 1e-10;
assert(all(abs(game.s1) > tol) && all(abs(game.s2) > tol), ...
    'Assumption 1 requires non-axis-aligned BR lines.');
assert(abs(game.s1(1)-game.s1(2)) > tol && abs(game.s2(1)-game.s2(2)) > tol, ...
    'Same-agent BR lines must not be parallel.');
lines = [1,-game.s1(1),-game.c1(1); ...
         1,-game.s1(2),-game.c1(2); ...
         -game.s2(1),1,-game.c2(1); ...
         -game.s2(2),1,-game.c2(2)];
pairs = nchoosek(1:4,2);
for q = 1:size(pairs,1)
    chosen = pairs(q,:);
    coefficient = lines(chosen,1:2);
    assert(abs(det(coefficient)) > tol, 'Two BR lines are parallel.');
    intersection = coefficient\(-lines(chosen,3));
    other = setdiff(1:4,chosen);
    assert(all(abs(lines(other,1:2)*intersection+lines(other,3)) > 1e-8), ...
        'Three BR lines share an intersection.');
end
dets = zeros(1,4);
q = 0;
for j1 = 1:2
    for j2 = 1:2
        q = q+1;
        dets(q) = diagOut.branches(j1,j2).det;
        assert(abs(dets(q)) > tol, 'A scalar-payoff Nash corner is singular.');
    end
end
if game.expectedStable
    assert(all(dets > 0), 'Stable Case %d has a nonpositive branch determinant.',game.id);
else
    assert(all(dets < 0), 'Unstable Case 5 must have four negative determinants.');
    hasWitness = false;
    for j1 = 1:2
        for j2 = 1:2
            b = diagOut.branches(j1,j2);
            hasWitness = hasWitness || any(real(b.eigenvalues) > 0 & any(b.eigenRayInCone,2));
        end
    end
    assert(hasWitness, 'Case 5 lacks a positive active-cone eigenray witness.');
end
% Rank Assumption 3: neither same-agent BR intersection lies in the other strip.
assert(~isNash(game,game.p1) && ~isNash(game,game.p2), ...
    'The same-agent BR intersection entered the Nash set (rank-zero geometry).');
end

function code = branchAt(game,x)
h1 = -x(1) + game.s1*x(2) + game.c1;
h2 = game.s2*x(1) - x(2) + game.c2;
b1 = chooseBranch(h1);
b2 = chooseBranch(h2);
code = 10*b1+b2;
end

function b = chooseBranch(h)
if h(1)*h(2) <= 0
    b = 0;
elseif abs(h(1)) <= abs(h(2))
    b = 1;
else
    b = 2;
end
end

function f = pseudoGradient(game,x)
h1 = -x(1) + game.s1*x(2) + game.c1;
h2 = game.s2*x(1) - x(2) + game.c2;
j1 = chooseBranch(h1);
j2 = chooseBranch(h2);
f = zeros(2,1);
if j1 > 0, f(1) = game.alpha1(j1)*h1(j1); end
if j2 > 0, f(2) = game.alpha2(j2)*h2(j2); end
end

function tf = isNash(game,x)
h1 = -x(1) + game.s1*x(2) + game.c1;
h2 = game.s2*x(1) - x(2) + game.c2;
tf = h1(1)*h1(2) <= 1e-10 && h2(1)*h2(2) <= 1e-10;
end

function [startAngle,endAngle,span] = selectedCone(game,xStar,pair)
theta = linspace(0,2*pi,1441);
theta(end) = [];
inside = false(size(theta));
for k = 1:numel(theta)
    x = xStar + 1e-6*[cos(theta(k));sin(theta(k))];
    inside(k) = branchAt(game,x) == 10*pair(1)+pair(2);
end
assert(any(inside),'No local double-active cone found.');
% Rotate the circular mask to begin just after an outside sample.
outside = find(~inside,1,'first');
rot = [inside(outside+1:end),inside(1:outside)];
edges = diff([false,rot,false]);
i0 = find(edges==1);
i1 = find(edges==-1)-1;
[runLength,which] = max(i1-i0+1);
firstIndex = mod(outside+i0(which)-1,numel(theta))+1;
lastIndex = mod(firstIndex+runLength-1-1,numel(theta))+1;
startAngle = theta(firstIndex);
endAngle = theta(lastIndex);
span = runLength*2*pi/numel(theta);
end

function label = transitionType(A,coneAngle,values,eigenRayInCone)
if det(A) < 0
    if any(real(values) > 0 & any(eigenRayInCone,2))
        label = 'unstable non-transitive eigenray';
    else
        label = 'saddle: stable eigenray / outward generic flow';
    end
elseif A(1,2)*A(2,1) < 0
    if A(2,1) < 0
        label = '1-transitive clockwise';
    else
        label = '1-transitive counterclockwise';
    end
elseif coneAngle < pi/2
    label = '0-transitive';
else
    label = '2-transitive';
end
end

function order = convexOrder(vertices)
center = mean(vertices,2);
angles = atan2(vertices(2,:)-center(2),vertices(1,:)-center(1));
[~,order] = sort(angles);
end

function [t,x] = simulateFixedStep(game,x0,tFinal,dt)
n = ceil(tFinal/dt);
t = zeros(n+1,1);
x = zeros(n+1,2);
x(1,:) = x0(:)';
for k = 1:n
    y = x(k,:)';
    k1 = pseudoGradient(game,y);
    k2 = pseudoGradient(game,y+0.5*dt*k1);
    k3 = pseudoGradient(game,y+0.5*dt*k2);
    k4 = pseudoGradient(game,y+dt*k3);
    yNext = y + dt*(k1+2*k2+2*k3+k4)/6;
    t(k+1) = k*dt;
    x(k+1,:) = yNext';
    if norm(yNext) > 100 || (isNash(game,yNext) && norm(pseudoGradient(game,yNext)) < 1e-9)
        t = t(1:k+1);
        x = x(1:k+1,:);
        return;
    end
end
end

function plotOverview(cases,report,path)
fig = figure('Color','w','Visible','off','Position',[60,60,1450,850]);
for k = 1:5
    ax = subplot(2,3,k,'Parent',fig);
    hold(ax,'on'); axis(ax,'equal'); box(ax,'on'); grid(ax,'on');
    vertices = report(k).vertices;
    ord = report(k).vertexOrder;
    allPoints = [vertices,cases(k).p1,cases(k).p2];
    lo = min(allPoints,[],2)-1.0;
    hi = max(allPoints,[],2)+1.0;
    if k == 5, hi = hi+0.8; end
    xlim(ax,[lo(1),hi(1)]); ylim(ax,[lo(2),hi(2)]);
    [X,Y] = meshgrid(linspace(lo(1),hi(1),14),linspace(lo(2),hi(2),14));
    U = zeros(size(X)); V = U;
    for q = 1:numel(X)
        f = pseudoGradient(cases(k),[X(q);Y(q)]);
        scale = max(norm(f),1e-12);
        U(q) = f(1)/scale; V(q) = f(2)/scale;
    end
    quiver(ax,X,Y,U,V,0.38,'Color',[0.72,0.76,0.82],'LineWidth',0.6);
    patch(ax,vertices(1,ord),vertices(2,ord),[0.65,0.42,0.72], ...
        'FaceAlpha',0.38,'EdgeColor',[0.42,0.19,0.48],'LineWidth',1.2);
    xx = linspace(lo(1),hi(1),300);
    for j = 1:2
        yy1 = (xx-cases(k).c1(j))/cases(k).s1(j);
        plot(ax,xx,yy1,'Color',[0.82,0.20+0.18*(j-1),0.20],'LineWidth',1.25);
        yy2 = cases(k).s2(j)*xx+cases(k).c2(j);
        plot(ax,xx,yy2,'Color',[0.15,0.36+0.18*(j-1),0.82],'LineWidth',1.25);
    end
    center = mean(vertices,2);
    radius = max(vecnorm(vertices-center,2,1))+0.75;
    initialAngles = linspace(0,2*pi,6); initialAngles(end)=[];
    for q = 1:numel(initialAngles)
        x0 = center + radius*[cos(initialAngles(q));sin(initialAngles(q))];
        [~,traj] = simulateFixedStep(cases(k),x0,4,0.03);
        plot(ax,traj(:,1),traj(:,2),'k-','LineWidth',0.9);
        plot(ax,traj(1,1),traj(1,2),'ko','MarkerSize',2.5,'MarkerFaceColor','k');
    end
    if k == 5
        b = report(k).branches(1,2);
        pos = find(real(b.eigenvalues)>0,1);
        v = real(b.eigenvectors(:,pos));
        xStar = report(k).vertices(:,2);
        if branchAt(cases(k),xStar+1e-4*v) ~= 12, v=-v; end
        x0 = xStar+0.06*v/norm(v);
        [~,traj] = simulateFixedStep(cases(k),x0,2.2,0.015);
        plot(ax,traj(:,1),traj(:,2),'-','Color',[0.85,0.05,0.05],'LineWidth',2.4);
    end
    title(ax,sprintf('Case %d: %s',k,cases(k).label),'Interpreter','none');
    xlabel(ax,'x^1'); ylabel(ax,'x^2');
end
ax = subplot(2,3,6,'Parent',fig); axis(ax,'off');
text(ax,0,0.92,{'Common construction','red: agent 1 BRs','blue: agent 2 BRs', ...
    'purple: Nash set','black: multiple trajectories','red trajectory: positive-eigenvalue witness', ...
    'Case identity is certified by slopes, branch matrices,','eigenstructure and active-cone transitions - not endpoints.'}, ...
    'VerticalAlignment','top','FontSize',11);
try
    exportgraphics(fig,path,'Resolution',120);
catch
    print(fig,path,'-dpng','-r180');
end
close(fig);
end

function plotTransitionExplanation(cases,report,path)
examples = [2,1,1; 2,1,2; 1,1,1; 5,1,2];
titles = {'0-transitive: larger eigenvalue ray inside', ...
    '2-transitive: smaller eigenvalue ray separates exits', ...
    '1-transitive: complex pair, clockwise exit', ...
    'unstable: positive eigenvalue ray remains active'};
fig = figure('Color','w','Visible','off','Position',[80,80,1300,780]);
for q = 1:4
    k=examples(q,1); j1=examples(q,2); j2=examples(q,3);
    b=report(k).branches(j1,j2);
    ax=subplot(2,2,q,'Parent',fig); hold(ax,'on'); axis(ax,'equal'); box(ax,'on'); grid(ax,'on');
    lim=1.15; xlim(ax,[-lim,lim]); ylim(ax,[-lim,lim]);
    theta=linspace(b.coneStart,b.coneStart+b.coneAngle,100);
    patch(ax,[0,cos(theta),0],[0,sin(theta),0],[0.90,0.86,0.95], ...
        'EdgeColor','none','FaceAlpha',0.75);
    plot(ax,[0,cos(b.coneStart)],[0,sin(b.coneStart)],'k-','LineWidth',1.3);
    plot(ax,[0,cos(b.coneStart+b.coneAngle)],[0,sin(b.coneStart+b.coneAngle)],'k-','LineWidth',1.3);
    if b.realEigenvectors
        for ell=1:2
            v=real(b.eigenvectors(:,ell)); v=v/norm(v);
            for sign=[-1,1]
                if b.eigenRayInCone(ell,(sign<0)+1)
                    color=[0.85,0.10,0.10]; width=2.6;
                else
                    color=[0.35,0.35,0.35]; width=1.0;
                end
                quiver(ax,0,0,sign*v(1),sign*v(2),0,'Color',color,'LineWidth',width,'MaxHeadSize',0.2);
            end
        end
    else
        sample=linspace(b.coneStart+0.08,b.coneStart+b.coneAngle-0.08,7);
        for a=sample
            y=0.72*[cos(a);sin(a)]; f=b.A*y; f=0.25*f/max(norm(f),1e-12);
            quiver(ax,y(1),y(2),f(1),f(2),0,'Color',[0.12,0.40,0.78],'LineWidth',1.0);
        end
    end
    title(ax,sprintf('Case %d, branch (%d,%d)\n%s',k,j1,j2,titles{q}), ...
        'Interpreter','none','FontSize',10);
    xlabel(ax,'x^1-x_*^1'); ylabel(ax,'x^2-x_*^2');
end
try
    exportgraphics(fig,path,'Resolution',120);
catch
    print(fig,path,'-dpng','-r180');
end
close(fig);
end

function writeCaseSummary(path,cases,report)
fid=fopen(path,'w'); cleaner=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,['case,label,expected_stability,slope_order,s11,s12,s21,s22,' ...
    'det_min,det_max,n0,n1,n2,unstable_active_rays,saddle_other\n']);
for k=1:5
    dets=arrayfun(@(b)b.det,reshape(report(k).branches,1,[]));
    labels=arrayfun(@(b)string(b.transition),reshape(report(k).branches,1,[]));
    nUnstable=sum(startsWith(labels,"unstable"));
    nSaddle=sum(startsWith(labels,"saddle"));
    fprintf(fid,'%d,%s,%s,"%s",%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%d,%d,%d,%d,%d\n', ...
        k,cases(k).label,ternary(cases(k).expectedStable,'stable','unstable'),cases(k).slopeOrder, ...
        cases(k).s1(1),cases(k).s1(2),cases(k).s2(1),cases(k).s2(2), ...
        min(dets),max(dets),report(k).transitionCounts,nUnstable,nSaddle);
end
end

function writeBranchDiagnostics(path,cases,report)
fid=fopen(path,'w'); cleaner=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,['case,j1,j2,a11,a12,a21,a22,det,lambda1_real,lambda1_imag,' ...
    'lambda2_real,lambda2_imag,v1_x_real,v1_y_real,v2_x_real,v2_y_real,' ...
    'cone_angle_deg,eigenray_in_cone,transition,xstar1,xstar2\n']);
for k=1:5
    for j1=1:2
        for j2=1:2
            b=report(k).branches(j1,j2);
            ray=sprintf('%d%d%d%d',b.eigenRayInCone(1,1),b.eigenRayInCone(1,2), ...
                b.eigenRayInCone(2,1),b.eigenRayInCone(2,2));
            vectors=nan(2,2);
            if b.realEigenvectors, vectors=real(b.eigenvectors); end
            idx=(j1-1)*2+j2; xStar=report(k).vertices(:,idx);
            fprintf(fid,['%d,%d,%d,%.12g,%.12g,%.12g,%.12g,%.12g,' ...
                '%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,' ...
                '%.12g,%s,"%s",%.12g,%.12g\n'], ...
                k,j1,j2,b.A(1,1),b.A(1,2),b.A(2,1),b.A(2,2),b.det, ...
                real(b.eigenvalues(1)),imag(b.eigenvalues(1)), ...
                real(b.eigenvalues(2)),imag(b.eigenvalues(2)), ...
                vectors(1,1),vectors(2,1),vectors(1,2),vectors(2,2), ...
                b.coneAngle*180/pi,ray,b.transition,xStar(1),xStar(2));
        end
    end
end
end

function value=ternary(condition,a,b)
if condition, value=a; else, value=b; end
end
