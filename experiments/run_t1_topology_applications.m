function report = run_t1_topology_applications(outputDir,figureDir,assetDir)
%RUN_T1_TOPOLOGY_APPLICATIONS Rebuild Chapter 2 face maps and application entry.
% Every weighted Nash point solves M(weight)*x+b(weight)=0. Both M and b
% are weighted. No full payoff Hessian is fabricated from own-gradient rows.

repoRoot=fileparts(fileparts(mfilename('fullpath')));
if nargin<1 || isempty(outputDir), outputDir=fullfile(repoRoot,'results','t1'); end
if nargin<2 || isempty(figureDir), figureDir=outputDir; end
if nargin<3, assetDir=''; end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
if ~exist(figureDir,'dir'), mkdir(figureDir); end
if ~isempty(assetDir) && ~exist(assetDir,'dir'), mkdir(assetDir); end
configDir=fullfile(repoRoot,'experiments','configs'); addpath(configDir);
cleanupPath=onCleanup(@()rmpath(configDir));
p=t1_topology_parameters();

cube=analyzeCube(p.cube);
prism=analyzePrism(p.prism);
application=analyzeApplication();
assert(cube.minRcond>1e-8 && prism.minRcond>1e-8,'A sampled weighted own-gradient matrix is singular.');
assert(cube.minAbsJacobianDet>1e-6 && prism.minAbsJacobianDet>1e-6, ...
    'A sampled weight-to-Nash Jacobian is degenerate.');
assert(cube.maxEquationResidual<1e-10 && prism.maxEquationResidual<1e-10, ...
    'Weighted Nash equation residual is too large.');

plotCube(p.cube,cube,fullfile(figureDir,'T1_cube_face_correspondence.png'));
plotPrism(p.prism,prism,fullfile(figureDir,'T1_prism_face_correspondence.png'));
plotApplication(application,fullfile(figureDir,'T1_production_pollution.png'));
plotNonlinearSchematic(fullfile(figureDir,'T1_nonquadratic_schematic.png'));
if ~isempty(assetDir)
    plotCorrespondenceCard('cube',fullfile(assetDir,'T1_cube_correspondence_card.png'));
    plotCorrespondenceCard('prism',fullfile(assetDir,'T1_prism_correspondence_card.png'));
    plotApplication(application,fullfile(assetDir,'T1_production_pollution_card.png'));
    plotNonlinearSchematic(fullfile(assetDir,'T1_nonquadratic_schematic_card.png'));
end
writeFaceCsv(fullfile(outputDir,'t1_face_correspondence.csv'));
writeFeatureCsv(fullfile(outputDir,'t1_vertex_correspondence.csv'), ...
    fullfile(outputDir,'t1_edge_correspondence.csv'),cube,prism);
writeDiagnostics(fullfile(outputDir,'t1_diagnostics.csv'),cube,prism,application);

report=struct('notation',p.notation,'parameters',p,'cube',cube,'prism',prism, ...
    'application',application,'nonlinear',p.nonlinear, ...
    'mappingDefinition','x*(weight) is the unique solution of M(weight)x+b(weight)=0', ...
    'surjectionMeaning','onto the defined weighted Nash image; different weights may still map to one point', ...
    'bijectionMeaning','surjective and injective: every image point has exactly one weight', ...
    'centralizedParetoComputed',false,'completedPayoffHessians',false);
save(fullfile(outputDir,'t1_report.mat'),'report');
fprintf('T1 outputs written to %s and %s\n',outputDir,figureDir);
fprintf('Cube: min rcond %.6g, min |det Dx| %.6g, max residual %.3g.\n', ...
    cube.minRcond,cube.minAbsJacobianDet,cube.maxEquationResidual);
fprintf('Prism: min rcond %.6g, min |det Dx| %.6g, max residual %.3g.\n', ...
    prism.minRcond,prism.minAbsJacobianDet,prism.maxEquationResidual);
clear cleanupPath
end

function out=analyzeCube(c)
g=linspace(0,1,11); minR=Inf; minJ=Inf; maxRes=0;
for i=1:numel(g)
    for j=1:numel(g)
        for k=1:numel(g)
            w=[g(i),g(j),g(k)]; [x,M,b]=cubePoint(c,w); J=cubeJacobian(c,x,M);
            minR=min(minR,rcond(M)); minJ=min(minJ,abs(det(J))); maxRes=max(maxRes,norm(M*x+b));
        end
    end
