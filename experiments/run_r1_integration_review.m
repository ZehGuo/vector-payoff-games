function report = run_r1_integration_review(cleanRunRoot,outputDir)
%RUN_R1_INTEGRATION_REVIEW Validate clean-run outputs and assemble the R1 pack.
% This entry does not rerun the scientific experiments.  R1 launches each
% task entry in its own clean MATLAB process, then calls this function in a
% seventh clean process to verify and package those outputs.

repoRoot = fileparts(fileparts(mfilename('fullpath')));
if nargin < 1 || isempty(cleanRunRoot)
    cleanRunRoot = fullfile(repoRoot,'results','r1','clean_runs');
end
if nargin < 2 || isempty(outputDir)
    outputDir = fullfile(repoRoot,'results','r1','review_pack');
end
assert(exist(cleanRunRoot,'dir')==7,'R1 clean-run root does not exist.');
assert(exist(outputDir,'dir')~=7, ...
    'R1 review pack already exists; use a new empty output directory.');
mkdir(outputDir);
figureDir = fullfile(outputDir,'figures');
mkdir(figureDir);

rows = figureRows();
for k = 1:size(rows,1)
    sourcePath = fullfile(cleanRunRoot,rows{k,1},rows{k,2});
    assert(exist(sourcePath,'file')==2, ...
        'Missing R1 figure from clean run: %s',sourcePath);
    destinationPath = fullfile(figureDir,rows{k,3});
    ok = copyfile(sourcePath,destinationPath);
    assert(ok,'Could not copy R1 figure: %s',sourcePath);
    info = imfinfo(destinationPath);
    assert(info.Width>=900 && info.Height>=600, ...
        'R1 figure is unexpectedly small: %s',destinationPath);
end

artifacts = artifactRows();
for k = 1:size(artifacts,1)
    artifactPath = fullfile(cleanRunRoot,artifacts{k,1},artifacts{k,2});
    assert(exist(artifactPath,'file')==2, ...
        'Missing R1 clean-run artifact: %s',artifactPath);
end

indexPath = fullfile(outputDir,'R1_FIGURE_INDEX.csv');
fid = fopen(indexPath,'w');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'file,task,repository_role,website_status,claim_boundary\n');
for k = 1:size(rows,1)
    fprintf(fid,'"%s","%s","%s","%s","%s"\n', ...
        rows{k,3},rows{k,4},rows{k,5},rows{k,6},rows{k,7});
end

readmePath = fullfile(outputDir,'README.md');
fidReadme = fopen(readmePath,'w');
cleanupReadme = onCleanup(@() fclose(fidReadme));
fprintf(fidReadme,'# R1 local figure review pack\n\n');
fprintf(fidReadme,['Generated from six separate clean MATLAB sessions and ', ...
    'assembled in a seventh clean session. This directory is local, ignored ', ...
    'runtime output; it is not a publication or deployment bundle.\n\n']);
fprintf(fidReadme,['Review `R1_FIGURE_INDEX.csv` before selecting website ', ...
    'figures. All 18 repository figures are retained. `baseline candidate` ', ...
    'means the figure belongs to an author-approved candidate group; it is ', ...
    'not final publication approval.\n\n']);
fprintf(fidReadme,['Scientific claims and limitations remain controlled by ', ...
    '`audit/implementation/R1.md` and the task reports. A finite grid, a ', ...
    'trajectory, or a successful run is not a theorem proof.\n']);

report = struct();
report.matlabVersion = version;
report.computer = computer;
report.cleanRunRoot = cleanRunRoot;
report.outputDir = outputDir;
report.figureCount = size(rows,1);
report.artifactCount = size(artifacts,1);
report.figureFiles = string(rows(:,3));
save(fullfile(outputDir,'r1_review_report.mat'),'report');
fprintf('R1 review pack written to %s (%d figures, %d checked artifacts).\n', ...
    outputDir,report.figureCount,report.artifactCount);
end

