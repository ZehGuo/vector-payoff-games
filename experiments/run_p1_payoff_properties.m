function report = run_p1_payoff_properties(outputDir, publicFigureDir, derivedFigureDir)
%RUN_P1_PAYOFF_PROPERTIES Rebuild P1 payoff-property and weak-trap experiments.
%
% REPORT = RUN_P1_PAYOFF_PROPERTIES() writes figures, sampled diagnostics,
% parameter tables, and a MAT report to results/p1.  PUBLICFIGUREDIR can
% separately receive the tracked public figures, and DERIVEDFIGUREDIR can
% receive the two mobile cards.  State order is
% x=[x^1;x^2], while the payoff order is [J_1^1,J_2^1,J_1^2,J_2^2].
%
% The first three games are a documented construction with exact trajectory
% and rate formulae.  The trap game is the actual legacy simulation version:
% its A/b/x0/alpha values and scaled-own-gradient helper behavior are kept.

if nargin < 1 || isempty(outputDir)
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    outputDir = fullfile(repoRoot, 'results', 'p1');
end
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
if nargin < 2 || isempty(publicFigureDir), publicFigureDir=outputDir; end
if nargin < 3, derivedFigureDir=''; end
if ~exist(publicFigureDir, 'dir'), mkdir(publicFigureDir); end
if ~isempty(derivedFigureDir) && ~exist(derivedFigureDir, 'dir'), mkdir(derivedFigureDir); end

games = defineGames();
sampleStep = 0.002;
report = struct([]);
for k = 1:numel(games)
    t = (0:sampleStep:games(k).tFinal)';
    opts = odeset('RelTol',1e-10,'AbsTol',1e-12,'MaxStep',0.01);
    [t,x] = ode45(@(~,z) rhs(games(k),z), t, games(k).x0, opts);
    d = diagnostics(games(k),t,x);
    report(k).game = games(k); %#ok<AGROW>
    report(k).t = t;
    report(k).x = x;
    report(k).payoff = d.payoff;
    report(k).own = d.own;
    report(k).externality = d.externality;
    report(k).totalRate = d.totalRate;
    report(k).gammaMetric = d.gammaMetric;
    report(k).omegaMetric = d.omegaMetric;
end

% Continuous-time identity for the common three-game construction.
for k = 1:3
    z = exp(-report(k).t);
    exactX = [2*(1-z), 1+2*z];
    report(k).exactStateMaxError = max(abs(report(k).x-exactX),[],'all');
end

[witness,ok] = findTrapWitness(report(4),0.02,report(4).game.tFinal-0.1);
assert(ok, 'No interior trap witness was found on the declared output grid.');
report(4).trapWitness = witness;

writeSamples(fullfile(outputDir,'p1_samples.csv'),report);
writeSummary(fullfile(outputDir,'p1_summary.csv'),report);
if strcmp(outputDir,publicFigureDir)
    publicNames={'p1_three_payoff_properties.png','p1_rate_decomposition.png','p1_weak_pareto_trap.png'};
else
    publicNames={'P1_three_payoff_properties.png','P1_rate_decomposition.png','P1_weak_pareto_trap.png'};
end
plotThreeProperties(report(1:3),fullfile(publicFigureDir,publicNames{1}));
plotDecomposition(report(1:3),fullfile(publicFigureDir,publicNames{2}));
plotTrap(report(4),fullfile(publicFigureDir,publicNames{3}));
if ~strcmp(outputDir,publicFigureDir)
    copyfile(fullfile(publicFigureDir,publicNames{1}),fullfile(outputDir,'p1_three_payoff_properties.png'));
    copyfile(fullfile(publicFigureDir,publicNames{2}),fullfile(outputDir,'p1_rate_decomposition.png'));
    copyfile(fullfile(publicFigureDir,publicNames{3}),fullfile(outputDir,'p1_weak_pareto_trap.png'));
end
if ~isempty(derivedFigureDir)
    plotRateCard(report(1),fullfile(derivedFigureDir,'P1_rate_decomposition_card.png'));
    plotTrapCard(report(4),fullfile(derivedFigureDir,'P1_trap_two_times_card.png'));