end
V=dec2bin(0:7,3)-'0'; X=zeros(8,3);
for k=1:8, X(k,:)=cubePoint(c,V(k,:))'; end
E=[]; for i=1:8,for j=i+1:8,if sum(V(i,:)~=V(j,:))==1,E(end+1,:)=[i,j];end,end,end %#ok<AGROW>
out=struct('verticesWeight',V,'verticesState',X,'edges',E,'minRcond',minR, ...
    'minAbsJacobianDet',minJ,'maxEquationResidual',maxRes, ...
    'minVertexSeparation',minPairDistance(X),'theoremIdentity', ...
    'paper Example 2.9 states Theorem 2.4 conditions hold and x* is a diffeomorphism');
end

function [x,M,b]=cubePoint(c,w)
M=zeros(3); b=zeros(3,1);
for i=1:3
    M(i,:)=w(i)*c.ownRows(i,:,1)+(1-w(i))*c.ownRows(i,:,2);
    b(i)=w(i)*c.ownOffsets(i,1)+(1-w(i))*c.ownOffsets(i,2);
end
x=-M\b;
end

function J=cubeJacobian(c,x,M)
J=zeros(3);
for i=1:3
    dM=zeros(3); db=zeros(3,1);
    dM(i,:)=c.ownRows(i,:,1)-c.ownRows(i,:,2);
    db(i)=c.ownOffsets(i,1)-c.ownOffsets(i,2);
    J(:,i)=-M\(dM*x+db);
end
end

function out=analyzePrism(p)
g=linspace(0,1,13); minR=Inf; minJ=Inf; maxRes=0;
for i=1:numel(g)
    for j=1:numel(g)
        u=g(i); v=g(j); if u+v>1+1e-12, continue; end
        for k=1:numel(g)
            z=[u,v,g(k)]; [x,M,b]=prismPoint(p,z); J=prismJacobian(p,x,M);
            minR=min(minR,rcond(M)); minJ=min(minJ,abs(det(J))); maxRes=max(maxRes,norm(M*x+b));
        end
    end
end
V=[1,0,0;0,1,0;0,0,0;1,0,1;0,1,1;0,0,1]; X=zeros(6,3);
for k=1:6,X(k,:)=prismPoint(p,V(k,:))';end
E=[1,2;2,3;3,1;4,5;5,6;6,4;1,4;2,5;3,6];
out=struct('verticesWeight',V,'verticesState',X,'edges',E,'minRcond',minR, ...
    'minAbsJacobianDet',minJ,'maxEquationResidual',maxRes, ...
    'minVertexSeparation',minPairDistance(X),'theoremIdentity', ...
    'paper Example 2.10 states Theorem 2.4 conditions hold and x* is a diffeomorphism');
end

function [x,M,b]=prismPoint(p,z)
lambda=[z(1),z(2),1-z(1)-z(2)]; q=z(3); M=zeros(3); b=zeros(3,1);
for j=1:3
    M(1:2,:)=M(1:2,:)+lambda(j)*p.agent1Blocks(:,:,j);
    b(1:2)=b(1:2)+lambda(j)*p.agent1Offsets(:,j);
end
M(3,:)=q*p.agent2Rows(1,:)+(1-q)*p.agent2Rows(2,:);
b(3)=q*p.agent2Offsets(1)+(1-q)*p.agent2Offsets(2);
x=-M\b;
end

function J=prismJacobian(p,x,M)
J=zeros(3); dM=zeros(3); db=zeros(3,1);
dM(1:2,:)=p.agent1Blocks(:,:,1)-p.agent1Blocks(:,:,3);
db(1:2)=p.agent1Offsets(:,1)-p.agent1Offsets(:,3); J(:,1)=-M\(dM*x+db);
dM=zeros(3); db=zeros(3,1); dM(1:2,:)=p.agent1Blocks(:,:,2)-p.agent1Blocks(:,:,3);
db(1:2)=p.agent1Offsets(:,2)-p.agent1Offsets(:,3); J(:,2)=-M\(dM*x+db);
dM=zeros(3); db=zeros(3,1); dM(3,:)=p.agent2Rows(1,:)-p.agent2Rows(2,:);
db(3)=p.agent2Offsets(1)-p.agent2Offsets(2); J(:,3)=-M\(dM*x+db);
end