function rows = figureRows()
% source task, generated name, canonical pack name, task, role, site status, limit
rows = {
 't1','T1_cube_face_correspondence.png','T1_cube_face_correspondence.png','T1','complete cube face/edge/vertex mapping','baseline candidate','finite grid is implementation evidence; global identity uses the paper theorem';
 't1','T1_prism_face_correspondence.png','T1_prism_face_correspondence.png','T1','complete prism face/edge/vertex mapping','baseline candidate','finite grid is implementation evidence; global identity uses the paper theorem';
 't1','T1_production_pollution.png','T1_production_pollution.png','T1','application entry point','baseline candidate','purple set is a weighted Nash image, not centralized social Pareto';
 't1','T1_nonquadratic_schematic.png','T1_nonquadratic_schematic.png','T1','nonquadratic scope illustration','repository only','schematic only; no source functions or numerical parameters asserted';
 's1','s1_five_case_overview.png','S1_five_case_overview.png','S1','five-case compact overview','appendix candidate','case identity comes from slopes, matrices, eigenstructure and active cones, not trajectories';
 's1','s1_eigenvectors_and_transitions.png','S1_eigenvectors_transitions.png','S1','eigenvector and transition explanation','repository support','coordinate changes do not remove the unstable active-cone direction';
 's2','S2_rank_degenerate_five_cases.png','S2_rank_degenerate_five_cases.png','S2','rank-degenerate five-case coverage','repository full scope','new construction; not an exact thesis-parameter reproduction';
 's2','S2_noncompact_three_configurations.png','S2_noncompact_three_configurations.png','S2','three noncompact configurations','repository full scope','noncompactness follows from the analytic criterion, not the finite window';
 'p1','p1_three_payoff_properties.png','P1_three_payoff_properties.png','P1','nonweak/all/weak comparison','baseline candidate','new exact comparison family; not exact Figure 4.3 parameters';
 'p1','p1_rate_decomposition.png','P1_rate_decomposition.png','P1','own/externality/total-rate decomposition','repository support','own contribution and total payoff derivative are distinct';
 'p1','p1_weak_pareto_trap.png','P1_weak_pareto_trap.png','P1','independent weak-Pareto trap','baseline candidate','weak-at-every-time statement is finite-grid evidence';
 'x1','x1_domain_map.png','X1_domain_map.png','X1','domain-to-image map','baseline candidate','colored images are local subsets, not whole-quadrant surjectivity claims';
 'x1','x1_fiber_collapse.png','X1_fiber_collapse.png','X1','rank-one information loss','repository support','axis inverse is set-valued; no representative inverse is selected';
 'x1','x1_trajectories_lyapunov.png','X1_trajectories_lyapunov.png','X1','original/image/independent trajectory comparison','baseline candidate','mapped and independently integrated trajectories are different objects';
 'i1','I1_design_geometry.png','I1_design_geometry.png','I1','Pareto/Nash/omega/design geometry','baseline candidate','social Pareto and decentralized Nash sets remain distinct';
 'i1','I1_sigma_budget.png','I1_sigma_budget.png','I1','three sigma regimes and common exclusion','baseline candidate','certificate failure is not general impossibility';
 'i1','I1_before_after.png','I1_before_after.png','I1','paired before/after behavior and budget','baseline candidate','finite endpoint is near the target, not identical to it';
 'i1','I1_INC_omega.png','I1_INC_omega.png','I1','different-game omega supplement','repository full scope','supplement is not a one-factor omega comparison'};
end

function rows = artifactRows()
rows = {
 't1','t1_report.mat'; 't1','t1_face_correspondence.csv';
 't1','t1_edge_correspondence.csv'; 't1','t1_vertex_correspondence.csv';
 't1','t1_diagnostics.csv';
 's1','s1_report.mat'; 's1','s1_case_summary.csv';
 's1','s1_branch_diagnostics.csv';
 's2','s2_report.mat'; 's2','s2_case_summary.csv';
 's2','s2_branch_diagnostics.csv'; 's2','s2_noncompact_summary.csv';
 's2','s2_trajectory_summary.csv';
 'p1','p1_report.mat'; 'p1','p1_samples.csv'; 'p1','p1_summary.csv';
 'x1','x1_report.mat'; 'x1','x1_trajectories.csv';
 'i1','i1_report.mat'; 'i1','i1_condition_checks.csv';
 'i1','i1_trajectory_summary.csv'};
end