end
save(fullfile(outputDir,'p1_report.mat'),'games','report');

fprintf('P1 outputs written to %s\n',outputDir);
fprintf('Trap witness: t1=%.6f < t2=%.6f; Delta[J_1^2,J_2^2]=[%.6f,%.6f].\n', ...
    witness.t1,witness.t2,witness.delta(1),witness.delta(2));
fprintf(['The trap weak-property check is a finite output-grid observation; ', ...
    'it is not labeled a continuous-time proof.\n']);
end

function games = defineGames()
% Common family: each agent has own targets [2,4] and [-1,1].  External
% coefficients affect payoff rates but not own-gradients or the dynamics.
names = {'nonweak','all-payoff-nondecreasing','weak-not-all'};
ext = {[5,6,-7,-6],[0,0,0,0],[3,-4,5,-3]};
properties = {'weak','all','weak'};
for k = 1:3
    e = ext{k};
    games(k).name = names{k}; %#ok<AGROW>
    games(k).source = 'new P1 construction; not a literal Fig. 4.3 transcription';
    games(k).A = cat(3,[-1,0;0,0],[-1,0;0,0],[0,0;0,-1],[0,0;0,-1]);
    games(k).b = [[2;e(1)],[4;e(2)],[e(3);-1],[e(4);1]];
    games(k).c = zeros(1,4);
    games(k).alpha = ones(1,4);
    games(k).x0 = [0;3];
    games(k).tFinal = 5;
    games(k).rule = 'nearest-BR';
    games(k).property = properties{k};
end

% Exact arrays produced by trap.m/testfun1.m.  The executable does not add
% the caption constants; they would not affect the field or payoff changes.
games(4).name = 'weak-Pareto-trap';
games(4).source = ['legacy_github/trap_of_weak_Pareto_improvement: actual ', ...
    'simulation parameters and scaled-own-gradient helper'];
games(4).A = cat(3,[-2,1;1,-3],[-2,-1;-1,-10], ...
    [-4,1;1,-4],[-5,-1;-1,-2]);
games(4).b = [[5;-5],[20;124],[90;0],[72;0]];
games(4).c = [0,0,0,0];
games(4).alpha = [1,1.2,1,2];
games(4).x0 = [18.5;-8.71];
games(4).tFinal = 4;
games(4).rule = 'scaled-own-gradient';
games(4).property = 'weak-trap';
end