function a=analyzeApplication()
g=linspace(0,1,81); X=zeros(numel(g),numel(g));Y=X; maxRes=0; minR=Inf;
for i=1:numel(g)
    for j=1:numel(g)
        [x,M,b]=applicationPoint([g(i),g(j)]); X(j,i)=x(1);Y(j,i)=x(2);
        maxRes=max(maxRes,norm(M*x+b));minR=min(minR,rcond(M));
    end
end
a=struct('weights',g,'x1',X,'x2',Y,'maxEquationResidual',maxRes,'minRcond',minR, ...
    'identity','weighted Nash image of the two-company vector-payoff game', ...
    'centralizedSocialPareto',false);
end

function [x,M,b]=applicationPoint(w)
M=[-(6+8*w(1)),-2*w(1);-2*w(2),-(5+7*w(2))]; b=100*[w(1);w(2)]; x=-M\b;
end

function plotCube(c,out,path)
colors=faceColors(); names={'F1 w_1=0','F2 w_1=1','F3 w_2=0','F4 w_2=1','F5 w_3=0','F6 w_3=1'};
fig=figure('Color','w','Position',[70,70,1500,720]);tl=tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
ax1=nexttile(tl); hold(ax1,'on'); drawCubeFaces(ax1,@(z)z,colors); drawFeatures(ax1,out.verticesWeight,out.edges,'C'); labelCubeFaces(ax1,@(z)z);
axis(ax1,'equal');grid(ax1,'on');view(ax1,34,24);xlabel(ax1,'w_1');ylabel(ax1,'w_2');zlabel(ax1,'w_3');title(ax1,'weight domain Delta^1 x Delta^1 x Delta^1');
ax2=nexttile(tl);hold(ax2,'on');drawCubeFaces(ax2,@(z)cubePoint(c,z),colors);drawFeatures(ax2,out.verticesState,out.edges,'C');labelCubeFaces(ax2,@(z)cubePoint(c,z));
axis(ax2,'equal');grid(ax2,'on');view(ax2,34,24);xlabel(ax2,'x^1');ylabel(ax2,'x^2');zlabel(ax2,'x^3');title(ax2,'weighted Nash image X*(J)');
addFaceLegend(ax2,colors,names);title(tl,'Cube face and vertex correspondence (paper parameters)');
annotation(fig,'textbox',[.405,.01,.19,.07],'String',{'weight w  ->  solve','M(w)x+b(w)=0  ->  x*(w)'}, ...
    'HorizontalAlignment','center','VerticalAlignment','middle','FontWeight','bold','EdgeColor',[.25,.25,.25],'BackgroundColor','w');
exportgraphics(fig,path,'Resolution',180);close(fig);
end

function labelCubeFaces(ax,map)
centers=[0,.5,.5;1,.5,.5;.5,0,.5;.5,1,.5;.5,.5,0;.5,.5,1];
for k=1:6
    x=map(centers(k,:)); text(ax,x(1),x(2),x(3),sprintf(' F%d',k), ...
        'FontSize',9,'FontWeight','bold','Color',[.08,.08,.08],'BackgroundColor','w','Margin',1);
end
end

function drawCubeFaces(ax,map,colors)
g=linspace(0,1,21); [U,V]=meshgrid(g,g); n=numel(U);
for d=1:3
    for side=0:1
        Q=zeros(n,3); free=setdiff(1:3,d); Q(:,d)=side; Q(:,free(1))=U(:);Q(:,free(2))=V(:);R=zeros(n,3);
        for k=1:n,R(k,:)=map(Q(k,:))';end
        surf(ax,reshape(R(:,1),size(U)),reshape(R(:,2),size(U)),reshape(R(:,3),size(U)), ...
            'FaceColor',colors(2*d-1+side,:),'FaceAlpha',.62,'EdgeColor','none');
    end
end
end

function plotPrism(p,out,path)
colors=faceColors(); names={'P1 q=0','P2 q=1','P3 lambda_1=0','P4 lambda_2=0','P5 lambda_3=0'};
fig=figure('Color','w','Position',[70,70,1500,720]);tl=tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
ax1=nexttile(tl);hold(ax1,'on');drawPrismFaces(ax1,@(z)z,colors);drawFeatures(ax1,out.verticesWeight,out.edges,'P');labelPrismFaces(ax1,@(z)z);
axis(ax1,'equal');grid(ax1,'on');view(ax1,35,23);xlabel(ax1,'lambda_1');ylabel(ax1,'lambda_2');zlabel(ax1,'q');title(ax1,'weight domain Delta^2 x Delta^1');
ax2=nexttile(tl);hold(ax2,'on');drawPrismFaces(ax2,@(z)prismPoint(p,z),colors);drawFeatures(ax2,out.verticesState,out.edges,'P');labelPrismFaces(ax2,@(z)prismPoint(p,z));
axis(ax2,'equal');grid(ax2,'on');view(ax2,35,23);xlabel(ax2,'x_1^1');ylabel(ax2,'x_2^1');zlabel(ax2,'x^2');title(ax2,'weighted Nash image X*(J)');
addFaceLegend(ax2,colors(1:5,:),names);title(tl,'Triangular-prism face and vertex correspondence');
annotation(fig,'textbox',[.405,.01,.19,.07],'String',{'weight (lambda,q)  ->  solve','M(w)x+b(w)=0  ->  x*(w)'}, ...
    'HorizontalAlignment','center','VerticalAlignment','middle','FontWeight','bold','EdgeColor',[.25,.25,.25],'BackgroundColor','w');
exportgraphics(fig,path,'Resolution',180);close(fig);
end

function labelPrismFaces(ax,map)
centers=[1/3,1/3,0;1/3,1/3,1;0,.5,.5;.5,0,.5;.5,.5,.5];
for k=1:5
    x=map(centers(k,:)); text(ax,x(1),x(2),x(3),sprintf(' P%d',k), ...
        'FontSize',9,'FontWeight','bold','Color',[.08,.08,.08],'BackgroundColor','w','Margin',1);
end
end

function drawPrismFaces(ax,map,colors)
g=linspace(0,1,25); [U,V]=meshgrid(g,g);
% Two triangular faces q=0,1.
for side=0:1
    T=[]; for i=1:numel(g),for j=1:(numel(g)-i+1),T(end+1,:)=[g(i),g(j),side];end,end %#ok<AGROW>
    tri=delaunay(T(:,1),T(:,2)); R=mapRows(map,T); trisurf(tri,R(:,1),R(:,2),R(:,3),'Parent',ax,'FaceColor',colors(1+side,:),'FaceAlpha',.65,'EdgeColor','none');
end
% Three rectangular faces lambda_1=0, lambda_2=0, lambda_3=0.
for f=1:3
    s=U(:);q=V(:);
    if f==1,Q=[zeros(size(s)),s,q];elseif f==2,Q=[s,zeros(size(s)),q];else,Q=[s,1-s,q];end
    R=mapRows(map,Q);surf(ax,reshape(R(:,1),size(U)),reshape(R(:,2),size(U)),reshape(R(:,3),size(U)), ...
        'FaceColor',colors(2+f,:),'FaceAlpha',.62,'EdgeColor','none');
end
end

function R=mapRows(map,Q)
R=zeros(size(Q));for k=1:size(Q,1),R(k,:)=map(Q(k,:))';end
end

function drawFeatures(ax,V,E,prefix)
for k=1:size(E,1),q=V(E(k,:),:);plot3(ax,q(:,1),q(:,2),q(:,3),'k-','LineWidth',1.25);end
scatter3(ax,V(:,1),V(:,2),V(:,3),42,'k','filled');
for k=1:size(V,1),text(ax,V(k,1),V(k,2),V(k,3),sprintf('  %s%d',prefix,k),'FontSize',8,'FontWeight','bold');end
end

function addFaceLegend(ax,colors,names)
h=gobjects(numel(names),1);for k=1:numel(names),h(k)=patch(ax,nan,nan,colors(k,:),'FaceAlpha',.7);end
legend(ax,h,names,'Location','bestoutside','Interpreter','tex');
end