function f = rhs(game,x)
[~,own] = gradients(game,x);
f = zeros(2,1);
for i = 1:2
    ids = (2*i-1):(2*i);
    h = own(ids);
    if h(1)*h(2) <= 0, continue; end
    if strcmp(game.rule,'nearest-BR')
        q = [abs(h(1)/game.A(i,i,ids(1))),abs(h(2)/game.A(i,i,ids(2)))];
    else
        q = abs(game.alpha(ids).*h(:)');
    end
    if q(1) <= q(2), selected=ids(1); else, selected=ids(2); end
    f(i) = game.alpha(selected)*own(selected);
end
end

function [full,own] = gradients(game,x)
full = zeros(2,4);
for j=1:4, full(:,j)=game.A(:,:,j)*x+game.b(:,j); end
own = [full(1,1),full(1,2),full(2,3),full(2,4)];
end

function d = diagnostics(game,t,x) %#ok<INUSD>
n=size(x,1); d.payoff=zeros(n,4); d.own=zeros(n,4);
d.externality=zeros(n,4); d.totalRate=zeros(n,4);
for q=1:n
    z=x(q,:)'; f=rhs(game,z); [full,ownGradient]=gradients(game,z);
    for j=1:4
        d.payoff(q,j)=0.5*z'*game.A(:,:,j)*z+game.b(:,j)'*z+game.c(j);
        owner=1+(j>2);
        d.own(q,j)=ownGradient(j)*f(owner);
        d.totalRate(q,j)=full(:,j)'*f;
        d.externality(q,j)=d.totalRate(q,j)-d.own(q,j);
    end
end
if strcmp(game.property,'all')
    d.gammaMetric=min(d.externality,[],2);
    d.omegaMetric=min(d.totalRate,[],2);
else
    d.gammaMetric=min(max(d.externality(:,1:2),[],2),max(d.externality(:,3:4),[],2));
    d.omegaMetric=min(max(d.totalRate(:,1:2),[],2),max(d.totalRate(:,3:4),[],2));
end
end

function [w,ok] = findTrapWitness(r,minT1,maxT2)
idx1=find(r.t>=minT1 & r.t<maxT2); idx2=find(r.t<=maxT2);
best=-inf; pair=[0,0]; delta=[nan,nan];
for a=idx1(:)'
    later=idx2(idx2>a);
    if isempty(later), continue; end
    changes=r.payoff(later,3:4)-r.payoff(a,3:4);
    scores=min(-changes,[],2); [score,j]=max(scores);
    if score>best, best=score; pair=[a,later(j)]; delta=changes(j,:); end
end
ok=best>0;
w=struct('t1',r.t(pair(1)),'t2',r.t(pair(2)), ...
    'payoff1',r.payoff(pair(1),3:4),'payoff2',r.payoff(pair(2),3:4), ...
    'delta',delta,'minimumDrop',best,'indices',pair);
end

function plotThreeProperties(r,path)
fig=figure('Color','w','Position',[100,100,1500,1080]);
judgments={'Nonweak: both total rates are negative for each agent.', ...
    'All-payoff: every total payoff rate is nonnegative.', ...
    'Weak, not all: each agent has one positive and one negative total rate.'};
for k=1:3
    subplot(3,3,3*k-2); phasePanel(r(k)); title(sprintf('%c  %s',64+k,strrep(r(k).game.name,'-',' ')));
    subplot(3,3,3*k-1); plot(r(k).t,r(k).payoff-r(k).payoff(1,:),'LineWidth',1.5); yline(0,'k:'); grid on;
    if k==1, legend(payoffLabels(),'Location','best'); end
    ylabel('\Delta payoff'); xlabel('t');
    subplot(3,3,3*k); plot(r(k).t,r(k).totalRate,'LineWidth',1.4); yline(0,'k:','zero'); grid on;
    ylabel('dJ/dt (total)'); xlabel('t');
    text(.02,.96,judgments{k},'Units','normalized','VerticalAlignment','top', ...
        'FontWeight','bold','FontSize',9,'BackgroundColor','w','Margin',2);
end
sgtitle({'P1: three exact comparison games (new family; not exact Fig. 4.3 parameters)', ...
    'Columns: state trajectory | payoff change | total payoff rate'});
exportgraphics(fig,path,'Resolution',180); close(fig);
end

function plotDecomposition(r,path)
fig=figure('Color','w','Position',[100,100,1500,980]);
cols=[0 .447 .741; .85 .325 .098];
for k=1:3
    for agent=1:2
        subplot(3,2,2*(k-1)+agent); ids=(2*agent-1):(2*agent);
        for q=1:2, plot(r(k).t,r(k).totalRate(:,ids(q)),'Color',cols(q,:),'LineWidth',1.8); hold on; end
        for q=1:2, plot(r(k).t,r(k).own(:,ids(q)),'--','Color',cols(q,:),'LineWidth',1.25); end
        for q=1:2, plot(r(k).t,r(k).externality(:,ids(q)),':','Color',cols(q,:),'LineWidth',1.65); end
        yline(0,'k-','zero','LabelHorizontalAlignment','left'); grid on;
        title(sprintf('%s: agent %d',strrep(r(k).game.name,'-',' '),agent)); xlabel('t'); ylabel('rate');
    end
end
han=axes(fig,'Visible','off'); %#ok<LAXES>
hold(han,'on');
h(1)=plot(han,nan,nan,'Color',cols(1,:),'LineWidth',2);h(2)=plot(han,nan,nan,'Color',cols(2,:),'LineWidth',2);
h(3)=plot(han,nan,nan,'k-','LineWidth',2);h(4)=plot(han,nan,nan,'k--','LineWidth',1.5);h(5)=plot(han,nan,nan,'k:','LineWidth',1.8);
legend(h,{'objective 1','objective 2','total rate','own-direction contribution','externality'}, ...
    'Location','southoutside','Orientation','horizontal');
sgtitle({'Total payoff rate = own-direction contribution + externality', ...
    'Color identifies objective; line style identifies term; horizontal black line is zero'});
exportgraphics(fig,path,'Resolution',180); close(fig);
end

function plotTrap(r,path)
w=r.trapWitness; fig=figure('Color','w','Position',[100,100,1550,500]);
subplot(1,3,1); phasePanel(r); hold on;
scatter(r.x(w.indices(1),1),r.x(w.indices(1),2),60,'k','filled');
scatter(r.x(w.indices(2),1),r.x(w.indices(2),2),60,'r','filled');
title('Actual legacy scaled-rule trap');
subplot(1,3,2); plot(r.t,r.payoff(:,3:4),'LineWidth',1.7); hold on;
xline(w.t1,'k--'); xline(w.t2,'r--');
scatter([w.t1,w.t1],w.payoff1,35,'k','filled');
scatter([w.t2,w.t2],w.payoff2,35,'r','filled'); grid on;
legend({'J_1^2','J_2^2','t_1','t_2'},'Location','best'); xlabel('t'); ylabel('payoff');
title(sprintf('Interior witness: t_1=%.3f < t_2=%.3f',w.t1,w.t2));
text(.02,.04,sprintf('J_1^2: %+.3f   J_2^2: %+.3f',w.delta(1),w.delta(2)), ...
    'Units','normalized','FontWeight','bold','BackgroundColor','w','Margin',3);
subplot(1,3,3); plot(r.t,r.totalRate(:,3:4),'LineWidth',1.6); hold on;
plot(r.t,r.own(:,3:4),'--','LineWidth',1.1); plot(r.t,r.externality(:,3:4),':','LineWidth',1.4);
yline(0,'k-'); grid on; xlabel('t'); ylabel('rate');
legend({'total J_1^2','total J_2^2','own J_1^2','own J_2^2','external J_1^2','external J_2^2'},'Location','best');
title('Rate decomposition for agent 2');
sgtitle({'Legacy scaled-own-gradient trap: actual A/b/x_0/alpha and helper rule', ...
    'Weak-at-every-time is finite-grid evidence; this trap does not replace the nonweak case'});
exportgraphics(fig,path,'Resolution',180); close(fig);
end

function plotRateCard(r,path)
fig=figure('Color','w','Position',[100,100,900,620]);ids=1:2;cols=[0 .447 .741;.85 .325 .098];
for q=1:2,plot(r.t,r.totalRate(:,ids(q)),'Color',cols(q,:),'LineWidth',2.5);hold on;end
for q=1:2,plot(r.t,r.own(:,ids(q)),'--','Color',cols(q,:),'LineWidth',1.8);end
for q=1:2,plot(r.t,r.externality(:,ids(q)),':','Color',cols(q,:),'LineWidth',2.1);end
yline(0,'k-','zero');grid on;xlabel('time t');ylabel('payoff rate');
legend({'J_1^1 total','J_2^1 total','J_1^1 own','J_2^1 own','J_1^1 externality','J_2^1 externality'}, ...
    'Location','southoutside','NumColumns',2);
title({'Why moving in an own-improving direction may lower total payoff', ...
    'total rate = own-direction contribution + externality'});
exportgraphics(fig,path,'Resolution',180);close(fig);
end

function plotTrapCard(r,path)
w=r.trapWitness;fig=figure('Color','w','Position',[100,100,900,620]);
plot(r.t,r.payoff(:,3),'Color',[0 .447 .741],'LineWidth',2.2);hold on;
plot(r.t,r.payoff(:,4),'Color',[.85 .325 .098],'LineWidth',2.2);
xline(w.t1,'k--');xline(w.t2,'r--');
scatter([w.t1,w.t1],w.payoff1,65,'k','filled');scatter([w.t2,w.t2],w.payoff2,65,'r','filled');
grid on;xlabel('time t');ylabel('agent 2 payoff');
legend({'J_1^2','J_2^2','t_1','t_2'},'Location','southoutside','Orientation','horizontal');
title({sprintf('Two interior times: t_1=%.3f < t_2=%.3f',w.t1,w.t2), ...
    sprintf('Both decrease: Delta J_1^2=%+.3f, Delta J_2^2=%+.3f',w.delta(1),w.delta(2))});
exportgraphics(fig,path,'Resolution',180);close(fig);
end

function phasePanel(r)
plot(r.x(:,1),r.x(:,2),'k-','LineWidth',2); hold on; scatter(r.x(1,1),r.x(1,2),45,'k','filled');
g=r.game; xl=[min(r.x(:,1)),max(r.x(:,1))]; yl=[min(r.x(:,2)),max(r.x(:,2))];
pad=max([xl(2)-xl(1),yl(2)-yl(1),1]); xl=xl+[-.35,.35]*pad; yl=yl+[-.35,.35]*pad;
xx=linspace(xl(1),xl(2),90); yy=linspace(yl(1),yl(2),90); [X,Y]=meshgrid(xx,yy);
GM=zeros(size(X)); OM=zeros(size(X));
for q=1:numel(X)
    dd=diagnostics(g,0,[X(q),Y(q)]); GM(q)=dd.gammaMetric; OM(q)=dd.omegaMetric;
end
if min(GM,[],'all')<0 && max(GM,[],'all')>=0, contour(X,Y,GM,[0,0],'--','Color',[.9,.45,.05],'LineWidth',1.5); end
if min(OM,[],'all')<0 && max(OM,[],'all')>=0, contour(X,Y,OM,[0,0],':','Color',[.65,0,.1],'LineWidth',2); end
for agent=1:2
    ids=(2*agent-1):(2*agent);
    for j=ids
        ownRow=g.A(agent,:,j); ownB=g.b(agent,j);
        if abs(ownRow(2))>eps
            xlineGrid=linspace(xl(1),xl(2),100);
            ylineGrid=-(ownRow(1)*xlineGrid+ownB)/ownRow(2);
            plot(xlineGrid,ylineGrid,'Color',(.2+.25*(agent-1))*[1,1,1]+[0,.15,.35],'LineWidth',1);
        elseif abs(ownRow(1))>eps
            xline(-ownB/ownRow(1),'Color',[.2,.45,.8]);
        end
    end
end
xlim(xl); ylim(yl); axis square; grid on; xlabel('x^1'); ylabel('x^2');
text(xl(1)+.03*(xl(2)-xl(1)),yl(2)-.08*(yl(2)-yl(1)),sprintf('rule: %s',g.rule),'FontSize',8);
end

function labels=payoffLabels(), labels={'J_1^1','J_2^1','J_1^2','J_2^2'}; end

function writeSamples(path,r)
fid=fopen(path,'w'); cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'case,t,x1,x2,J11,J12,J21,J22,dJ11,dJ12,dJ21,dJ22,own11,own12,own21,own22,ext11,ext12,ext21,ext22,gamma_metric,omega_metric\n');
for k=1:numel(r)
    for q=1:numel(r(k).t)
        values=[r(k).t(q),r(k).x(q,:),r(k).payoff(q,:),r(k).totalRate(q,:),r(k).own(q,:),r(k).externality(q,:),r(k).gammaMetric(q),r(k).omegaMetric(q)];
        fprintf(fid,'%s',r(k).game.name); fprintf(fid,',%.12g',values); fprintf(fid,'\n');
    end
end
end

function writeSummary(path,r)
fid=fopen(path,'w'); cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'case,rule,min_dJ11,min_dJ12,min_dJ21,min_dJ22,min_weak_agent1,min_weak_agent2,min_gamma_metric,min_omega_metric\n');
for k=1:numel(r)
    md=min(r(k).totalRate,[],1); weak=[min(max(r(k).totalRate(:,1:2),[],2)),min(max(r(k).totalRate(:,3:4),[],2))];
    fprintf(fid,'%s,%s,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n', ...
        r(k).game.name,r(k).game.rule,md,weak,min(r(k).gammaMetric),min(r(k).omegaMetric));
end
end