function plotApplication(a,path)
fig=figure('Color','w','Position',[80,80,1120,820]);ax=axes(fig);hold(ax,'on');
surf(ax,a.x1,a.x2,zeros(size(a.x1)),'FaceColor',[.55,.2,.7],'FaceAlpha',.5,'EdgeColor','none');view(ax,2);
x=linspace(0,20,400);plot(ax,x,(100-14*x)/2,'-','Color',[.80,.13,.18],'LineWidth',2.0);plot(ax,zeros(size(x)),x,'--','Color',[.80,.13,.18],'LineWidth',2.0);
plot(ax,(100-12*x)/2,x,'-.','Color',[0,.40,.72],'LineWidth',2.0);plot(ax,x,zeros(size(x)),':','Color',[0,.40,.72],'LineWidth',2.4);
xlim(ax,[0,20]);ylim(ax,[0,20]);axis(ax,'square');grid(ax,'on');xlabel(ax,'agent 1 production x^1 (dimensionless model units)');ylabel(ax,'agent 2 production x^2 (dimensionless model units)');
title(ax,'Production-pollution: decentralized weighted Nash image');
text(ax,.03,.96,'Not a centralized social Pareto set','Units','normalized','FontWeight','bold','Color',[.36,.08,.45],'BackgroundColor','w','Margin',3);
legend(ax,{'weighted Nash image','best response (BR): profit, agent 1','best response (BR): environment, agent 1','best response (BR): profit, agent 2','best response (BR): environment, agent 2'},'Location','northeast');
exportgraphics(fig,path,'Resolution',180);close(fig);
end

function plotNonlinearSchematic(path)
fig=figure('Color','w','Position',[80,80,900,720]);ax=axes(fig);hold(ax,'on');
t=linspace(-1.35,1.35,300);left=-1.15+.22*t.^2;right=.65+.34*t.^2;lower=-.85+.36*t.^2;upper=.9-.30*t.^2;
[X,Y]=meshgrid(linspace(-1.5,1.45,420),linspace(-1.5,1.5,420));
mask=X>=(-1.15+.22*Y.^2) & X<=(.65+.34*Y.^2) & ...
     Y>=(-.85+.36*X.^2) & Y<=(.9-.30*X.^2);
contourf(ax,X,Y,double(mask),[.5,.5],'FaceColor',[.55,.2,.7],'FaceAlpha',.28,'LineStyle','none');
plot(ax,left,t,'-','Color',[.80,.13,.18],'LineWidth',2);plot(ax,right,t,'--','Color',[.80,.13,.18],'LineWidth',2);plot(ax,t,lower,'-.','Color',[0,.40,.72],'LineWidth',2);plot(ax,t,upper,':','Color',[0,.40,.72],'LineWidth',2.4);
axis(ax,'equal');xlim(ax,[-1.5,1.45]);ylim(ax,[-1.5,1.5]);axis(ax,'off');title(ax,'Schematic nonquadratic Nash geometry');
text(ax,.03,.96,'SCHEMATIC ONLY','Units','normalized','FontWeight','bold','Color',[.36,.08,.45]);
text(ax,-1.25,-1.58,'Curved own-gradient zero sets can bound a weighted Nash image','FontSize',10);
exportgraphics(fig,path,'Resolution',180);close(fig);
end

function plotCorrespondenceCard(kind,path)
if strcmp(kind,'cube')
    faceRows={'F1/F2: w_1=0/1','F3/F4: w_2=0/1','F5/F6: w_3=0/1'};
    vertexText='C1-C8: identical labels on weight and Nash vertices';
    heading='Cube correspondence key';
else
    faceRows={'P1/P2: q=0/1','P3: lambda_1=0','P4: lambda_2=0','P5: lambda_3=0'};
    vertexText='P1-P6: identical labels on weight and Nash vertices';
    heading='Triangular-prism correspondence key';
end
fig=figure('Color','w','Visible','off','Position',[60,60,760,760]);ax=axes(fig);hold(ax,'on');axis(ax,'off');
xlim(ax,[0,1]);ylim(ax,[0,1]);
text(ax,.5,.94,heading,'HorizontalAlignment','center','FontSize',18,'FontWeight','bold');
text(ax,.18,.82,'weight domain','HorizontalAlignment','center','FontSize',13,'FontWeight','bold');
text(ax,.82,.82,'weighted Nash image','HorizontalAlignment','center','FontSize',13,'FontWeight','bold');
text(ax,.50,.82,'->','HorizontalAlignment','center','FontSize',24,'FontWeight','bold');
text(ax,.50,.74,{'same face ID','same vertex ID'},'HorizontalAlignment','center','FontSize',12,'Color',[.25,.25,.25]);
if numel(faceRows)==3, y=.61; step=.12; boxHeight=.09; else, y=.61; step=.095; boxHeight=.072; end
for k=1:numel(faceRows)
    rectangle(ax,'Position',[.08,y-boxHeight/2,.84,boxHeight],'Curvature',.08,'FaceColor',[.94,.94,.98],'EdgeColor',[.45,.35,.55]);
    text(ax,.5,y,faceRows{k},'HorizontalAlignment','center','FontSize',13,'FontWeight','bold'); y=y-step;
end
rectangle(ax,'Position',[.08,.10,.84,.115],'Curvature',.08,'FaceColor',[.90,.96,.93],'EdgeColor',[.25,.55,.35]);
text(ax,.5,.158,vertexText,'HorizontalAlignment','center','FontSize',11,'FontWeight','bold');
text(ax,.5,.035,'Global one-to-one correspondence uses the paper theorem conditions; finite samples are diagnostics.', ...
    'HorizontalAlignment','center','FontSize',9,'Color',[.25,.25,.25]);
exportgraphics(fig,path,'Resolution',150);close(fig);
end

function writeFaceCsv(path)
rows={ ...
 'cube','F1','w_1=0','remove J_1^1; keep J_2^1','2';'cube','F2','w_1=1','remove J_2^1; keep J_1^1','2'; ...
 'cube','F3','w_2=0','remove J_1^2; keep J_2^2','2';'cube','F4','w_2=1','remove J_2^2; keep J_1^2','2'; ...
 'cube','F5','w_3=0','remove J_1^3; keep J_2^3','2';'cube','F6','w_3=1','remove J_2^3; keep J_1^3','2'; ...
 'prism','P1','q=0','remove J_1^2; keep J_2^2','2';'prism','P2','q=1','remove J_2^2; keep J_1^2','2'; ...
 'prism','P3','lambda_1=0','remove J_1^1','2';'prism','P4','lambda_2=0','remove J_2^1','2'; ...
 'prism','P5','lambda_3=0','remove J_3^1','2'};
fid=fopen(path,'w');c=onCleanup(@()fclose(fid));fprintf(fid,'domain,face,weight_condition,subgame_interpretation,dimension\n');
for k=1:size(rows,1),fprintf(fid,'%s,%s,%s,%s,%s\n',rows{k,:});end
end

function writeFeatureCsv(vpath,epath,cube,prism)
fid=fopen(vpath,'w');c=onCleanup(@()fclose(fid));fprintf(fid,'domain,vertex,weight_1,weight_2,weight_3,state_1,state_2,state_3\n');
for k=1:8,fprintf(fid,'cube,C%d,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n',k,cube.verticesWeight(k,:),cube.verticesState(k,:));end
for k=1:6,fprintf(fid,'prism,P%d,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n',k,prism.verticesWeight(k,:),prism.verticesState(k,:));end
clear c;fid=fopen(epath,'w');c=onCleanup(@()fclose(fid));fprintf(fid,'domain,edge,vertex_a,vertex_b\n');
for k=1:size(cube.edges,1),fprintf(fid,'cube,E%d,C%d,C%d\n',k,cube.edges(k,:));end
for k=1:size(prism.edges,1),fprintf(fid,'prism,E%d,P%d,P%d\n',k,prism.edges(k,:));end
end

function writeDiagnostics(path,cube,prism,a)
fid=fopen(path,'w');c=onCleanup(@()fclose(fid));fprintf(fid,'example,min_rcond,min_abs_jacobian_det,max_equation_residual,min_vertex_separation\n');
fprintf(fid,'cube,%.12g,%.12g,%.12g,%.12g\n',cube.minRcond,cube.minAbsJacobianDet,cube.maxEquationResidual,cube.minVertexSeparation);
fprintf(fid,'prism,%.12g,%.12g,%.12g,%.12g\n',prism.minRcond,prism.minAbsJacobianDet,prism.maxEquationResidual,prism.minVertexSeparation);
fprintf(fid,'application,%.12g,NaN,%.12g,NaN\n',a.minRcond,a.maxEquationResidual);
end

function d=minPairDistance(X)
d=Inf;for i=1:size(X,1),for j=i+1:size(X,1),d=min(d,norm(X(i,:)-X(j,:)));end,end
end

function c=faceColors()
c=[.20,.55,.90;.95,.50,.15;.25,.70,.40;.75,.35,.80;.95,.75,.20;.20,.75,.75];
end
